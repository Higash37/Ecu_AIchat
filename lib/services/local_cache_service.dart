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
    final box = Hive.box<Chat>(chatBoxName);
    return box.values.toList();
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
    final box = await Hive.openBox<Message>(messageBoxPrefix + chatId);
    return box.values.toList();
  }
}
