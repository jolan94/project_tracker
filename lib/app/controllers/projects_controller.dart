import 'package:get/get.dart';
import '../data/models/project.dart';
import '../data/models/task.dart';
import '../data/services/hive_service.dart';

class ProjectsController extends GetxController {
  static ProjectsController get to => Get.find();

  // Observable lists
  final RxList<Project> _projects = <Project>[].obs;
  final RxList<Project> _filteredProjects = <Project>[].obs;
  
  // Filters and search
  final RxString _searchQuery = ''.obs;
  final Rx<ProjectStatus?> _statusFilter = Rx<ProjectStatus?>(null);
  final RxString _selectedTag = ''.obs;
  
  // UI state
  final RxBool _isLoading = false.obs;
  final RxString _sortBy = 'createdAt'.obs;
  final RxBool _sortAscending = false.obs;
  
  // Filter/Sort state for widget
  final RxMap<String, dynamic> _currentFilters = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _currentSort = <String, dynamic>{
    'field': 'createdAt',
    'direction': 'desc'
  }.obs;

  // Getters
  List<Project> get projects => _projects;
  List<Project> get filteredProjects => _filteredProjects;
  String get searchQuery => _searchQuery.value;
  ProjectStatus? get statusFilter => _statusFilter.value;
  String get selectedTag => _selectedTag.value;
  bool get isLoading => _isLoading.value;
  String get sortBy => _sortBy.value;
  bool get sortAscending => _sortAscending.value;
  Map<String, dynamic> get currentFilters => _currentFilters;
  Map<String, dynamic> get currentSort => _currentSort;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      _isLoading.value = true;
      final projects = HiveService.getAllProjects();
      _projects.assignAll(projects);
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load projects: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await HiveService.saveProject(project);
      _projects.add(project);
      _applyFilters();
      Get.snackbar(
        'Success',
        'Project added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add project: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await HiveService.updateProject(project);
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        _applyFilters();
      }
      Get.snackbar(
        'Success',
        'Project updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update project: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await HiveService.deleteProject(id);
      _projects.removeWhere((project) => project.id == id);
      _applyFilters();
      Get.snackbar(
        'Success',
        'Project deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete project: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProjectProgress(String projectId) async {
    try {
      final project = _projects.firstWhere((p) => p.id == projectId);
      final tasks = HiveService.getTasksForProject(projectId);
      
      if (tasks.isEmpty) {
        project.progress = 0.0;
      } else {
        final completedTasks = tasks.where((task) => task.status == TaskStatus.done).length;
        project.progress = completedTasks / tasks.length;
      }
      
      await updateProject(project);
    } catch (e) {
      print('Error updating project progress: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void setStatusFilter(ProjectStatus? status) {
    _statusFilter.value = status;
    _applyFilters();
  }

  void setTagFilter(String tag) {
    _selectedTag.value = tag;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = null;
    _selectedTag.value = '';
    _applyFilters();
  }

  void setSorting(String sortBy, {bool? ascending}) {
    _sortBy.value = sortBy;
    if (ascending != null) {
      _sortAscending.value = ascending;
    } else {
      _sortAscending.value = !_sortAscending.value;
    }
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _projects.where((project) {
      // Search filter
      if (_searchQuery.value.isNotEmpty) {
        final query = _searchQuery.value.toLowerCase();
        if (!project.title.toLowerCase().contains(query) &&
            !project.description.toLowerCase().contains(query) &&
            !project.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Status filter
      if (_statusFilter.value != null && project.status != _statusFilter.value) {
        return false;
      }

      // Tag filter
      if (_selectedTag.value.isNotEmpty && !project.tags.contains(_selectedTag.value)) {
        return false;
      }

      return true;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy.value) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'updatedAt':
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case 'progress':
          comparison = a.progress.compareTo(b.progress);
          break;
        case 'revenue':
          comparison = a.monthlyRevenue.compareTo(b.monthlyRevenue);
          break;
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) comparison = 0;
          else if (a.dueDate == null) comparison = 1;
          else if (b.dueDate == null) comparison = -1;
          else comparison = a.dueDate!.compareTo(b.dueDate!);
          break;
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }
      return _sortAscending.value ? comparison : -comparison;
    });

    _filteredProjects.assignAll(filtered);
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (final project in _projects) {
      tags.addAll(project.tags);
    }
    return tags.toList()..sort();
  }

  List<Project> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((project) => project.status == status).toList();
  }

  List<Project> getActiveProjects() {
    return getProjectsByStatus(ProjectStatus.active);
  }

  List<Project> getOverdueProjects() {
    return _projects.where((project) => project.isOverdue).toList();
  }

  List<Project> getRecentProjects({int limit = 5}) {
    final sorted = List<Project>.from(_projects)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(limit).toList();
  }

  double getTotalRevenue() {
    return _projects.fold<double>(
      0.0,
      (sum, project) => sum + project.monthlyRevenue,
    );
  }

  int getTotalUsers() {
    return _projects.fold<int>(
      0,
      (sum, project) => sum + project.userCount,
    );
  }

  double getAverageProgress() {
    if (_projects.isEmpty) return 0.0;
    final totalProgress = _projects.fold<double>(
      0.0,
      (sum, project) => sum + project.progress,
    );
    return totalProgress / _projects.length;
  }

  Map<String, dynamic> getProjectStats() {
    return {
      'total': _projects.length,
      'active': getProjectsByStatus(ProjectStatus.active).length,
      'completed': getProjectsByStatus(ProjectStatus.completed).length,
      'planning': getProjectsByStatus(ProjectStatus.planning).length,
      'onHold': getProjectsByStatus(ProjectStatus.onHold).length,
      'overdue': getOverdueProjects().length,
      'totalRevenue': getTotalRevenue(),
      'totalUsers': getTotalUsers(),
      'averageProgress': getAverageProgress(),
    };
  }

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
  
  void updateFiltersAndSort(Map<String, dynamic> data) {
    final filters = data['filters'] as Map<String, dynamic>? ?? {};
    final sort = data['sort'] as Map<String, dynamic>? ?? {};
    
    _currentFilters.assignAll(filters);
    _currentSort.assignAll(sort);
    
    // Update individual filter values
    _statusFilter.value = filters['status'];
    
    // Update sort values
    _sortBy.value = sort['field'] ?? 'createdAt';
    _sortAscending.value = sort['direction'] == 'asc';
    
    _applyFilters();
  }
  
  void showFilterDialog() {
    // This will be called from the UI to show the filter dialog
  }
}