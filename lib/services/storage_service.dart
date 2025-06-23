import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_tracker/models/project_model.dart';

class StorageService {
  static const String projectsBoxName = 'projects';
  static late Box<Project> _projectsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(ProjectStatusAdapter());
    Hive.registerAdapter(StatusChangeAdapter());

    // Open boxes
    _projectsBox = await Hive.openBox<Project>(projectsBoxName);
  }

  static Box<Project> get projectsBox => _projectsBox;

  // Project operations
  static Future<void> saveProject(Project project) async {
    await project.save();
  }

  static Future<void> deleteProject(String id) async {
    final project = _projectsBox.values.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Project not found'),
    );
    await project.delete();
  }

  static List<Project> getAllProjects() {
    return _projectsBox.values.toList();
  }

  static Project? getProject(String id) {
    try {
      return _projectsBox.values.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearAllProjects() async {
    await _projectsBox.clear();
  }
}
