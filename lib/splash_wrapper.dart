import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/common/splash_screen.dart';
import 'screens/chat_screens/chat_screen/chat_screen.dart';
import 'services/local_cache_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'env.dart';
import 'package:uuid/uuid.dart';

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  Future<String> initializeApp() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    await LocalCacheService.init();
    await Hive.initFlutter();
    final box = await Hive.openBox('guest_session');
    String? guestSessionId = box.get('guest_session_id');
    if (guestSessionId == null) {
      guestSessionId = const Uuid().v4();
      await box.put('guest_session_id', guestSessionId);
    }
    return guestSessionId;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ChatScreen(chatId: snapshot.data!, projectId: '');
          } else {
            // エラーハンドリング: 有効なIDが取得できなかった場合は新しいIDを生成
            final fallbackId = const Uuid().v4();
            print('警告: ゲストセッションIDが取得できませんでした。代替ID生成: $fallbackId');
            return ChatScreen(chatId: fallbackId, projectId: '');
          }
        } else {
          return const SplashScreen();
        }
      },
    );
  }
}
