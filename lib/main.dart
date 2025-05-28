import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'screens/chat_screens/chat_screen/chat_screen.dart';
import 'theme/app_theme.dart';
import 'env.dart'; // 環境設定クラスをインポート
import 'services/local_cache_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase初期化 (String.fromEnvironmentで環境変数を取得)
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Hiveローカルキャッシュ初期化
  await LocalCacheService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // 環境設定の情報をコンソールに出力（デバッグ用）
    print('🌐 環境情報: ${AppConfig.envName}');
    print('🔗 API URL: ${AppConfig.apiBaseUrl}');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      title: 'AI 教材チャット',
      home: ChatScreen(
        chatId: const Uuid().v4(),
        projectId: '',
      ), // 新規チャット画面から開始
    );
  }
}
