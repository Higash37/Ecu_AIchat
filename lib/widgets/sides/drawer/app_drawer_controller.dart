import 'package:flutter/material.dart';
import '../../../models/chat.dart';
import '../../../services/chat_service.dart';
import '../../../services/local_cache_service.dart';

class AppDrawerController extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Chat> _recentChats = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _nickname;

  List<Chat> get recentChats => _recentChats;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get nickname => _nickname;

  AppDrawerController() {
    loadRecentChats();
    restoreLoginState();
  }

  Future<void> loadRecentChats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await LocalCacheService.getUserInfo();
      final userId = user?['user_id'] ?? '';
      final allChats = await _chatService.fetchAllChats(userId);
      await LocalCacheService.cacheChats(allChats);
      _recentChats = allChats.take(10).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      final cached = LocalCacheService.getCachedChats();
      _recentChats = cached.take(10).toList();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreLoginState() async {
    final user = await LocalCacheService.getUserInfo();
    if (user != null) {
      _isLoggedIn = true;
      _nickname = user['nickname'];
      notifyListeners();
    }
  }

  Future<void> login(String userId, String nickname) async {
    await LocalCacheService.saveUserInfo(userId, nickname);
    _isLoggedIn = true;
    _nickname = nickname;
    notifyListeners();
  }

  Future<void> logout() async {
    await LocalCacheService.clearUserInfo();
    _isLoggedIn = false;
    _nickname = null;
    notifyListeners();
  }
}
