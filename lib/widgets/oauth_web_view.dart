import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/services.dart';

// OAuth WebView 页面
class OAuthWebView extends StatefulWidget {
  final String authUrl;
  final String redirectUri;
  final Function(String code) onCodeReceived;

  const OAuthWebView({
    super.key,
    required this.authUrl,
    required this.redirectUri,
    required this.onCodeReceived,
  });

  @override
  State<OAuthWebView> createState() => _OAuthWebViewState();
}

class _OAuthWebViewState extends State<OAuthWebView> {
  WebViewController? _controller;  // 改为可空类型，因为初始化是异步的
  bool _isLoading = true;
  bool _codeReceived = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  // 使用平台通道清除 cookies（Android 和 iOS）
  Future<void> _clearCookies() async {
    try {
      const platform = MethodChannel('com.example.swiftcompanion/cookies');
      await platform.invokeMethod('clearCookies');
    } catch (e) {
      // 如果平台通道失败，忽略错误（可能在某些设备上不支持）
      // 在 iOS 上，这个错误不应该出现，因为我们已经实现了平台通道
      print('Platform channel not available: $e');
    }
  }

  Future<void> _initializeWebView() async {
    // 在创建 WebView 之前清除 cookies，确保每次都是全新的会话
    // 注意：在 iOS 上，清除 cookies 会同时清除缓存和本地存储
    try {
      await _clearCookies();
      print('Cookies cleared before WebView creation');
      // 给一点时间让清除操作完成
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      print('Error clearing cookies: $e');
    }

    // 创建平台特定的 WebView 配置
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = AndroidWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // 拦截回调 URL
            final uri = Uri.tryParse(request.url);
            if (uri != null) {
              final redirectUri = Uri.parse(widget.redirectUri);
              if (uri.scheme == redirectUri.scheme && uri.host == redirectUri.host) {
                _handleCallback(request.url);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            if (!_codeReceived) {
              setState(() {
                _isLoading = true;
              });
            }
            _handleCallback(url);
          },
          onPageFinished: (String url) {
            if (!_codeReceived) {
              setState(() {
                _isLoading = false;
              });
            }
            _handleCallback(url);
          },
          onWebResourceError: (WebResourceError error) {
            // 忽略深度链接的错误（这是正常的）
            if (!error.description.contains('ERR_UNKNOWN_URL_SCHEME')) {
              print('WebView error: ${error.description}');
              // 显示错误信息给用户
              if (mounted && !_codeReceived) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('加载错误: ${error.description}'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
        ),
      );

    // Android 特定配置：清除缓存和本地存储，确保私有会话
    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setMediaPlaybackRequiresUserGesture(false);
      
      // 清除缓存和本地存储（在加载 URL 之前）
      // 注意：清除操作可能会影响输入框的焦点，所以延迟清除
      try {
        // 先加载页面，再清除缓存（避免影响页面加载和输入）
        Future.delayed(const Duration(seconds: 2), () async {
          try {
            await androidController.clearCache();
            await androidController.clearLocalStorage();
            print('Cache and localStorage cleared for private session');
          } catch (e) {
            print('Error clearing cache/localStorage: $e');
          }
        });
      } catch (e) {
        print('Error setting up cache clearing: $e');
      }
    }

    // 先设置 controller，再加载 URL
    if (mounted) {
      setState(() {
        _controller = controller;
      });
    }

    // 加载 URL
    try {
      await controller.loadRequest(Uri.parse(widget.authUrl));
    } catch (e) {
      print('Error loading URL: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法加载页面: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleCallback(String url) {
    if (_codeReceived) return;

    final uri = Uri.tryParse(url);
    if (uri != null) {
      final redirectUri = Uri.parse(widget.redirectUri);
      if (uri.scheme == redirectUri.scheme && uri.host == redirectUri.host) {
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];

        if (error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login error: $error')),
            );
            Navigator.pop(context);
          }
          return;
        }

        if (code != null) {
          _codeReceived = true;
          setState(() {
            _isLoading = false;
          });
          // 延迟一下再关闭，确保状态更新
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              widget.onCodeReceived(code);
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // 清理资源
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with 42'),
      ),
      body: _controller == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}

