import 'package:flutter/material.dart';
import '../../../models/chat.dart';
import '../../../services/chat_service.dart';
import '../../../services/local_cache_service.dart';

/// ChatListScreenのロジック・状態管理用コントローラー
class ChatListController extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Chat> chats = [];
  bool isLoading = true;
  String projectTitle = '';
  final String? projectId;

  ChatListController({this.projectId});

  Future<void> loadChats(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      List<Chat> loadedChats;
      if (projectId != null) {
        loadedChats = await _chatService.fetchChatsByProject(projectId!);
        projectTitle = 'プロジェクト内チャット';
      } else {
        loadedChats = await _chatService.fetchAllChats();
        projectTitle = 'すべてのチャット';
      }
      // 通信成功時はキャッシュ保存
      await LocalCacheService.cacheChats(loadedChats);
      loadedChats.sort((a, b) {
        final DateTime dateA = a.updatedAt ?? a.createdAt;
        final DateTime dateB = b.updatedAt ?? b.createdAt;
        return dateB.compareTo(dateA);
      });
      chats = loadedChats;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      // 通信失敗時はキャッシュから取得
      final cached = LocalCacheService.getCachedChats();
      if (cached.isNotEmpty) {
        chats = cached;
        isLoading = false;
        notifyListeners();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('オフラインキャッシュから表示しています')));
        }
      } else {
        isLoading = false;
        notifyListeners();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('チャットの読み込みに失敗しました: $e')));
        }
      }
    }
  }

  Future<Chat?> createChat(BuildContext context, String title) async {
    if (projectId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('プロジェクトを選択してください')));
      }
      return null;
    }
    try {
      final newChat = Chat(
        id: '', // サーバー側でID生成される場合は空文字
        projectId: projectId!,
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastMessage: '',
        messageCount: 0,
      );
      final createdChat = await _chatService.createChat(newChat);
      await loadChats(context);
      return createdChat;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('チャットの作成に失敗しました: $e')));
      }
      return null;
    }
  }

  Future<void> deleteChat(BuildContext context, String chatId) async {
    try {
      await _chatService.deleteChat(chatId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('チャットを削除しました')));
      }
      await loadChats(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('チャットの削除に失敗しました: $e')));
      }
    }
  }
}
