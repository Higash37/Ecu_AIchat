import 'package:flutter/material.dart';
import '../../app_styles/theme/app_theme.dart';

/// トースト通知ユーティリティクラス
class ToastUtil {
  /// 成功メッセージを表示
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Colors.green.shade600, Icons.check_circle);
  }

  /// 情報メッセージを表示
  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, AppTheme.primaryColor, Icons.info_outline);
  }

  /// 警告メッセージを表示
  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message,
      Colors.orange.shade600,
      Icons.warning_amber_rounded,
    );
  }

  /// エラーメッセージを表示
  static void showError(BuildContext context, String message) {
    _showToast(context, message, Colors.red.shade600, Icons.error_outline);
  }

  /// 開発中機能メッセージを表示
  static void showComingSoon(BuildContext context, String message) {
    _showToast(
      context,
      message,
      const Color(0xFF6C63FF).withOpacity(0.9),
      Icons.update,
    );
  }

  /// ベースとなるトースト表示処理
  static void _showToast(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
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
                color: backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
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
}
