import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ideas_controller.dart';
import '../controllers/projects_controller.dart';
import '../controllers/tasks_controller.dart';
import '../widgets/stat_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ideasController = Get.find<IdeasController>();
    final projectsController = Get.find<ProjectsController>();
    final tasksController = Get.find<TasksController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ideasController.loadIdeas();
              projectsController.loadProjects();
              tasksController.loadTasks();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ideasController.loadIdeas(),
            projectsController.loadProjects(),
            tasksController.loadTasks(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Stats
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final ideaStats = ideasController.getIdeaStats();
                final projectStats = projectsController.getProjectStats();
                final taskStats = tasksController.getTaskStats();

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: 'Total Ideas',
                      value: ideaStats['total'].toString(),
                      subtitle: '${ideaStats['validated']} validated',
                      icon: Icons.lightbulb,
                      color: Colors.amber,
                    ),
                    StatCard(
                      title: 'Active Projects',
                      value: projectStats['active'].toString(),
                      subtitle: 'of ${projectStats['total']} total',
                      icon: Icons.work,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Completed Tasks',
                      value: taskStats['done'].toString(),
                      subtitle: 'of ${taskStats['total']} total',
                      icon: Icons.task_alt,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Monthly Revenue',
                      value: '\$${projectStats['totalRevenue'].toStringAsFixed(0)}',
                      subtitle: '${projectStats['totalUsers']} users',
                      icon: Icons.attach_money,
                      color: Colors.purple,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),

              // Ideas Analytics
              Text(
                'Ideas Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final ideaStats = ideasController.getIdeaStats();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _AnalyticsRow(
                          label: 'Total Ideas',
                          value: ideaStats['total'].toString(),
                          color: Colors.amber,
                        ),
                        _AnalyticsRow(
                          label: 'Validated Ideas',
                          value: ideaStats['validated'].toString(),
                          color: Colors.green,
                        ),
                        _AnalyticsRow(
                          label: 'High Priority',
                          value: ideaStats['highPriority'].toString(),
                          color: Colors.red,
                        ),
                        _AnalyticsRow(
                          label: 'Average Score',
                          value: (ideaStats['averageScore'] ?? 0.0).toStringAsFixed(1),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Projects Analytics
              Text(
                'Projects Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final projectStats = projectsController.getProjectStats();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _AnalyticsRow(
                          label: 'Total Projects',
                          value: projectStats['total'].toString(),
                          color: Colors.blue,
                        ),
                        _AnalyticsRow(
                          label: 'Active Projects',
                          value: projectStats['active'].toString(),
                          color: Colors.green,
                        ),
                        _AnalyticsRow(
                          label: 'Completed Projects',
                          value: projectStats['completed'].toString(),
                          color: Colors.purple,
                        ),
                        _AnalyticsRow(
                          label: 'Average Progress',
                          value: '${(projectStats['averageProgress'] * 100).toInt()}%',
                          color: Colors.orange,
                        ),
                        _AnalyticsRow(
                          label: 'Overdue Projects',
                          value: projectStats['overdue'].toString(),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Tasks Analytics
              Text(
                'Tasks Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final taskStats = tasksController.getTaskStats();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _AnalyticsRow(
                          label: 'Total Tasks',
                          value: taskStats['total'].toString(),
                          color: Colors.blue,
                        ),
                        _AnalyticsRow(
                          label: 'To Do',
                          value: taskStats['todo'].toString(),
                          color: Colors.grey,
                        ),
                        _AnalyticsRow(
                          label: 'In Progress',
                          value: taskStats['inProgress'].toString(),
                          color: Colors.orange,
                        ),
                        _AnalyticsRow(
                          label: 'Completed',
                          value: taskStats['done'].toString(),
                          color: Colors.green,
                        ),
                        _AnalyticsRow(
                          label: 'Overdue Tasks',
                          value: taskStats['overdue'].toString(),
                          color: Colors.red,
                        ),
                        _AnalyticsRow(
                          label: 'Due Today',
                          value: taskStats['dueToday'].toString(),
                          color: Colors.amber,
                        ),
                        _AnalyticsRow(
                          label: 'Time Spent',
                          value: '${taskStats['totalTimeSpent'].toStringAsFixed(1)}h',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AnalyticsRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}