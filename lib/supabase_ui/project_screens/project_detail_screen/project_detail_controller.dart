import 'package:flutter/material.dart';
import '../../../app_services/services-model/chat.dart';
import '../../../app_models/project.dart';
import '../../../app_services/services/services-chat/chat_service.dart';
import '../../../app_services/services/projects/project_service.dart';
import '../../../app_services/services/cache/local_cache_service.dart';

class ProjectDetailController extends ChangeNotifier {
  final Project project;
  final ChatService chatService;
  final ProjectService projectService;

  List<Chat> chats = [];
  bool isLoading = true;
  String? errorMessage;

  ProjectDetailController({
    required this.project,
    required this.chatService,
    required this.projectService,
  });

  Future<void> loadChats() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (project.id == null) {
        throw Exception('プロジェクトIDが未設定です');
      }
      final user = await LocalCacheService.getUserInfo();
      final userId = user?['user_id'] ?? '';
      final result = await chatService.fetchChatsByProjectId(
        project.id ?? '',
        userId,
      );
      chats = result;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'チャットの読み込みに失敗しました。再試行してください。';
      notifyListeners();
    }
  }

  Future<void> deleteChat(String chatId, BuildContext context) async {
    try {
      await chatService.deleteChat(chatId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('チャットを削除しました')));
      await loadChats();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('チャットの削除に失敗しました: $e')));
    }
  }
}
