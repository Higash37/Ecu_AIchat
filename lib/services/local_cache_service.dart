import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat.dart';
import '../models/message.dart';

class LocalCacheService {
  static const String chatBoxName = 'cached_chats';
  static const String messageBoxPrefix = 'cached_messages_';

  static Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    }
    Hive.registerAdapter(ChatAdapter());
    Hive.registerAdapter(MessageAdapter());
    await Hive.openBox<Chat>(chatBoxName);
    // メッセージBoxは動的に開く
  }

  // チャット一覧キャッシュ
  static Future<void> cacheChats(List<Chat> chats) async {
    final box = Hive.box<Chat>(chatBoxName);
    await box.clear();
    for (final chat in chats) {
      await box.put(chat.id, chat);
    }
  }

  static List<Chat> getCachedChats() {
    try {
      final box = Hive.box<Chat>(chatBoxName);
      return box.values.toList();
    } catch (e) {
      print('Hive cached_chats box error: $e');
      return [];
    }
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

  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final box = await Hive.openBox(userBoxName);
      final userId = box.get(userIdKey);
      final nickname = box.get(nicknameKey);
      final isLoggedIn = box.get(loginKey, defaultValue: false);
      if (isLoggedIn == true) {
        return {'user_id': userId, 'nickname': nickname};
      }
      // 未ログイン時はbotユーザーとして返す
      return {'user_id': 'bot', 'nickname': 'bot'};
    } catch (e, st) {
      print('Hive user_info box error: $e\n$st');
      // 例外時もbotユーザーとして返す
      return {'user_id': 'bot', 'nickname': 'bot'};
    }
  }

  static Future<void> clearUserInfo() async {
    final box = await Hive.openBox(userBoxName);
    await box.clear();
  }
}
