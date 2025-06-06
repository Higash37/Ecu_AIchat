import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../../env.dart';

/// チャットAPI通信を処理するサービス
class ChatApiService {
  /// チャットAPI通信（非ストリーミング）
  static Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    required String modelName,
    List<Map<String, String>>? previousMessages,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/chat');

      // メッセージ履歴の構築
      final messagesList = previousMessages ?? [];
      messagesList.add({"role": "user", "content": message});

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"messages": messagesList, "model": modelName}),
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
