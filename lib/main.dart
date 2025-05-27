import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'screens/chat_screens/chat_screen/chat_screen.dart';
import 'theme/app_theme.dart';
import 'env.dart'; // 環境設定クラスをインポート

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .envの読み込み（SUPABASE_URLとKEYを使うため）
  await dotenv.load(fileName: ".env");

  // Supabase初期化
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
