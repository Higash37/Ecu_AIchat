import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'screens/chat_screens/chat_screen/chat_screen.dart';
import 'theme/app_theme.dart';
import 'env.dart'; // 環境設定クラスをインポート
import 'services/local_cache_service.dart';
import 'widgets/common/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SplashScreenApp());
}

class SplashScreenApp extends StatefulWidget {
  const SplashScreenApp({super.key});
  @override
  State<SplashScreenApp> createState() => _SplashScreenAppState();
}

class _SplashScreenAppState extends State<SplashScreenApp> {
  bool _initialized = false;
  List<dynamic>? _prefetchedChats;
  Map<String, dynamic>? _prefetchedUser;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    // Supabase/Hive初期化を並列化
    await Future.wait([
      Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      ),
      LocalCacheService.init(),
    ]);
    // キャッシュ先読み（チャット一覧・ユーザー情報）
    final chats = LocalCacheService.getCachedChats();
    final user = await LocalCacheService.getUserInfo();
    setState(() {
      _initialized = true;
      _prefetchedChats = chats;
      _prefetchedUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }
    return MyApp(
      prefetchedChats: _prefetchedChats,
      prefetchedUser: _prefetchedUser,
    );
  }
}

class MyApp extends StatelessWidget {
  final List<dynamic>? prefetchedChats;
  final Map<String, dynamic>? prefetchedUser;
  const MyApp({super.key, this.prefetchedChats, this.prefetchedUser});
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
        // 必要に応じてprefetchedChats, prefetchedUserを渡す
      ),
      // チャット一覧画面にプリフェッチを渡す例:
      // home: ChatListScreen(
      //   prefetchedChats: prefetchedChats?.cast<Chat>(),
      //   prefetchedUser: prefetchedUser,
      // ),
    );
  }
}
