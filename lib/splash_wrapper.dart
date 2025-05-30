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
      // Supabase等の初期化は失敗しても致命的にしない
      try {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        );
      } catch (e) {
        print('Supabase初期化失敗: $e');
      }
      try {
        await LocalCacheService.init();
      } catch (e) {
        print('LocalCacheService初期化失敗: $e');
      }
      try {
        await Hive.initFlutter();
      } catch (e) {
        print('Hive初期化失敗: $e');
      }
      try {
        final box = await Hive.openBox('guest_session');
        guestSessionId = box.get('guest_session_id');
        if (guestSessionId == null) {
          guestSessionId = const Uuid().v4();
          await box.put('guest_session_id', guestSessionId);
        }
      } catch (e) {
        print('ゲストID生成用box初期化失敗: $e');
        // boxが開けない場合もUUIDだけ生成
        guestSessionId = const Uuid().v4();
      }
    } catch (e) {
      print('initializeApp全体で例外: $e');
      guestSessionId = const Uuid().v4();
    }
    return guestSessionId;
  }

  @override
  Widget build(BuildContext context) {
    // まずUIを即時表示し、裏で初期化・接続を進める
    return ChatScreen(chatId: '', projectId: '');
  }
}
