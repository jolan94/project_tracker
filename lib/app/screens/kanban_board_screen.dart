import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tasks_controller.dart';
import '../data/models/task.dart';
import 'task_form_screen.dart';

class KanbanBoardScreen extends StatelessWidget {
  const KanbanBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Kanban Board',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const TaskFormScreen());
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Task',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF10B981),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumn(
                'To Do',
                TaskStatus.todo,
                const Color(0xFF6B7280),
                controller.tasks.where((task) => task.status == TaskStatus.todo).toList(),
                controller,
                context,
              ),
              const SizedBox(width: 16),
              _buildColumn(
                'In Progress',
                TaskStatus.inProgress,
                const Color(0xFF3B82F6),
                controller.tasks.where((task) => task.status == TaskStatus.inProgress).toList(),
                controller,
                context,
              ),
              const SizedBox(width: 16),
              _buildColumn(
                'Testing',
                TaskStatus.testing,
                const Color(0xFF8B5CF6),
                controller.tasks.where((task) => task.status == TaskStatus.testing).toList(),
                controller,
                context,
              ),
              const SizedBox(width: 16),
              _buildColumn(
                'Blocked',
                TaskStatus.blocked,
                const Color(0xFFEF4444),
                controller.tasks.where((task) => task.status == TaskStatus.blocked).toList(),
                controller,
                context,
              ),
              const SizedBox(width: 16),
              _buildColumn(
                'Done',
                TaskStatus.done,
                const Color(0xFF10B981),
                controller.tasks.where((task) => task.status == TaskStatus.done).toList(),
                controller,
                context,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildColumn(
    String title,
    TaskStatus status,
    Color color,
    List<Task> tasks,
    TasksController controller,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tasks List
          Expanded(
            child: DragTarget<Task>(
              onAccept: (task) {
                controller.updateTaskStatus(task.id, status);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? color.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    shrinkWrap: true,
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _KanbanTaskCard(
                          task: task,
                          color: color,
                        ),
                      );
                    },
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

class _KanbanTaskCard extends StatelessWidget {
  final Task task;
  final Color color;

  const _KanbanTaskCard({
    required this.task,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF334155), // Updated to match new theme
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: _buildCardContent(),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCard(),
      ),
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTap: () {
        Get.to(() => TaskFormScreen(task: task));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF334155), // Updated to match new theme
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          task.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (task.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            task.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 12),
        // Priority and Due Date
        Row(
          children: [
            // Priority
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getPriorityColor(task.priority),
                ),
              ),
            ),
            const Spacer(),
            // Due Date
            if (task.dueDate != null)
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: task.isOverdue
                        ? Colors.red
                        : task.isDueToday
                            ? Colors.orange
                            : Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(task.dueDate!),
                    style: TextStyle(
                      fontSize: 10,
                      color: task.isOverdue
                          ? Colors.red
                          : task.isDueToday
                              ? Colors.orange
                              : Colors.grey[400],
                      fontWeight: task.isOverdue || task.isDueToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
          ],
        ),
        // Tags
        if (task.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: task.tags.take(2).map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 9,
                  color: color,
                ),
              ),
            )).toList(),
          ),
        ],
        // Estimated Hours
        if (task.estimatedHours > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Text(
                '${task.estimatedHours}h',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ],
    );
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
      return '${difference.inDays}d';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else {
      return '${difference.inDays.abs()}d ago';
    }
  }
}