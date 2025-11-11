import 'package:flutter/material.dart';
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
