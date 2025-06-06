import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../services-model/chat.dart';
import '../services-model/message.dart';

class LocalCacheService {
  static const String chatBoxName = 'cached_chats';
  static const String messageBoxPrefix = 'cached_messages_';

  static Future<void> init() async {
    // Hiveの初期化は1回だけ行う
    if (!Hive.isBoxOpen(chatBoxName)) {
      if (kIsWeb) {
        await Hive.initFlutter();
      } else {
        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
      }

      // アダプターの登録
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ChatAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(MessageAdapter());
      }

      // Boxの初期化
      await Hive.openBox<Chat>(chatBoxName);
    }
  }

  // チャット一覧キャッシュ
  static Future<void> cacheChats(List<Chat> chats) async {
    final box = Hive.box<Chat>(chatBoxName);
    await box.clear();
    for (final chat in chats) {
      await box.put(chat.id, chat);
    }
  }

  static List<Chat>? _cachedChats;

  static Future<List<Chat>> getCachedChats() async {
    if (_cachedChats != null) {
      return _cachedChats!;
    }
    try {
      final box = await Hive.openBox<Chat>(chatBoxName);
      _cachedChats = box.values.toList();
      return _cachedChats!;
    } catch (e) {
      print('Hive cached_chats box error: $e');
      return [];
    }
  }

  static void clearCachedChats() {
    _cachedChats = null;
  }

  // チャットごとのメッセージキャッシュ
  static Future<void> cacheMessages(
    String chatId,
    List<Message> messages,
  ) async {
    final box = await Hive.openBox<Message>(messageBoxPrefix + chatId);
    await box.clear();
    for (final msg in messages) {
      await box.put(msg.id, msg);
    }
  }

  static Future<List<Message>> getCachedMessages(String chatId) async {
    try {
      final box = await Hive.openBox<Message>(messageBoxPrefix + chatId);
      return box.values.toList();
    } catch (e) {
      print('Hive message box error: $e');
      // 例外時は空リスト返却
      return [];
    }
  }

  // --- ユーザー情報の永続化 ---
  static const String userBoxName = 'user_info';
  static const String userIdKey = 'user_id';
  static const String nicknameKey = 'nickname';
  static const String loginKey = 'is_logged_in';

  static Future<void> saveUserInfo(String userId, String nickname) async {
    final box = await Hive.openBox(userBoxName);
    await box.put(userIdKey, userId);
    await box.put(nicknameKey, nickname);
    await box.put(loginKey, true);
  }

  static Future<void> saveGuestUserInfo(String userId) async {
    final box = await Hive.openBox(userBoxName);
    await box.put(userIdKey, userId);
    await box.put('is_guest', true);
    await box.put(loginKey, false);
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final box = await Hive.openBox(userBoxName);
      final userId = box.get(userIdKey);
      final nickname = box.get(nicknameKey);
      final isLoggedIn = box.get(loginKey, defaultValue: false);
      final isGuest = box.get('is_guest', defaultValue: false);
      if (isLoggedIn == true) {
        return {'user_id': userId, 'nickname': nickname};
      } else if (isGuest == true && userId != null) {
        return {'user_id': userId, 'is_guest': true};
      }
      // 未ログイン・未ゲスト時はbot
      return {'user_id': 'bot', 'nickname': 'bot'};
    } catch (e, st) {
      print('Hive user_info box error: $e\n$st');
      return {'user_id': 'bot', 'nickname': 'bot'};
    }
  }

  static Future<void> clearUserInfo() async {
    final box = await Hive.openBox(userBoxName);
    await box.clear();
  }

  static Future<void> setUserInfo(Map<String, dynamic> info) async {
    final box = await Hive.openBox(userBoxName);
    info.forEach((key, value) => box.put(key, value));
  }
}
