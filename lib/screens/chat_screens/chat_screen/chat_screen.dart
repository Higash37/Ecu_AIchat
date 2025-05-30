import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/sides/drawer/app_scaffold.dart';
import '../../../widgets/chat/chat_input_field.dart';
import 'chat_screen_controller.dart';
import '../../../models/selector.dart';
import 'message_list.dart';
import 'chat_options_menu.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String projectId;
  const ChatScreen({super.key, required this.chatId, required this.projectId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatScreenController? _controller;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    if (widget.chatId.isNotEmpty) {
      _controller = ChatScreenController(
        chatId: widget.chatId,
        projectId: widget.projectId,
      );
      _initFuture = _controller!.init();
      _controller!.addListener(_onControllerChanged);
    } else {
      // chatIdが空の場合のフォールバック処理
      print('警告: chatIdが空です。新しいIDを生成します。');
      final fallbackId = const Uuid().v4();
      _controller = ChatScreenController(
        chatId: fallbackId,
        projectId: widget.projectId,
      );
      _initFuture = _controller!.init();
      _controller!.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '新規チャット',
      currentNavIndex: 2,
      actions: [
        // --- モデル切り替えドロップダウンを追加 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(height: 36, child: const ModelSelector()),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            ChatOptionsMenu.showOptionsMenu(context, _controller);
          },
        ),
      ],
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          // --- 極限まで高速表示: 履歴ロード中もUI即表示・入力即可能 ---
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          // コントローラーがnullの場合にフォールバック
          if (_controller == null) {
            return const Center(child: Text('エラー: チャットコントローラーの初期化に失敗しました。'));
          }

          return Column(
            children: [
              Expanded(
                child: Container(
                  color: AppTheme.backgroundColor,
                  child: MessageList(
                    controller: _controller,
                    isLoading: isLoading,
                  ),
                ),
              ),
              // --- 入力欄は常に即表示・即入力可能 ---
              ChatInputField(
                onSendPressed:
                    (msg) => _controller?.onSendPressed(context, msg),
              ),
            ],
          );
        },
      ),
    );
  }
}
