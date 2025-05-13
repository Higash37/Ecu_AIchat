import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'ai');

  void _onSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
    );
    setState(() {
      _messages.insert(0, textMessage);
    });

    final aiReply = await _fetchAIResponse(message.text);

    final aiMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: aiReply,
    );
    setState(() {
      _messages.insert(0, aiMessage);
    });
  }

  Future<String> _fetchAIResponse(String text) async {
    final uri = Uri.parse('http://127.0.0.1:8000/chat'); // ✅ ←ここに変更！

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "messages": [
          {"role": "user", "content": text},
        ],
      }),
    );

    final json = jsonDecode(response.body);
    final reply =
        (json is Map && json.containsKey("reply"))
            ? json["reply"]
            : "[No reply]";

    return reply; // ← ✅ ここが必要！
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        messages: _messages,
        onSendPressed: _onSendPressed,
        user: _user,
      ),
    );
  }
}
