import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// API management class
class IntraApi {
  static const String uid = 'u-s4t2ud-e2cf8fda9cbaf28ced138deca873b4903a8853323e6b0363ced40da94e662f01';
  static const String secret = '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';
  static const String redirectUri = 'com.example.swiftcompanion://oauth2redirect';
  static const String authUrl = 'https://api.intra.42.fr/oauth/authorize';
  static const String tokenUrl = 'https://api.intra.42.fr/oauth/token';
  static const String apiBase = 'https://api.intra.42.fr/v2';

  final storage = const FlutterSecureStorage();

  // Generate authorization URL
  String getAuthorizationUrl() {
    final params = {
      'client_id': uid,
      'redirect_uri': redirectUri,
      'response_type': 'code',
    };
    return Uri.parse(authUrl).replace(queryParameters: params).toString();
  }

  // Exchange authorization code for token
  Future<bool> exchangeCodeForToken(String code) async {
    try {
      print('🔐 [Token Management] Exchanging authorization code for token...');
      print('   Request URL: $tokenUrl');
      print('   Request body: grant_type=authorization_code&client_id=$uid&client_secret=***&code=$code&redirect_uri=$redirectUri');
      
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

      print('📡 [Token Management] Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String;
        final expiresIn = data['expires_in'] as int;
        // Use created_at timestamp (if exists) or current time to calculate expiration
        final createdAt = data['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch((data['created_at'] as int) * 1000)
            : DateTime.now();
        final expiresAt = createdAt.add(Duration(seconds: expiresIn));

        await storage.write(key: 'access_token', value: accessToken);
        await storage.write(key: 'expires_at', value: expiresAt.toIso8601String());

        print('✅ [Token Management] Token obtained successfully');
        print('   Token expires in: ${expiresIn ~/ 60} minutes');
        print('   Token preview: ${accessToken.substring(0, 20)}...');
        return true;
      } else {
        print('❌ [Token Management] Token exchange failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Token Management] Token exchange error: $e');
    }
    return false;
  }

  // Note: 42 API does not support refresh token, need to re-authenticate after token expires

  // Get valid token
  // Returns null if token is expired, need to re-authenticate
  Future<String?> getValidToken() async {
    String? token = await storage.read(key: 'access_token');
    String? expiresAtStr = await storage.read(key: 'expires_at');

    if (token != null && expiresAtStr != null) {
      final expiry = DateTime.parse(expiresAtStr);
      final timeUntilExpiry = expiry.difference(DateTime.now());
      
      if (DateTime.now().isBefore(expiry.subtract(const Duration(minutes: 5)))) {
        // Token is still valid, reuse existing token
        print('✅ [Token Management] Reusing existing token');
        print('   Token expires in: ${timeUntilExpiry.inMinutes} minutes');
        print('   Token preview: ${token.substring(0, 20)}...');
        return token;
      } else {
        // Token is expiring soon or expired, need to re-authenticate
        print('⚠️ [Token Management] Token expired or expiring soon');
        print('   Time until expiry: ${timeUntilExpiry.inMinutes} minutes');
        print('   Please re-authenticate to get a new token');
        // Clear expired token
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'expires_at');
      }
    } else {
      print('⚠️ [Token Management] No token found');
    }
    return null;
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getValidToken();
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    await storage.deleteAll();
  }

  // Get current user information
  Future<Map<String, dynamic>?> getCurrentUser() async {
    print('👤 [API Call] Getting current user info...');
    final token = await getValidToken();
    if (token == null) {
      print('❌ [API Call] No valid token available');
      return null;
    }

    print('📡 [API Call] Making request with token: ${token.substring(0, 20)}...');
    try {
      final response = await http.get(
        Uri.parse('$apiBase/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('✅ [API Call] User info retrieved successfully');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ [API Call] Failed to get user info: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [API Call] Error: $e');
    }
    return null;
  }

  // Search for user
  Future<Map<String, dynamic>?> searchUser(String login) async {
    print('🔍 [API Call] Searching for user: $login');
    final token = await getValidToken();
    if (token == null) {
      print('❌ [API Call] No valid token available');
      return {'error': 'Not authenticated'};
    }

    print('📡 [API Call] Making request with token: ${token.substring(0, 20)}...');
    try {
      final response = await http.get(
        Uri.parse('$apiBase/users/$login'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('✅ [API Call] User found successfully');
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        print('⚠️ [API Call] User not found');
        return {'error': 'User not found'};
      } else if (response.statusCode == 401) {
        print('⚠️ [API Call] Token expired or invalid');
        // Clear expired token
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'expires_at');
        return {'error': 'Token expired. Please re-authenticate.'};
      }
    } catch (e) {
      print('❌ [API Call] Network error: $e');
      return {'error': 'Network error'};
    }
    return null;
  }
}

