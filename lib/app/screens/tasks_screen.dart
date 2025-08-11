import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tasks_controller.dart';
import '../controllers/projects_controller.dart';
import '../data/models/task.dart';
import '../data/models/project.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';
import 'kanban_board_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.filteredTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.task_alt_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Stay organized by creating\nyour first task',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const TaskFormScreen()),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create First Task'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadTasks,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            itemCount: controller.filteredTasks.length,
            itemBuilder: (context, index) {
              final task = controller.filteredTasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _TaskCard(task: task),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "tasks_fab",
        onPressed: () => Get.to(() => const TaskFormScreen()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => TaskDetailScreen(task: task)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with checkbox, title, and priority
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (task.status == TaskStatus.todo) {
                          controller.markTaskAsStarted(task.id);
                        } else if (task.status == TaskStatus.inProgress) {
                          controller.markTaskAsCompleted(task.id);
                        }
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getStatusColor(task.status),
                            width: 2.5,
                          ),
                          color: task.status == TaskStatus.done 
                              ? _getStatusColor(task.status) 
                              : Colors.transparent,
                        ),
                        child: task.status == TaskStatus.done
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Colors.white,
                              )
                            : task.status == TaskStatus.inProgress
                                ? Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getStatusColor(task.status),
                                    ),
                                  )
                                : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                          decoration: task.status == TaskStatus.done 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getPriorityColor(task.priority).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        task.priority.name.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getPriorityColor(task.priority),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description
                if (task.description.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        height: 1.5,
                        decoration: task.status == TaskStatus.done 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Status and metadata section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(task.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(task.status).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(task.status),
                                  size: 14,
                                  color: _getStatusColor(task.status),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  task.statusDisplayName,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getStatusColor(task.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          if (task.estimatedHours > 0) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF3A3A3A) : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${task.estimatedHours}h',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const Spacer(),
                          
                          if (task.dueDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: task.isOverdue 
                                    ? Colors.red.withOpacity(0.1)
                                    : task.isDueToday
                                        ? Colors.orange.withOpacity(0.1)
                                        : (isDark ? const Color(0xFF3A3A3A) : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                                border: (task.isOverdue || task.isDueToday)
                                    ? Border.all(
                                        color: task.isOverdue 
                                            ? Colors.red.withOpacity(0.3)
                                            : Colors.orange.withOpacity(0.3),
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: task.isOverdue 
                                        ? Colors.red 
                                        : task.isDueToday
                                            ? Colors.orange
                                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.isDueToday 
                                        ? 'Due today'
                                        : task.isOverdue 
                                            ? 'Overdue'
                                            : 'Due ${_formatDate(task.dueDate!)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: task.isOverdue 
                                          ? Colors.red 
                                          : task.isDueToday
                                              ? Colors.orange
                                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Tags
                if (task.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: task.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline_rounded;
      case TaskStatus.done:
        return Icons.check_circle_rounded;
      case TaskStatus.testing:
        return Icons.science_rounded;
      case TaskStatus.blocked:
        return Icons.block_rounded;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.testing:
        return Colors.purple;
      case TaskStatus.blocked:
        return Colors.red;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.deepOrange;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays}d';
    } else if (difference.inDays == 0) {
      return 'today';
    } else {
      return '${difference.inDays.abs()}d ago';
    }
  }
}