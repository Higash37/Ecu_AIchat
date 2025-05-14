import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tag.dart';

class TagService {
  final supabase = Supabase.instance.client;

  // 指定された project に関連するタグを取得
  Future<List<Tag>> fetchTagsByProject(String projectId) async {
    final response = await supabase
        .from('tags')
        .select()
        .eq('project_id', projectId)
        .order('created_at');

    return (response as List).map((e) => Tag.fromMap(e)).toList();
  }

  // タグの追加
  Future<void> createTag(Tag tag) async {
    await supabase.from('tags').insert(tag.toMap());
  }

  // タグの削除
  Future<void> deleteTag(String tagId) async {
    await supabase.from('tags').delete().eq('id', tagId);
  }
}
