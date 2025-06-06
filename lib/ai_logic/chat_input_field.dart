import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_styles/app_theme.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSendPressed;

  const ChatInputField({super.key, required this.onSendPressed});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {
      _showSendButton = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.isEmpty) {
      HapticFeedback.heavyImpact(); // 空送信時は強い振動
      return;
    }
    HapticFeedback.lightImpact(); // 送信時は軽い振動
    // フォーカスを外してキーボードを閉じる
    FocusScope.of(context).unfocus();

    widget.onSendPressed(_controller.text);
    _controller.clear();
  }

  // 添付ファイルメニュー
  Widget _buildAttachmentMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ファイルを添付',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachmentOption(
                context: context,
                icon: Icons.image_outlined,
                label: '画像',
                onTap: () {
                  Navigator.pop(context);
                  _showInfoToast(context, '画像添付機能は近日公開予定です');
                },
              ),
              _buildAttachmentOption(
                context: context,
                icon: Icons.file_present_outlined,
                label: 'ファイル',
                onTap: () {
                  Navigator.pop(context);
                  _showInfoToast(context, 'ファイル添付機能は近日公開予定です');
                },
              ),
              _buildAttachmentOption(
                context: context,
                icon: Icons.camera_alt_outlined,
                label: 'カメラ',
                onTap: () {
                  Navigator.pop(context);
                  _showInfoToast(context, 'カメラ機能は近日公開予定です');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 添付オプション項目
  Widget _buildAttachmentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 情報トースト表示
  void _showInfoToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(30),
                color: AppTheme.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppTheme.primaryColor,
              onPressed: () {
                // ファイル添付メニュー表示
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => _buildAttachmentMenu(context),
                );
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: '教材について質問する...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  suffixIcon:
                      _controller.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () {
                              _controller.clear();
                              setState(() {});
                            },
                          )
                          : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              opacity: _showSendButton ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _showSendButton ? _handleSend : null,
                  icon: const Icon(Icons.send_rounded),
                  color: Colors.white,
                  iconSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
