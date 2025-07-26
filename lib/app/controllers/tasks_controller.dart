import 'package:get/get.dart';
import '../data/models/task.dart';
import '../data/models/project.dart';
import '../data/services/hive_service.dart';
import 'projects_controller.dart';

class TasksController extends GetxController {
  static TasksController get to => Get.find();

  // Observable lists
  final RxList<Task> _tasks = <Task>[].obs;
  final RxList<Task> _filteredTasks = <Task>[].obs;
  
  // Filters and search
  final RxString _searchQuery = ''.obs;
  final Rx<TaskStatus?> _statusFilter = Rx<TaskStatus?>(null);
  final Rx<TaskPriority?> _priorityFilter = Rx<TaskPriority?>(null);
  final RxString _selectedTag = ''.obs;
  final RxString _projectFilter = ''.obs;
  
  // UI state
  final RxBool _isLoading = false.obs;
  final RxString _sortBy = 'createdAt'.obs;
  final RxBool _sortAscending = false.obs;
  final RxBool _showCompletedTasks = true.obs;

  // Getters
  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;
  String get searchQuery => _searchQuery.value;
  TaskStatus? get statusFilter => _statusFilter.value;
  TaskPriority? get priorityFilter => _priorityFilter.value;
  String get selectedTag => _selectedTag.value;
  String get projectFilter => _projectFilter.value;
  bool get isLoading => _isLoading.value;
  String get sortBy => _sortBy.value;
  bool get sortAscending => _sortAscending.value;
  bool get showCompletedTasks => _showCompletedTasks.value;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      _isLoading.value = true;
      final tasks = HiveService.getAllTasks();
      _tasks.assignAll(tasks);
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await HiveService.saveTask(task);
      _tasks.add(task);
      _applyFilters();
      
      // Update project progress if task belongs to a project
      if (task.projectId != null) {
        await ProjectsController.to.updateProjectProgress(task.projectId!);
      }
      
      Get.snackbar(
        'Success',
        'Task added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await HiveService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _applyFilters();
      }
      
      // Update project progress if task belongs to a project
      if (task.projectId != null) {
        await ProjectsController.to.updateProjectProgress(task.projectId!);
      }
      
      Get.snackbar(
        'Success',
        'Task updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      await HiveService.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      _applyFilters();
      
      // Update project progress if task belonged to a project
      if (task.projectId != null) {
        await ProjectsController.to.updateProjectProgress(task.projectId!);
      }
      
      Get.snackbar(
        'Success',
        'Task deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> markTaskAsStarted(String id) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.markAsStarted();
      await updateTask(task);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> markTaskAsCompleted(String id) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.markAsCompleted();
      await updateTask(task);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete task: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter.value = status;
    _applyFilters();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter.value = priority;
    _applyFilters();
  }

  void setTagFilter(String tag) {
    _selectedTag.value = tag;
    _applyFilters();
  }

  void setProjectFilter(String projectId) {
    _projectFilter.value = projectId;
    _applyFilters();
  }

  void toggleShowCompletedTasks() {
    _showCompletedTasks.value = !_showCompletedTasks.value;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = null;
    _priorityFilter.value = null;
    _selectedTag.value = '';
    _projectFilter.value = '';
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
    var filtered = _tasks.where((task) {
      // Search filter
      if (_searchQuery.value.isNotEmpty) {
        final query = _searchQuery.value.toLowerCase();
        if (!task.title.toLowerCase().contains(query) &&
            !task.description.toLowerCase().contains(query) &&
            !task.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Status filter
      if (_statusFilter.value != null && task.status != _statusFilter.value) {
        return false;
      }

      // Priority filter
      if (_priorityFilter.value != null && task.priority != _priorityFilter.value) {
        return false;
      }

      // Tag filter
      if (_selectedTag.value.isNotEmpty && !task.tags.contains(_selectedTag.value)) {
        return false;
      }

      // Project filter
      if (_projectFilter.value.isNotEmpty && task.projectId != _projectFilter.value) {
        return false;
      }

      // Show completed tasks filter
      if (!_showCompletedTasks.value && task.status == TaskStatus.done) {
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
        case 'priority':
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case 'status':
          comparison = a.status.index.compareTo(b.status.index);
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

    _filteredTasks.assignAll(filtered);
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (final task in _tasks) {
      tags.addAll(task.tags);
    }
    return tags.toList()..sort();
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  List<Task> getOverdueTasks() {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  List<Task> getTodayTasks() {
    return _tasks.where((task) => task.isDueToday).toList();
  }

  List<Task> getUpcomingTasks({int days = 7}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(now) && task.dueDate!.isBefore(futureDate);
    }).toList();
  }

  List<Task> getRecentTasks({int limit = 5}) {
    final sorted = List<Task>.from(_tasks)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(limit).toList();
  }

  double getTotalTimeSpent() {
    return _tasks.fold<double>(
      0.0,
      (sum, task) => sum + (task.timeSpent?.inHours ?? 0),
    );
  }

  double getTotalEstimatedTime() {
    return _tasks.fold<double>(
      0.0,
      (sum, task) => sum + task.estimatedHours,
    );
  }

  Map<String, dynamic> getTaskStats() {
    return {
      'total': _tasks.length,
      'todo': getTasksByStatus(TaskStatus.todo).length,
      'inProgress': getTasksByStatus(TaskStatus.inProgress).length,
      'done': getTasksByStatus(TaskStatus.done).length,
      'overdue': getOverdueTasks().length,
      'dueToday': getTodayTasks().length,
      'highPriority': getTasksByPriority(TaskPriority.high).length,
      'totalTimeSpent': getTotalTimeSpent(),
      'totalEstimatedTime': getTotalEstimatedTime(),
    };
  }

  Map<TaskPriority, int> getTasksByPriorityCount() {
    return {
      TaskPriority.low: getTasksByPriority(TaskPriority.low).length,
      TaskPriority.medium: getTasksByPriority(TaskPriority.medium).length,
      TaskPriority.high: getTasksByPriority(TaskPriority.high).length,
    };
  }

  Map<TaskStatus, int> getTasksByStatusCount() {
    return {
      TaskStatus.todo: getTasksByStatus(TaskStatus.todo).length,
      TaskStatus.inProgress: getTasksByStatus(TaskStatus.inProgress).length,
      TaskStatus.done: getTasksByStatus(TaskStatus.done).length,
    };
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
}