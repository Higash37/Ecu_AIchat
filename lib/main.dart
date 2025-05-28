import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'screens/chat_screens/chat_screen/chat_screen.dart';
import 'theme/app_theme.dart';
import 'env.dart'; // 環境設定クラスをインポート
import 'services/local_cache_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    // Supabase/LocalCacheServiceの初期化をUI表示後に遅延実行
    await Future.wait([
      Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      ),
      LocalCacheService.init(),
    ]);
    // 必要なら今後Provider等でグローバル管理
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      title: 'AI 教材チャット',
      home: ChatScreen(chatId: const Uuid().v4(), projectId: ''),
    );
  }
}
