import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/tag.dart';
import '../services/tag_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';

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

  final TextEditingController _labelController = TextEditingController();
  String _selectedType = 'keyword';
  final Map<String, IconData> _typeIcons = {
    'keyword': Icons.label_outline,
    'emotion': Icons.emoji_emotions_outlined,
    'trait': Icons.psychology_outlined,
  };

  final Map<String, String> _typeLabels = {
    'keyword': 'キーワード',
    'emotion': '感情',
    'trait': '特徴',
  };

  final Map<String, Color> _typeColors = {
    'keyword': Colors.blue,
    'emotion': Colors.orange,
    'trait': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('タグの読み込みに失敗しました: $e')));
        setState(() => _isLoading = false);
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
    if (_tags.any((tag) => tag.label == label && tag.type == _selectedType)) {
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
        type: _selectedType,
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
      currentNavIndex: 3, // タグはナビゲーションの4番目
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTags),
      ],
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildTagInput(),
                  const Divider(height: 1),
                  Expanded(
                    child: _tags.isEmpty ? _buildEmptyState() : _buildTagList(),
                  ),
                ],
              ),
    );
  }

  Widget _buildTagInput() {
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
                    controller: _labelController,
                    decoration: InputDecoration(
                      labelText: 'タグ名',
                      hintText: '例: 数学、感動的、重要ポイント',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(
                        _typeIcons[_selectedType],
                        color: _typeColors[_selectedType],
                      ),
                    ),
                    onFieldSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('タグの種類:', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    DropdownButton<String>(
                      value: _selectedType,
                      items:
                          _typeLabels.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Row(
                                children: [
                                  Icon(
                                    _typeIcons[entry.key],
                                    color: _typeColors[entry.key],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(entry.value),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
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
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onPressed: _addTag,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tag_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'タグがありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '上部のフォームから新しいタグを追加できます',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTagList() {
    // タイプごとにタグをグループ化
    final Map<String, List<Tag>> groupedTags = {};

    for (final tag in _tags) {
      if (!groupedTags.containsKey(tag.type)) {
        groupedTags[tag.type] = [];
      }
      groupedTags[tag.type]!.add(tag);
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
                        _typeIcons[type] ?? Icons.label,
                        color: _typeColors[type] ?? Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _typeLabels[type] ?? type,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _typeColors[type] ?? Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${tags.length})',
                        style: TextStyle(
                          color:
                              _typeColors[type]?.withOpacity(0.6) ??
                              Colors.grey,
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
                        return Chip(
                          label: Text(tag.label),
                          backgroundColor:
                              _typeColors[tag.type]?.withOpacity(0.1) ??
                              Colors.grey.shade100,
                          side: BorderSide(
                            color:
                                _typeColors[tag.type]?.withOpacity(0.3) ??
                                Colors.grey.shade300,
                          ),
                          avatar: Icon(
                            _typeIcons[tag.type] ?? Icons.label,
                            color: _typeColors[tag.type] ?? Colors.grey,
                            size: 18,
                          ),
                          deleteIcon: const Icon(Icons.cancel, size: 18),
                          onDeleted: () => _deleteTag(tag),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
}
