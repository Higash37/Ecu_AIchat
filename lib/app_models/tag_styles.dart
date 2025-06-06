// styles/tag_styles.dart
// タグ種別ごとの色・アイコン定義

import 'package:flutter/material.dart';
import 'tag_types.dart';

const Map<TagType, Color> tagTypeColors = {
  TagType.keyword: Colors.blue,
  TagType.emotion: Colors.orange,
  TagType.trait: Colors.purple,
};

const Map<TagType, IconData> tagTypeIcons = {
  TagType.keyword: Icons.label_outline,
  TagType.emotion: Icons.emoji_emotions_outlined,
  TagType.trait: Icons.psychology_outlined,
};
