import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../services/tag_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await _tagService.fetchTagsByProject(widget.projectId);
    setState(() {
      _tags = tags;
      _isLoading = false;
    });
  }

  Future<void> _addTag() async {
    final newTag = Tag(
      id: '',
      projectId: widget.projectId,
      label: _labelController.text,
      type: _selectedType,
      createdAt: DateTime.now(),
    );
    await _tagService.createTag(newTag);
    _labelController.clear();
    await _loadTags();
  }

  Future<void> _deleteTag(String tagId) async {
    await _tagService.deleteTag(tagId);
    await _loadTags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タグ一覧')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _labelController,
                            decoration: const InputDecoration(
                              labelText: 'タグ名を入力',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _selectedType,
                          items: const [
                            DropdownMenuItem(
                              value: 'emotion',
                              child: Text('感情'),
                            ),
                            DropdownMenuItem(
                              value: 'keyword',
                              child: Text('キーワード'),
                            ),
                            DropdownMenuItem(value: 'trait', child: Text('特徴')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _tags.length,
                      itemBuilder: (context, index) {
                        final tag = _tags[index];
                        return ListTile(
                          title: Text(tag.label),
                          subtitle: Text('種類: ${tag.type}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTag(tag.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
