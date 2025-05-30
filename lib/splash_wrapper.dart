import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/chat_screens/chat_screen/chat_screen.dart';
import 'services/local_cache_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'env.dart';
import 'package:uuid/uuid.dart';

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  Future<String> initializeApp() async {
    String? guestSessionId;
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      await LocalCacheService.init();
      await Hive.initFlutter();
      final box = await Hive.openBox('guest_session');
      guestSessionId = box.get('guest_session_id');
      if (guestSessionId == null) {
        guestSessionId = const Uuid().v4();
        await box.put('guest_session_id', guestSessionId);
      }
    } catch (e) {
      print('初期化失敗: $e');
      guestSessionId = const Uuid().v4();
    }
    return guestSessionId;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final chatId =
              snapshot.data?.isNotEmpty == true
                  ? snapshot.data!
                  : const Uuid().v4();
          return ChatScreen(chatId: chatId, projectId: '');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
