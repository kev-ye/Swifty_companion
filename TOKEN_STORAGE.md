# Token 存储说明

## 📍 Token 存储位置

### 使用 FlutterSecureStorage

你的应用使用 `flutter_secure_storage` 包来安全存储 token。这个包会将数据存储在：

#### Android
- **位置**: Android KeyStore（系统加密存储）
- **路径**: 由系统管理，应用无法直接访问
- **安全性**: 使用硬件支持的加密（如果设备支持）

#### iOS
- **位置**: iOS Keychain（系统钥匙串）
- **路径**: 由系统管理，应用无法直接访问
- **安全性**: 使用系统级加密

### 存储的数据

应用存储了以下三个值：

1. **access_token**: 访问令牌（用于 API 调用）
2. **refresh_token**: 刷新令牌（用于获取新的 access_token）
3. **expires_at**: 过期时间（ISO 8601 格式字符串）

### 代码位置

```dart
// 在 IntraApi 类中
final storage = const FlutterSecureStorage();

// 保存 token
await storage.write(key: 'access_token', value: accessToken);
await storage.write(key: 'refresh_token', value: refreshToken);
await storage.write(key: 'expires_at', value: expiresAt.toIso8601String());

// 读取 token
String? token = await storage.read(key: 'access_token');

// 清除所有数据（登出时）
await storage.deleteAll();
```

---

## 🔧 修复的问题

### 问题 1: 登出时显示 "login error"

**原因**: 
- 深度链接监听器在登出后可能捕获到错误的 URL
- 没有正确处理 OAuth 错误响应

**修复**:
- 在 `_handleDeepLink()` 中添加了错误参数检查
- 如果 URL 中包含 `error` 参数，会显示具体的错误信息

### 问题 2: 登出后重新登录不需要重新验证

**原因**:
- OAuth 流程中，如果浏览器还保存了 42 的登录 session，会直接重定向
- 没有强制用户重新输入密码

**修复**:
1. 在 `getAuthorizationUrl()` 中添加了 `prompt=login` 参数支持
2. `LoginView` 添加了 `forceLogin` 参数
3. 登出时，跳转到登录页并设置 `forceLogin=true`
4. 当 `forceLogin=true` 时，OAuth URL 会包含 `prompt=login` 参数，强制 42 服务器要求用户重新登录

### 代码改动

```dart
// 1. 生成 OAuth URL 时支持强制登录
String getAuthorizationUrl({bool forceLogin = false}) {
  final params = {...};
  if (forceLogin) {
    params['prompt'] = 'login';  // 强制重新登录
  }
  return Uri.parse(authUrl).replace(queryParameters: params).toString();
}

// 2. LoginView 支持强制登录参数
class LoginView extends StatefulWidget {
  final bool forceLogin;
  const LoginView({super.key, this.forceLogin = false});
  // ...
}

// 3. 登出时传递 forceLogin=true
void _logout() async {
  await _api.logout();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginView(forceLogin: true),
    ),
  );
}
```

---

## 🧪 测试建议

1. **测试登出功能**:
   - 登录后点击登出
   - 应该不会显示 "login error"
   - 应该直接跳转到登录页

2. **测试强制重新登录**:
   - 登录后点击登出
   - 重新点击登录按钮
   - 应该会要求你重新输入 42 的密码（即使浏览器还保存了 session）

3. **测试正常登录**:
   - 首次打开应用
   - 点击登录
   - 应该正常显示 42 登录页面

---

## 📝 注意事项

1. **Token 安全性**: 
   - Token 存储在系统加密存储中，相对安全
   - 但不要在代码中硬编码 secret（你的代码中已经有了，这是正常的 OAuth 配置）

2. **Token 刷新**:
   - 应用会自动刷新即将过期的 token
   - 如果 refresh_token 也过期了，需要重新登录

3. **清除数据**:
   - 卸载应用会清除所有存储的数据
   - 登出只会清除应用存储，不会清除浏览器的 42 session

