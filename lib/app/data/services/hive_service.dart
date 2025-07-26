import 'package:hive_flutter/hive_flutter.dart';
import '../models/idea.dart';
import '../models/project.dart';
import '../models/task.dart';

class HiveService {
  static const String _ideasBoxName = 'ideas';
  static const String _projectsBoxName = 'projects';
  static const String _tasksBoxName = 'tasks';
  static const String _settingsBoxName = 'settings';

  static late Box<Idea> _ideasBox;
  static late Box<Project> _projectsBox;
  static late Box<Task> _tasksBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(IdeaAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(IdeaPriorityAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(IdeaStatusAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ProjectAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ProjectStatusAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(TaskAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(TaskStatusAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(TaskPriorityAdapter());
    
    // Open boxes
    _ideasBox = await Hive.openBox<Idea>(_ideasBoxName);
    _projectsBox = await Hive.openBox<Project>(_projectsBoxName);
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Ideas CRUD operations
  static Future<void> saveIdea(Idea idea) async {
    await _ideasBox.put(idea.id, idea);
  }

  static Idea? getIdea(String id) {
    return _ideasBox.get(id);
  }

  static List<Idea> getAllIdeas() {
    return _ideasBox.values.toList();
  }

  static Future<void> deleteIdea(String id) async {
    await _ideasBox.delete(id);
  }

  static Future<void> updateIdea(Idea idea) async {
    idea.updatedAt = DateTime.now();
    await _ideasBox.put(idea.id, idea);
  }

  // Projects CRUD operations
  static Future<void> saveProject(Project project) async {
    await _projectsBox.put(project.id, project);
  }

  static Project? getProject(String id) {
    return _projectsBox.get(id);
  }

  static List<Project> getAllProjects() {
    return _projectsBox.values.toList();
  }

  static Future<void> deleteProject(String id) async {
    // Also delete all tasks associated with this project
    final tasks = getTasksForProject(id);
    for (final task in tasks) {
      await deleteTask(task.id);
    }
    await _projectsBox.delete(id);
  }

  static Future<void> updateProject(Project project) async {
    project.updatedAt = DateTime.now();
    await _projectsBox.put(project.id, project);
  }

  // Tasks CRUD operations
  static Future<void> saveTask(Task task) async {
    await _tasksBox.put(task.id, task);
  }

  static Task? getTask(String id) {
    return _tasksBox.get(id);
  }

  static List<Task> getAllTasks() {
    return _tasksBox.values.toList();
  }

  static List<Task> getTasksForProject(String projectId) {
    return _tasksBox.values.where((task) => task.projectId == projectId).toList();
  }

  static Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }

  static Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    await _tasksBox.put(task.id, task);
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // Analytics and statistics
  static Map<String, dynamic> getAnalytics() {
    final ideas = getAllIdeas();
    final projects = getAllProjects();
    final tasks = getAllTasks();

    final totalRevenue = projects.fold<double>(
      0.0,
      (sum, project) => sum + project.monthlyRevenue,
    );

    final completedTasks = tasks.where((task) => task.status == TaskStatus.done).length;
    final totalTasks = tasks.length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

    final activeProjects = projects.where((p) => p.status == ProjectStatus.active).length;

    return {
      'totalIdeas': ideas.length,
      'totalProjects': projects.length,
      'activeProjects': activeProjects,
      'totalRevenue': totalRevenue,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'completionRate': completionRate,
    };
  }

  // Data export/import
  static Map<String, dynamic> exportData() {
    return {
      'ideas': getAllIdeas().map((idea) => idea.toJson()).toList(),
      'projects': getAllProjects().map((project) => project.toJson()).toList(),
      'tasks': getAllTasks().map((task) => task.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await _ideasBox.clear();
    await _projectsBox.clear();
    await _tasksBox.clear();

    // Import ideas
    if (data['ideas'] != null) {
      for (final ideaJson in data['ideas']) {
        final idea = Idea.fromJson(ideaJson);
        await saveIdea(idea);
      }
    }

    // Import projects
    if (data['projects'] != null) {
      for (final projectJson in data['projects']) {
        final project = Project.fromJson(projectJson);
        await saveProject(project);
      }
    }

    // Import tasks
    if (data['tasks'] != null) {
      for (final taskJson in data['tasks']) {
        final task = Task.fromJson(taskJson);
        await saveTask(task);
      }
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await _ideasBox.clear();
    await _projectsBox.clear();
    await _tasksBox.clear();
  }

  // Close all boxes
  static Future<void> close() async {
    await _ideasBox.close();
    await _projectsBox.close();
    await _tasksBox.close();
    await _settingsBox.close();
  }
}