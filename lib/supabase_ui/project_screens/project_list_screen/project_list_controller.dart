import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../app_models/project.dart';
import '../../../app_services/services/projects/project_service.dart';

class ProjectListController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProjects({List<Project>? prefetched}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (prefetched != null && prefetched.isNotEmpty) {
        _projects = prefetched;
      } else {
        _projects = await _projectService.fetchProjects();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'プロジェクトの読み込みに失敗しました。再試行してください。';
      notifyListeners();
    }
  }

  Future<bool> createProject(String name, String? description) async {
    final project = Project(
      id: Uuid().v4(),
      name: name,
      description:
          (description != null && description.trim().isNotEmpty)
              ? description.trim()
              : null,
      createdAt: DateTime.now(),
    );
    try {
      await _projectService.createProject(project);
      await loadProjects();
      return true;
    } catch (e) {
      _errorMessage = 'プロジェクトの作成に失敗しました: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
