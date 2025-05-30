// tag_list_grouped.dart
// タグリスト表示Widget

import 'package:flutter/material.dart';
import '../../../models/tag.dart';
import '../../../styles/tag_styles.dart';
import '../../../types/tag_types.dart';

class TagListGrouped extends StatelessWidget {
  final List<Tag> tags;
  final void Function(Tag) onDeleteTag;
  const TagListGrouped({
    super.key,
    required this.tags,
    required this.onDeleteTag,
  });

  @override
  Widget build(BuildContext context) {
    final Map<TagType, List<Tag>> groupedTags = {};
    for (final tag in tags) {
      final type = TagType.values.firstWhere(
        (t) => t.key == tag.type,
        orElse: () => TagType.keyword,
      );
      groupedTags[type] = groupedTags[type] ?? [];
      (groupedTags[type] ?? <Tag>[]).add(tag);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children:
          groupedTags.entries.map((entry) {
            final type = entry.key;
            final tags = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        tagTypeIcons[type] ?? Icons.label,
                        color: tagTypeColors[type] ?? Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: tagTypeColors[type] ?? Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${tags.length})',
                        style: TextStyle(
                          color:
                              tagTypeColors[type] != null
                                  ? tagTypeColors[type]!.withValues(
                                    alpha: 0.6,
                                    red:
                                        tagTypeColors[type]?.red.toDouble() ??
                                        0,
                                    green:
                                        tagTypeColors[type]?.green.toDouble() ??
                                        0,
                                    blue:
                                        tagTypeColors[type]?.blue.toDouble() ??
                                        0,
                                  )
                                  : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      tags.map((tag) {
                        final tagType = TagType.values.firstWhere(
                          (t) => t.key == tag.type,
                          orElse: () => TagType.keyword,
                        );
                        return Chip(
                          label: Text(tag.label),
                          backgroundColor:
                              tagTypeColors[tagType]?.withOpacity(0.1) ??
                              Colors.grey.shade100,
                          side: BorderSide(
                            color:
                                tagTypeColors[tagType]?.withOpacity(0.3) ??
                                Colors.grey.shade300,
                          ),
                          avatar: Icon(
                            tagTypeIcons[tagType] ?? Icons.label,
                            color: tagTypeColors[tagType] ?? Colors.grey,
                            size: 18,
                          ),
                          deleteIcon: const Icon(Icons.cancel, size: 18),
                          onDeleted: () => onDeleteTag(tag),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
    );
  }
}
