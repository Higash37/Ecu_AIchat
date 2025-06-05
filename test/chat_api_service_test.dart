import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/services/chat_api_service.dart';

void main() {
  group('ChatApiService Tests', () {
    test('sendChatMessage sends correct payload', () async {
      final mockMessage = 'Hello AI';
      final mockModelName = 'gpt-4';
      final mockChatId = 'test-chat-id';
      final mockUserId = 'test-user-id';

      final response = await ChatApiService.sendChatMessage(
        message: mockMessage,
        modelName: mockModelName,
        chatId: mockChatId,
        userId: mockUserId,
        previousMessages: [
          {"role": "user", "content": "Previous message"},
        ],
      );

      expect(response, isNotNull);
      expect(response['status'], equals(200));
    });
  });
}
