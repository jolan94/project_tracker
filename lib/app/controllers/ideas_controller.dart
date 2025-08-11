import 'package:get/get.dart';
import '../data/models/idea.dart';
import '../data/services/hive_service.dart';

class IdeasController extends GetxController {
  static IdeasController get to => Get.find();

  // Observable lists
  final RxList<Idea> _ideas = <Idea>[].obs;
  final RxList<Idea> _filteredIdeas = <Idea>[].obs;
  
  // Filters and search
  final RxString _searchQuery = ''.obs;
  final Rx<IdeaStatus?> _statusFilter = Rx<IdeaStatus?>(null);
  final Rx<IdeaPriority?> _priorityFilter = Rx<IdeaPriority?>(null);
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
  List<Idea> get ideas => _ideas;
  List<Idea> get filteredIdeas => _filteredIdeas;
  String get searchQuery => _searchQuery.value;
  IdeaStatus? get statusFilter => _statusFilter.value;
  IdeaPriority? get priorityFilter => _priorityFilter.value;
  String get selectedTag => _selectedTag.value;
  bool get isLoading => _isLoading.value;
  String get sortBy => _sortBy.value;
  bool get sortAscending => _sortAscending.value;
  Map<String, dynamic> get currentFilters => _currentFilters;
  Map<String, dynamic> get currentSort => _currentSort;

  @override
  void onInit() {
    super.onInit();
    loadIdeas();
  }

  Future<void> loadIdeas() async {
    try {
      _isLoading.value = true;
      final ideas = HiveService.getAllIdeas();
      _ideas.assignAll(ideas);
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load ideas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addIdea(Idea idea) async {
    try {
      await HiveService.saveIdea(idea);
      _ideas.add(idea);
      _applyFilters();
      Get.snackbar(
        'Success',
        'Idea added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add idea: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateIdea(Idea idea) async {
    try {
      await HiveService.updateIdea(idea);
      final index = _ideas.indexWhere((i) => i.id == idea.id);
      if (index != -1) {
        _ideas[index] = idea;
        _applyFilters();
      }
      Get.snackbar(
        'Success',
        'Idea updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update idea: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteIdea(String id) async {
    try {
      await HiveService.deleteIdea(id);
      _ideas.removeWhere((idea) => idea.id == id);
      _applyFilters();
      Get.snackbar(
        'Success',
        'Idea deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete idea: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void setStatusFilter(IdeaStatus? status) {
    _statusFilter.value = status;
    _applyFilters();
  }

  void setPriorityFilter(IdeaPriority? priority) {
    _priorityFilter.value = priority;
    _applyFilters();
  }

  void setTagFilter(String tag) {
    _selectedTag.value = tag;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = null;
    _priorityFilter.value = null;
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
    var filtered = _ideas.where((idea) {
      // Search filter
      if (_searchQuery.value.isNotEmpty) {
        final query = _searchQuery.value.toLowerCase();
        if (!idea.title.toLowerCase().contains(query) &&
            !idea.description.toLowerCase().contains(query) &&
            !idea.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Status filter
      if (_statusFilter.value != null && idea.status != _statusFilter.value) {
        return false;
      }

      // Priority filter
      if (_priorityFilter.value != null && idea.priority != _priorityFilter.value) {
        return false;
      }

      // Tag filter
      if (_selectedTag.value.isNotEmpty && !idea.tags.contains(_selectedTag.value)) {
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
        case 'validationScore':
          comparison = a.validationScore.compareTo(b.validationScore);
          break;
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }
      return _sortAscending.value ? comparison : -comparison;
    });

    _filteredIdeas.assignAll(filtered);
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (final idea in _ideas) {
      tags.addAll(idea.tags);
    }
    return tags.toList()..sort();
  }

  List<Idea> getIdeasByStatus(IdeaStatus status) {
    return _ideas.where((idea) => idea.status == status).toList();
  }

  List<Idea> getIdeasByPriority(IdeaPriority priority) {
    return _ideas.where((idea) => idea.priority == priority).toList();
  }

  List<Idea> getRecentIdeas({int limit = 5}) {
    final sorted = List<Idea>.from(_ideas)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  Map<String, int> getIdeaStats() {
    return {
      'total': _ideas.length,
      'backlog': getIdeasByStatus(IdeaStatus.backlog).length,
      'validated': getIdeasByStatus(IdeaStatus.validated).length,
      'archived': getIdeasByStatus(IdeaStatus.archived).length,
      'highPriority': getIdeasByPriority(IdeaPriority.high).length,
    };
  }
  
  void updateFiltersAndSort(Map<String, dynamic> data) {
    final filters = data['filters'] as Map<String, dynamic>? ?? {};
    final sort = data['sort'] as Map<String, dynamic>? ?? {};
    
    _currentFilters.assignAll(filters);
    _currentSort.assignAll(sort);
    
    // Update individual filter values
    _statusFilter.value = filters['status'];
    _priorityFilter.value = filters['priority'];
    
    // Update sort values
    _sortBy.value = sort['field'] ?? 'createdAt';
    _sortAscending.value = sort['direction'] == 'asc';
    
    _applyFilters();
  }
  
  void showFilterDialog() {
    // This will be called from the UI to show the filter dialog
  }
}