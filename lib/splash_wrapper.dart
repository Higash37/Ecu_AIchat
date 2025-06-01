import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/chat_screens/chat_screen/chat_screen.dart';
import 'services/local_cache_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'env.dart';
import 'package:uuid/uuid.dart';
import 'models/chat.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  Future<void> initializeSupabaseAndHive() async {
    await Future.wait([
      Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      ),
      LocalCacheService.init(),
    ]);
  }

  Future<void> preloadCache() async {
    await LocalCacheService.getCachedChats();
  }

  Future<void> setupFonts() async {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  Future<void> initializeApp() async {
    try {
      // 非同期処理を分離して実行
      await Future.wait([
        initializeSupabaseAndHive(),
        preloadCache(),
        setupFonts(),
      ]);

      // ゲストセッションIDの取得と保存
      final box = await Hive.openBox('guest_session');
      String? guestSessionId = box.get('guest_session_id');
      if (guestSessionId == null) {
        guestSessionId = const Uuid().v4();
        await box.put('guest_session_id', guestSessionId);
      }
      LocalCacheService.saveGuestUserInfo(guestSessionId);
    } catch (e) {
      print('初期化失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 初期化を非同期で実行しつつ、画面を即座に表示
    initializeApp();

    return FutureBuilder<List<Chat>>(
      future: LocalCacheService.getCachedChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List<Chat> cachedChats = snapshot.data ?? [];
          return ChatScreen(
            chatId:
                cachedChats.isNotEmpty
                    ? cachedChats.first.id
                    : const Uuid().v4(),
            projectId: '',
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
