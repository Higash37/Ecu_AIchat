import 'package:flutter/material.dart';

/// Drawerの汎用メニューアイテム用Widget
class DrawerMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool isPrimary;
  const DrawerMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.isDisabled = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: isPrimary ? 20 : 16,
                  color: isPrimary ? const Color(0xFF6C63FF) : Colors.grey[800],
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isPrimary ? 15 : 14,
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                    color: isPrimary ? const Color(0xFF6C63FF) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
