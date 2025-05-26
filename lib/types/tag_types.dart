// types/tag_types.dart
// タグ種別のenumや型定義

enum TagType { keyword, emotion, trait }

extension TagTypeExt on TagType {
  String get label {
    switch (this) {
      case TagType.keyword:
        return 'キーワード';
      case TagType.emotion:
        return '感情';
      case TagType.trait:
        return '特徴';
    }
  }

  String get key => toString().split('.').last;
}
