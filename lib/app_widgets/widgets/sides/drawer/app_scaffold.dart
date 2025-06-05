import 'package:flutter/material.dart';
import '../../../../app_styles/theme/app_theme.dart';
import 'app_drawer_new.dart'; // 新しいドロワーを使用
import '../app_bottom_navigation.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentNavIndex;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showDrawer;
  final bool showBottomNav;
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentNavIndex = 0,
    this.actions,
    this.floatingActionButton,
    this.showDrawer = true,
    this.showBottomNav = false, // デフォルトでボトムナビゲーションを表示しない
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: actions,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      drawer: showDrawer ? const AppDrawerNew() : null,
      body: body,
      bottomNavigationBar:
          showBottomNav
              ? AppBottomNavigation(currentIndex: currentNavIndex)
              : null,
      floatingActionButton: floatingActionButton,
    );
  }
}
