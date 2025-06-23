import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracker/models/project_model.dart';
import 'package:project_tracker/services/storage_service.dart';
import 'package:project_tracker/app/theme/app_theme.dart';

class ProjectController extends GetxController {
  final RxList<Project> projects = <Project>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<ProjectStatus?> filterStatus = Rx<ProjectStatus?>(null);

  // Computed properties
  int get buildingCount =>
      projects.where((p) => p.status == ProjectStatus.building).length;
  int get shippedCount =>
      projects.where((p) => p.status == ProjectStatus.shipped).length;
  int get abandonedCount =>
      projects.where((p) => p.status == ProjectStatus.abandoned).length;
  int get stuckCount =>
      projects.where((p) => p.status == ProjectStatus.stuck).length;

  double get completionRate {
    if (projects.isEmpty) return 0;
    return (shippedCount / projects.length) * 100;
  }

  String get statsText {
    if (projects.isEmpty) return 'No projects yet';
    return '$buildingCount building, $shippedCount shipped, $abandonedCount abandoned';
  }

  String get motivationalMessage {
    if (projects.isEmpty) {
      return "No projects yet? Time to start something you won't finish! 😅";
    }
    if (buildingCount >= 3) {
      return "Maybe focus on one? Just a thought 🤔";
    }
    if (completionRate < 20 && projects.length > 5) {
      return "Your graveyard is growing... perfectly normal 💀";
    }
    if (shippedCount > abandonedCount) {
      return "Actually shipping things? Who are you?! 🎉";
    }
    return "Keep building (or abandoning). We don't judge 😊";
  }

  @override
  void onInit() {
    super.onInit();
    loadProjects();

    // Add fake data for development
    if (projects.isEmpty) {
      _addFakeProjects();
    }
  }

  void loadProjects() {
    isLoading.value = true;
    try {
      final loadedProjects = StorageService.getAllProjects();
      projects.assignAll(loadedProjects);
    } catch (e) {
      Get.snackbar(
        'Oops!',
        'Failed to load projects. Probably not your fault (this time).',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await StorageService.projectsBox.add(project);
      projects.add(project);

      Get.snackbar(
        'Project Added!',
        'Now actually work on it 😉',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add project. The universe is against you today.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await StorageService.saveProject(project);
      final index = projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        projects[index] = project;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update project. Classic.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await StorageService.deleteProject(id);
      projects.removeWhere((p) => p.id == id);

      Get.snackbar(
        'Deleted',
        'One less thing to worry about 🗑️',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Cannot delete. This project will haunt you forever.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProjectStatus(String id, ProjectStatus status) async {
    final project = projects.firstWhere((p) => p.id == id);
    project.updateStatus(status);
    await updateProject(project);

    // Special celebration for shipping
    if (status == ProjectStatus.shipped) {
      Get.snackbar(
        '🎉 Holy shit!',
        'You actually finished something! Screenshot this moment!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: AppTheme.successColor.withOpacity(0.1),
        colorText: AppTheme.textPrimary,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        borderColor: AppTheme.successColor,
        borderWidth: 1,
      );
    }
  }

  Future<void> abandonProject(String id, String reason) async {
    final project = projects.firstWhere((p) => p.id == id);
    project.updateStatus(ProjectStatus.abandoned, reason: reason);
    await updateProject(project);

    Get.snackbar(
      'Added to the graveyard',
      "Don't worry, we've all been there 💀",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> addNote(String projectId, String note) async {
    final project = projects.firstWhere((p) => p.id == projectId);
    project.addNote(note);
    await updateProject(project);
  }

  // Get a single project by ID
  Project? getProject(String id) {
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get filtered projects
  List<Project> get filteredProjects {
    if (filterStatus.value == null) {
      return projects;
    }
    return projects.where((p) => p.status == filterStatus.value).toList();
  }

  // Set filter
  void setFilter(ProjectStatus? status) {
    filterStatus.value = status;
  }

  // Clear filter
  void clearFilter() {
    filterStatus.value = null;
  }

  // Add fake projects for development
  void _addFakeProjects() async {
    final fakeProjects = [
      Project(
        name: 'Weather App',
        description: 'A beautiful weather app with Material You design',
        status: ProjectStatus.shipped,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Project(
        name: 'Todo App Rewrite',
        description: 'The 15th attempt at making the perfect todo app',
        status: ProjectStatus.abandoned,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 20)),
        abandonReason: 'Found something shinier ✨',
      ),
      Project(
        name: 'Fitness Tracker',
        description: 'Track workouts and nutrition with ML predictions',
        status: ProjectStatus.building,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Project(
        name: 'Crypto Portfolio',
        description: 'Real-time crypto tracking with fancy charts',
        status: ProjectStatus.stuck,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Project(
        name: 'Social Media Clone',
        description: 'Because the world needs another one',
        status: ProjectStatus.abandoned,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 75)),
        abandonReason: 'Realized it\'s already been done 😅',
      ),
    ];

    for (final project in fakeProjects) {
      await addProject(project);
    }
  }
}
