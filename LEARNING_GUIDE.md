# Flutter 学习指南 - 42 Swift Companion

## 📚 目录
1. [Flutter 基础概念](#flutter-基础概念)
2. [代码结构解析](#代码结构解析)
3. [关键语法说明](#关键语法说明)
4. [OAuth 流程详解](#oauth-流程详解)
5. [常见问题](#常见问题)

---

## Flutter 基础概念

### 1. Widget（组件）
Flutter 中一切都是 Widget（组件）：
- **StatelessWidget**: 无状态组件，数据不会改变
- **StatefulWidget**: 有状态组件，可以更新数据并刷新 UI

```dart
// 无状态组件示例
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}

// 有状态组件示例
class MyCounter extends StatefulWidget {
  @override
  State<MyCounter> createState() => _MyCounterState();
}

class _MyCounterState extends State<MyCounter> {
  int count = 0;
  
  @override
  Widget build(BuildContext context) {
    return Text('Count: $count');
  }
}
```

### 2. Build 方法
`build` 方法用于构建 UI，Flutter 会自动调用它来渲染界面。

### 3. setState
当需要更新 UI 时，调用 `setState`：
```dart
setState(() {
  count = count + 1;  // 更新数据
  // Flutter 会自动重新调用 build 方法
});
```

---

## 代码结构解析

### 1. 应用入口 (`main` 函数)
```dart
void main() {
  runApp(const SwiftCompanionApp());
}
```
- `main()`: 程序入口点
- `runApp()`: 启动 Flutter 应用

### 2. 应用根组件 (`SwiftCompanionApp`)
```dart
class SwiftCompanionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginView(),  // 启动时显示登录页
    );
  }
}
```
- `MaterialApp`: Material Design 风格的应用容器
- `home`: 应用启动时显示的页面

### 3. API 管理类 (`IntraApi`)
这个类负责：
- OAuth 认证流程
- Token 管理（保存、刷新、验证）
- API 调用（获取用户信息、搜索用户）

**关键方法：**
- `getAuthorizationUrl()`: 生成 OAuth 授权 URL
- `exchangeCodeForToken()`: 用授权码换取 token
- `getValidToken()`: 获取有效的 token（自动刷新过期 token）

### 4. 登录页面 (`LoginView`)
**生命周期：**
1. `initState()`: 初始化时检查登录状态，设置深度链接监听
2. `build()`: 构建 UI
3. `dispose()`: 清理资源（取消监听）

**关键流程：**
```
用户点击登录按钮
  ↓
_startLogin() 尝试打开浏览器
  ↓
用户登录后，浏览器重定向到 app://oauth2redirect?code=xxx
  ↓
深度链接监听捕获 URL
  ↓
_handleDeepLink() 提取授权码
  ↓
exchangeCodeForToken() 换取 token
  ↓
跳转到搜索页面
```

### 5. 搜索页面 (`SearchView`)
- 显示当前登录用户
- 搜索其他用户
- 登出功能

### 6. 用户详情页面 (`UserDetailView`)
- 显示用户基本信息
- 显示技能列表
- 显示项目列表

---

## 关键语法说明

### 1. 异步编程 (async/await)
```dart
// async: 标记函数为异步
Future<String> fetchData() async {
  // await: 等待异步操作完成
  final response = await http.get(url);
  return response.body;
}
```

**为什么需要异步？**
- 网络请求、文件读写等操作需要时间
- 使用异步可以避免阻塞 UI 线程

### 2. Future 和 async/await
```dart
// Future: 表示一个未来会完成的操作
Future<bool> login() async {
  await someAsyncOperation();  // 等待完成
  return true;
}

// 使用
login().then((result) {
  print(result);
});
```

### 3. 可空类型 (Nullable Types)
```dart
String? name;  // ? 表示可能为 null

if (name != null) {
  print(name.length);  // 使用前检查
}

// 空值合并运算符
String displayName = name ?? 'Unknown';
```

### 4. 类型转换 (Type Casting)
```dart
// as: 类型转换
final data = json.decode(response.body) as Map<String, dynamic>;

// ?? 和 ??=: 空值合并
final value = data['key'] ?? 'default';
```

### 5. 扩展运算符 (...)
```dart
List<int> list1 = [1, 2, 3];
List<int> list2 = [4, 5, ...list1];  // [4, 5, 1, 2, 3]

// 在 Widget 中使用
Column(
  children: [
    Text('A'),
    ...items.map((item) => Text(item)),  // 展开列表
  ],
)
```

### 6. 条件渲染
```dart
// 三元运算符
child: isLoading ? CircularProgressIndicator() : Text('Done')

// if 语句（在列表中使用）
Column(
  children: [
    if (isLoggedIn) Text('Welcome'),
    if (hasError) Text('Error'),
  ],
)
```

### 7. 级联运算符 (..)
```dart
// 连续调用同一个对象的方法
_controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(...)
  ..loadRequest(Uri.parse(url));

// 等价于
_controller = WebViewController();
_controller.setJavaScriptMode(JavaScriptMode.unrestricted);
_controller.setNavigationDelegate(...);
_controller.loadRequest(Uri.parse(url));
```

### 8. 可选参数
```dart
// 命名参数（用 {}）
void showDialog({String? title, String? message}) {
  // ...
}
showDialog(title: 'Hello', message: 'World');

// 位置参数（用 []）
void showDialog(String title, [String? message]) {
  // ...
}
showDialog('Hello', 'World');
```

---

## OAuth 流程详解

### OAuth 2.0 授权码流程

```
1. 用户点击"登录"按钮
   ↓
2. 应用生成授权 URL 并打开浏览器
   URL: https://api.intra.42.fr/oauth/authorize?
        client_id=xxx&
        redirect_uri=com.example.swiftcompanion://oauth2redirect&
        response_type=code
   ↓
3. 用户在浏览器中登录 42 账号
   ↓
4. 42 服务器重定向到 redirect_uri，带上授权码
   URL: com.example.swiftcompanion://oauth2redirect?code=ABC123
   ↓
5. 应用通过深度链接捕获这个 URL
   ↓
6. 应用提取授权码，发送到服务器换取 token
   POST https://api.intra.42.fr/oauth/token
   Body: {
     grant_type: 'authorization_code',
     code: 'ABC123',
     client_id: 'xxx',
     client_secret: 'xxx'
   }
   ↓
7. 服务器返回 access_token 和 refresh_token
   ↓
8. 应用保存 token，完成登录
```

### 为什么需要深度链接？
- 浏览器重定向到 `com.example.swiftcompanion://oauth2redirect`
- 系统会打开我们的应用（而不是浏览器）
- 应用通过 `app_links` 包监听这个 URL

### Token 刷新机制
```dart
// 检查 token 是否即将过期（5分钟内）
if (DateTime.now().isBefore(expiry.subtract(Duration(minutes: 5)))) {
  return token;  // 还有效
} else {
  // 即将过期，自动刷新
  await refreshToken();
}
```

---

## 常见问题

### Q1: 为什么使用 StatefulWidget？
**A:** 当组件需要保存和更新状态时（如加载状态、用户输入），使用 StatefulWidget。

### Q2: mounted 是什么？
**A:** `mounted` 检查组件是否还在 Widget 树中。在异步操作后使用，避免在已销毁的组件上调用 `setState`。

```dart
Future<void> loadData() async {
  final data = await fetchData();
  if (mounted) {  // 检查组件是否还存在
    setState(() {
      // 更新状态
    });
  }
}
```

### Q3: 为什么需要 dispose？
**A:** 释放资源，避免内存泄漏：
- 取消网络请求
- 取消监听器
- 释放控制器

### Q4: const 的作用？
**A:** `const` 表示编译时常量，可以：
- 提高性能（避免重复创建）
- 确保值不变

```dart
const Text('Hello');  // 编译时创建，可复用
Text('Hello');        // 每次调用都创建新对象
```

### Q5: late 关键字？
**A:** `late` 表示延迟初始化，告诉 Dart 这个变量在使用前会被赋值：

```dart
late String name;  // 声明时不赋值

void init() {
  name = 'John';  // 使用前必须赋值
}
```

### Q6: 为什么提取方法？
**A:** 让代码更清晰、可维护：
- `_buildLoginContent()`: 分离 UI 构建逻辑
- `_handleLoginSuccess()`: 避免代码重复
- `_openWebView()`: 提高可读性

---

## 学习建议

1. **理解 Widget 树**: Flutter 的 UI 是 Widget 树结构
2. **掌握异步编程**: async/await 是 Flutter 的核心
3. **熟悉常用 Widget**: Column, Row, Container, Text, Button 等
4. **理解状态管理**: setState 如何更新 UI
5. **实践**: 修改代码，观察效果

---

## 下一步学习

- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 语言教程](https://dart.dev/guides)
- [Flutter Widget 目录](https://flutter.dev/docs/development/ui/widgets)

