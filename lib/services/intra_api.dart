import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// API 管理类
class IntraApi {
  static const String uid = 'u-s4t2ud-e2cf8fda9cbaf28ced138deca873b4903a8853323e6b0363ced40da94e662f01';
  static const String secret = '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';
  static const String redirectUri = 'com.example.swiftcompanion://oauth2redirect';
  static const String authUrl = 'https://api.intra.42.fr/oauth/authorize';
  static const String tokenUrl = 'https://api.intra.42.fr/oauth/token';
  static const String apiBase = 'https://api.intra.42.fr/v2';

  final storage = const FlutterSecureStorage();

  // 生成授权 URL
  // forceReauth: 是否强制重新授权（登出后使用）
  String getAuthorizationUrl({bool forceReauth = false}) {
    final params = {
      'client_id': uid,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'public',
    };
    if (forceReauth) {
      params['prompt'] = 'login consent';
      // 添加时间戳参数，确保每次都是新的请求（绕过缓存）
      params['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    return Uri.parse(authUrl).replace(queryParameters: params).toString();
  }

  // 用授权码换取 token
  Future<bool> exchangeCodeForToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        body: {
          'grant_type': 'authorization_code',
          'client_id': uid,
          'client_secret': secret,
          'code': code,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String;
        final refreshToken = data['refresh_token'] as String;
        final expiresIn = data['expires_in'] as int;
        final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

        await storage.write(key: 'access_token', value: accessToken);
        await storage.write(key: 'refresh_token', value: refreshToken);
        await storage.write(key: 'expires_at', value: expiresAt.toIso8601String());

        return true;
      }
    } catch (e) {
      print('Token exchange error: $e');
    }
    return false;
  }

  // 刷新 token
  Future<bool> refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        body: {
          'grant_type': 'refresh_token',
          'client_id': uid,
          'client_secret': secret,
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String;
        final expiresIn = data['expires_in'] as int;
        final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

        await storage.write(key: 'access_token', value: accessToken);
        await storage.write(key: 'refresh_token', value: newRefreshToken);
        await storage.write(key: 'expires_at', value: expiresAt.toIso8601String());

        return true;
      }
    } catch (e) {
      print('Token refresh error: $e');
    }
    return false;
  }

  // 获取有效 token
  Future<String?> getValidToken() async {
    String? token = await storage.read(key: 'access_token');
    String? expiresAtStr = await storage.read(key: 'expires_at');

    if (token != null && expiresAtStr != null) {
      final expiry = DateTime.parse(expiresAtStr);
      if (DateTime.now().isBefore(expiry.subtract(const Duration(minutes: 5)))) {
        return token;
      } else {
        if (await refreshToken()) {
          return await storage.read(key: 'access_token');
        }
      }
    }
    return null;
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getValidToken();
    return token != null;
  }

  // 登出
  Future<void> logout() async {
    await storage.deleteAll();
  }

  // 获取当前用户信息
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getValidToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$apiBase/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('API error: $e');
    }
    return null;
  }

  // 搜索用户
  Future<Map<String, dynamic>?> searchUser(String login) async {
    final token = await getValidToken();
    if (token == null) return {'error': 'Not authenticated'};

    try {
      final response = await http.get(
        Uri.parse('$apiBase/users/$login'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return {'error': 'User not found'};
      } else if (response.statusCode == 401) {
        if (await refreshToken()) {
          return await searchUser(login);
        }
        return {'error': 'Authentication failed'};
      }
    } catch (e) {
      print('API error: $e');
      return {'error': 'Network error'};
    }
    return null;
  }
}

