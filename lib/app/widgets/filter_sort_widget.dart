import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/idea.dart';
import '../data/models/project.dart';
import '../data/models/task.dart';

class FilterSortWidget extends StatelessWidget {
  final FilterSortType type;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> currentFilters;
  final Map<String, dynamic> currentSort;

  const FilterSortWidget({
    super.key,
    required this.type,
    required this.onFiltersChanged,
    required this.currentFilters,
    required this.currentSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filter Section
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildFilterSection(context),
          
          const SizedBox(height: 24),
          
          // Sort Section
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSortSection(context),
          
          const SizedBox(height: 24),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    switch (type) {
      case FilterSortType.ideas:
        return _buildIdeasFilters(context);
      case FilterSortType.projects:
        return _buildProjectsFilters(context);
      case FilterSortType.tasks:
        return _buildTasksFilters(context);
    }
  }

  Widget _buildIdeasFilters(BuildContext context) {
    return Column(
      children: [
        // Status Filter
        _buildDropdownFilter<IdeaStatus?>(
          context,
          'Status',
          currentFilters['status'],
          [null, ...IdeaStatus.values],
          (value) => value?.name != null ? value!.name[0].toUpperCase() + value.name.substring(1) : 'All',
          (value) => _updateFilter('status', value),
        ),
        const SizedBox(height: 12),
        
        // Priority Filter
        _buildDropdownFilter<IdeaPriority?>(
          context,
          'Priority',
          currentFilters['priority'],
          [null, ...IdeaPriority.values],
          (value) => value?.name != null ? value!.name[0].toUpperCase() + value.name.substring(1) : 'All',
          (value) => _updateFilter('priority', value),
        ),
      ],
    );
  }

  Widget _buildProjectsFilters(BuildContext context) {
    return Column(
      children: [
        // Status Filter
        _buildDropdownFilter<ProjectStatus?>(
          context,
          'Status',
          currentFilters['status'],
          [null, ...ProjectStatus.values],
          (value) => value?.name != null ? value!.name[0].toUpperCase() + value.name.substring(1) : 'All',
          (value) => _updateFilter('status', value),
        ),
        const SizedBox(height: 12),
        
        // Revenue Range Filter
        _buildDropdownFilter<String?>(
          context,
          'Revenue Range',
          currentFilters['revenueRange'],
          [null, '0-100', '100-1000', '1000-5000', '5000+'],
          (value) => value ?? 'All',
          (value) => _updateFilter('revenueRange', value),
        ),
      ],
    );
  }

  Widget _buildTasksFilters(BuildContext context) {
    return Column(
      children: [
        // Status Filter
        _buildDropdownFilter<TaskStatus?>(
          context,
          'Status',
          currentFilters['status'],
          [null, ...TaskStatus.values],
          (value) => value?.statusDisplayName ?? 'All',
          (value) => _updateFilter('status', value),
        ),
        const SizedBox(height: 12),
        
        // Priority Filter
        _buildDropdownFilter<TaskPriority?>(
          context,
          'Priority',
          currentFilters['priority'],
          [null, ...TaskPriority.values],
          (value) => value?.priorityDisplayName ?? 'All',
          (value) => _updateFilter('priority', value),
        ),
      ],
    );
  }

  Widget _buildSortSection(BuildContext context) {
    List<String> sortOptions;
    switch (type) {
      case FilterSortType.ideas:
        sortOptions = ['title', 'createdAt', 'updatedAt', 'priority', 'validationScore'];
        break;
      case FilterSortType.projects:
        sortOptions = ['title', 'createdAt', 'updatedAt', 'monthlyRevenue', 'progress', 'dueDate'];
        break;
      case FilterSortType.tasks:
        sortOptions = ['title', 'createdAt', 'updatedAt', 'priority', 'dueDate'];
        break;
    }

    return Column(
      children: [
        // Sort Field
        _buildDropdownFilter<String>(
          context,
          'Sort Field',
          currentSort['field'] ?? sortOptions.first,
          sortOptions,
          (value) => _getSortFieldDisplayName(value),
          (value) => _updateSort('field', value),
        ),
        const SizedBox(height: 12),
        
        // Sort Direction
        _buildDropdownFilter<String>(
          context,
          'Sort Order',
          currentSort['direction'] ?? 'desc',
          ['asc', 'desc'],
          (value) => value == 'asc' ? 'Ascending' : 'Descending',
          (value) => _updateSort('direction', value),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter<T>(
    BuildContext context,
    String label,
    T currentValue,
    List<T> options,
    String Function(T) displayName,
    Function(T) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: currentValue,
              isExpanded: true,
              items: options.map((option) {
                return DropdownMenuItem<T>(
                  value: option,
                  child: Text(displayName(option)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getSortFieldDisplayName(String field) {
    switch (field) {
      case 'title':
        return 'Title';
      case 'createdAt':
        return 'Created Date';
      case 'updatedAt':
        return 'Updated Date';
      case 'priority':
        return 'Priority';
      case 'validationScore':
        return 'Validation Score';
      case 'monthlyRevenue':
        return 'Monthly Revenue';
      case 'progress':
        return 'Progress';
      case 'dueDate':
        return 'Due Date';
      default:
        return field.isNotEmpty ? field[0].toUpperCase() + field.substring(1) : field;
    }
  }

  void _updateFilter(String key, dynamic value) {
    final updatedFilters = Map<String, dynamic>.from(currentFilters);
    updatedFilters[key] = value;
    onFiltersChanged({
      'filters': updatedFilters,
      'sort': currentSort,
    });
  }

  void _updateSort(String key, dynamic value) {
    final updatedSort = Map<String, dynamic>.from(currentSort);
    updatedSort[key] = value;
    onFiltersChanged({
      'filters': currentFilters,
      'sort': updatedSort,
    });
  }

  void _clearFilters() {
    onFiltersChanged({
      'filters': <String, dynamic>{},
      'sort': {'field': _getDefaultSortField(), 'direction': 'desc'},
    });
  }

  String _getDefaultSortField() {
    switch (type) {
      case FilterSortType.ideas:
        return 'createdAt';
      case FilterSortType.projects:
        return 'createdAt';
      case FilterSortType.tasks:
        return 'createdAt';
    }
  }
}

enum FilterSortType {
  ideas,
  projects,
  tasks,
}

// Extension to add statusDisplayName to TaskStatus
extension TaskStatusExtension on TaskStatus {
  String get statusDisplayName {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.testing:
        return 'Testing';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.blocked:
        return 'Blocked';
    }
  }
}

// Extension to add priorityDisplayName to TaskPriority
extension TaskPriorityExtension on TaskPriority {
  String get priorityDisplayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}