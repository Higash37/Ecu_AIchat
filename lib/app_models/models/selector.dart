import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_styles/theme/app_theme.dart';
import '../../supabase_ui/screens/chat_screens/chat_screen/chat_screen_controller.dart';

/// AIモデル選択ドロップダウン
class ModelSelector extends StatelessWidget {
  const ModelSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 親のStateを型で探す
    final controller = context
        .findAncestorStateOfType<State>()
        ?.getFieldByName<ChatScreenController?>('_controller');
    String selectedModel = controller?.selectedModel ?? 'gpt-4o';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedModel,
          items: [
            DropdownMenuItem(value: 'gpt-4o', child: Text('GPT-4o')),
            DropdownMenuItem(value: 'higash-ai', child: Text('Higash-AI')),
          ],
          onChanged: (value) {
            if (controller != null && value != null) {
              HapticFeedback.selectionClick(); // モデル切替時にカチッ
              controller.setModel(value);
            }
          },
          icon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
          ),
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: 4,
        ),
      ),
    );
  }
}

/// Flutter SDK内部のState拡張（リフレクション代替）
extension StateExtension on State {
  /// 指定した名前のフィールドを取得する拡張メソッド
  T? getFieldByName<T>(String name) {
    try {
      // このクラスの変数を探す
      final field = (this as dynamic)[name] as T?;
      return field;
    } catch (e) {
      print('フィールド $name の取得に失敗しました: $e');
      return null;
    }
  }
}
