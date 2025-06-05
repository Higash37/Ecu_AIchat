import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../env.dart';
import '../services/local_cache_service.dart';

/// チャットAPI通信を処理するサービス
class ChatApiService {
  /// チャットAPI通信（非ストリーミング）
  static Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    required String modelName,
    required String chatId,
    String? userId,
    List<Map<String, String>>? previousMessages,
    String mode = "normal",
    String quizType = "multiple_choice",
    String level = "中級",
    List<String>? tags,
    String layout = "quiz_card_v1",
    int count = 1,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/chat');

      // Generate user_id if not provided
      final userInfo = await LocalCacheService.getUserInfo();
      userId ??= userInfo?['user_id'];
      if (userId == null || userId.isEmpty) {
        userId = const Uuid().v4();
        await LocalCacheService.saveUserInfo(userId, 'guest');
      }

      // メッセージ履歴の構築
      final messagesList = previousMessages ?? [];
      messagesList.add({"role": "user", "content": message});

      final payload = {
        "chat_id": chatId,
        "user_id": userId,
        "messages": messagesList,
        "model": modelName,
        "mode": mode,
        "quiz_type": quizType,
        "level": level,
        "tags": tags ?? [],
        "layout": layout,
        "count": count,
      };

      debugPrint('Sending payload: $payload');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('ChatApiService: エラー発生 - $e');
      rethrow;
    }
  }

  /// ストリーミングチャットAPI通信（今後実装）
  static Stream<String> sendChatMessageStream({
    required String message,
    required String modelName,
    List<Map<String, String>>? previousMessages,
  }) async* {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/chat/stream');

      // メッセージ履歴の構築
      final messagesList = previousMessages ?? [];
      messagesList.add({"role": "user", "content": message});

      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({"messages": messagesList, "model": modelName});

      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('Stream API error: ${response.statusCode}');
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        if (chunk.contains('data: [DONE]')) break;
        if (chunk.startsWith('data: ')) {
          final data = chunk.substring(6);
          try {
            final json = jsonDecode(data);
            final token = json['token'];
            if (token != null) {
              yield token;
            }
          } catch (e) {
            // 不正なJSONはスキップ
          }
        }
      }
    } catch (e) {
      debugPrint('ChatApiService.stream: エラー発生 - $e');
      rethrow;
    }
  }
}
