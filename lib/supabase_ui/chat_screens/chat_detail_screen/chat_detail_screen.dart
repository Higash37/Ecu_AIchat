import 'package:flutter/material.dart';
import '../../../app_services/services-model/chat.dart';
import '../../../app_widgets/sides/drawer/app_scaffold.dart';
import 'chat_detail_edit_title_dialog.dart';
import 'chat_detail_clear_dialog.dart';
import 'chat_detail_options_sheet.dart';
import 'chat_detail_content.dart';
import 'chat_detail_sidebar.dart';
import 'chat_detail_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final Chat? chat;
  final Chat? prefetchedChat;
  final Map<String, dynamic>? prefetchedUser;
  const ChatDetailScreen({
    super.key,
    required this.chatId,
    this.chat,
    this.prefetchedChat,
    this.prefetchedUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  ChatDetailController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatDetailController(
      chatId: widget.chatId,
      initialChat: widget.prefetchedChat ?? widget.chat,
    );
    _controller!.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1000;
    if (_controller == null) {
      return const Center(child: Text('エラー: チャット詳細コントローラーの初期化に失敗しました。'));
    }
    return AppScaffold(
      title:
          _controller?.isLoading == true
              ? 'チャット読み込み中...'
              : _controller?.chat?.title ?? '',
      currentNavIndex: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _controller!.reload,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
      body:
          _controller!.isLoading
              ? const Center(child: CircularProgressIndicator())
              : isWideScreen
              ? Row(
                children: [
                  Container(
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(color: Colors.grey.shade50),
                    child: const ChatDetailSidebar(),
                  ),
                  Expanded(
                    child: ChatDetailContent(
                      messages: _controller!.messages,
                      isSending: _controller!.isSending,
                      onSendPressed: _controller!.sendMessage,
                      user: _controller!.user,
                      bot: _controller!.bot,
                    ),
                  ),
                ],
              )
              : ChatDetailContent(
                messages: _controller!.messages,
                isSending: _controller!.isSending,
                onSendPressed: _controller!.sendMessage,
                user: _controller!.user,
                bot: _controller!.bot,
              ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return ChatDetailOptionsSheet(
          onEditTitle: () => _showEditTitleDialog(context),
          onSavePdf: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF生成機能は準備中です'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onClear: () => _showClearConfirmation(context),
        );
      },
    );
  }

  void _showEditTitleDialog(BuildContext context) {
    final titleController = TextEditingController(
      text: _controller?.chat?.title ?? '',
    );
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder:
          (context) => ChatDetailEditTitleDialog(
            controller: titleController,
            onUpdate: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('タイトルを入力してください'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              try {
                await _controller!.updateTitle(title);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('タイトルを更新しました')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('タイトル更新に失敗しました: $e')));
                }
              }
            },
          ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder:
          (context) => ChatDetailClearDialog(
            onClear: () async {
              Navigator.pop(context);
              try {
                await _controller!.clearMessages();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('チャット履歴を削除しました'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('チャット履歴の削除に失敗しました: $e'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
    );
  }
}
