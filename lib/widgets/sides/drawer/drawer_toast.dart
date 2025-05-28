import 'package:flutter/material.dart';

/// Drawer用の「開発中」トースト表示ユーティリティ
void showComingSoonToast(BuildContext context, String message) {
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
              color: const Color(0xFF6C63FF).withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.update, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
