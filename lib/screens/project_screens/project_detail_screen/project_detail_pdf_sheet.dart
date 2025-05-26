import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ProjectDetailPdfSheet extends StatelessWidget {
  final void Function(String message) onToast;
  const ProjectDetailPdfSheet({super.key, required this.onToast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '教材生成オプション',
            style: AppTheme.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(
              Icons.school_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('学習教材PDF'),
            subtitle: const Text('チャットの内容からPDF教材を自動生成します'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              onToast('教材が生成されました！');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.quiz_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('問題集PDF'),
            subtitle: const Text('チャットの内容から問題集を自動生成します'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              onToast('問題集が生成されました！');
            },
          ),
        ],
      ),
    );
  }
}
