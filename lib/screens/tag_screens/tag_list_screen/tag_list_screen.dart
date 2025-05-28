import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/tag.dart';
import '../../../services/tag_service.dart';
import '../../../widgets/sides/drawer/app_scaffold.dart';
import '../../../types/tag_types.dart';
import 'tag_list_empty.dart';
import 'tag_list_grouped.dart';
import 'tag_list_input.dart';

class TagListScreen extends StatefulWidget {
  final String projectId;
  const TagListScreen({super.key, required this.projectId});

  @override
  State<TagListScreen> createState() => _TagListScreenState();
}

class _TagListScreenState extends State<TagListScreen> {
  final TagService _tagService = TagService();
  List<Tag> _tags = [];
  bool _isLoading = true;
  String? _errorMessage; // エラー状態追加

  final TextEditingController _labelController = TextEditingController();
  TagType _selectedType = TagType.keyword;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tags = await _tagService.fetchTagsByProject(widget.projectId);

      // タグをタイプごとにソート
      tags.sort((a, b) {
        int typeComp = a.type.compareTo(b.type);
        if (typeComp != 0) return typeComp;
        return a.label.compareTo(b.label);
      });

      if (mounted) {
        setState(() {
          _tags = tags;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'タグの読み込みに失敗しました。再試行してください。';
        });
      }
    }
  }

  Future<void> _addTag() async {
    final label = _labelController.text.trim();

    if (label.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タグ名を入力してください')));
      return;
    }

    // 重複チェック
    if (_tags.any(
      (tag) => tag.label == label && tag.type == _selectedType.key,
    )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('同じタグが既に存在します')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newTag = Tag(
        id: Uuid().v4(),
        projectId: widget.projectId,
        label: label,
        type: _selectedType.key,
        createdAt: DateTime.now(),
      );

      await _tagService.createTag(newTag);
      _labelController.clear();
      await _loadTags();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('タグを追加しました')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('タグの追加に失敗しました: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTag(Tag tag) async {
    // 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('タグの削除'),
            content: Text('「${tag.label}」を削除しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('削除'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await _tagService.deleteTag(tag.id);
        await _loadTags();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('タグを削除しました')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('タグの削除に失敗しました: $e')));
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'タグ管理',
      currentNavIndex: 3,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTags),
      ],
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorState()
              : Column(
                children: [
                  TagListInput(
                    labelController: _labelController,
                    selectedType: _selectedType,
                    onTypeChanged:
                        (type) => setState(() => _selectedType = type),
                    onAddTag: _addTag,
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child:
                        _tags.isEmpty
                            ? const TagListEmpty()
                            : TagListGrouped(
                              tags: _tags,
                              onDeleteTag: _deleteTag,
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'エラーが発生しました',
            style: const TextStyle(fontSize: 16, color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadTags, child: const Text('再試行')),
        ],
      ),
    );
  }
}
