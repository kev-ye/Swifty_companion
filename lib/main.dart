import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // 暂时不使用，等之后再用
import 'screens/login_view.dart';

void main() {
  runApp(const SwiftCompanionApp());
}

class SwiftCompanionApp extends StatelessWidget {
  const SwiftCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '42 Swift Companion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}
