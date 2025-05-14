import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart' as app_models;
import '../services/message_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final MessageService _messageService = MessageService();
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'ai');
  final List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final fetched = await _messageService.fetchMessagesByChat(widget.chatId);
    setState(() {
      _messages.clear();
      _messages.addAll(
        fetched.map(
          (m) => types.TextMessage(
            author: m.sender == 'user' ? _user : _bot,
            createdAt: m.createdAt.millisecondsSinceEpoch,
            id: m.id,
            text: m.content,
          ),
        ),
      );
    });
  }

  Future<void> _onSendPressed(types.PartialText message) async {
    final uuid = const Uuid().v4();
    final now = DateTime.now();
    final userMessage = app_models.Message(
      id: uuid,
      chatId: widget.chatId,
      sender: 'user',
      content: message.text,
      createdAt: now,
    );
    await _messageService.createMessage(userMessage);

    setState(() {
      _messages.insert(
        0,
        types.TextMessage(
          author: _user,
          createdAt: now.millisecondsSinceEpoch,
          id: uuid,
          text: message.text,
        ),
      );
    });

    final replyText = await _fetchAIResponse(message.text);
    final replyId = const Uuid().v4();
    final replyTime = DateTime.now();
    final aiMessage = app_models.Message(
      id: replyId,
      chatId: widget.chatId,
      sender: 'ai',
      content: replyText,
      createdAt: replyTime,
    );
    await _messageService.createMessage(aiMessage);

    setState(() {
      _messages.insert(
        0,
        types.TextMessage(
          author: _bot,
          createdAt: replyTime.millisecondsSinceEpoch,
          id: replyId,
          text: replyText,
        ),
      );
    });
  }

  Future<String> _fetchAIResponse(String text) async {
    final uri = Uri.parse('http://127.0.0.1:8000/chat');
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
    return (json is Map && json.containsKey("reply"))
        ? json["reply"]
        : "[No reply]";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('チャット詳細')),
      body: Chat(
        messages: _messages,
        onSendPressed: _onSendPressed,
        user: _user,
      ),
    );
  }
}
