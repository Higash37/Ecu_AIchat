import 'package:flutter/material.dart';
import 'splash_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansJP', // 日本語フォントをデフォルトに設定
      ),
      home: const SplashWrapper(),
    );
  }
}
