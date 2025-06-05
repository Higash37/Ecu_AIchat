// tag_list_input.dart
// タグ追加用の入力フォームWidget

import 'package:flutter/material.dart';
import '../../../../app_styles/styles/tag_styles.dart';
import '../../../../app_models/types/tag_types.dart';

class TagListInput extends StatelessWidget {
  final TextEditingController labelController;
  final TagType selectedType;
  final ValueChanged<TagType> onTypeChanged;
  final VoidCallback onAddTag;

  const TagListInput({
    super.key,
    required this.labelController,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onAddTag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '新しいタグを追加',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: labelController,
                    decoration: InputDecoration(
                      labelText: 'タグ名',
                      hintText: '例: 数学、感動的、重要ポイント',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(
                        tagTypeIcons[selectedType],
                        color: tagTypeColors[selectedType],
                      ),
                    ),
                    onFieldSubmitted: (_) => onAddTag(),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('タグの種類:', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    DropdownButton<TagType>(
                      value: selectedType,
                      items:
                          TagType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                    tagTypeIcons[type],
                                    color: tagTypeColors[type],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(type.label),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onTypeChanged(value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('追加'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onPressed: onAddTag,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
