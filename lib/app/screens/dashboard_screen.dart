import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ideas_controller.dart';
import '../controllers/projects_controller.dart';
import '../controllers/tasks_controller.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_items_list.dart';
import '../widgets/quick_actions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ideasController = Get.find<IdeasController>();
    final projectsController = Get.find<ProjectsController>();
    final tasksController = Get.find<TasksController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
              // Quick Stats
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
                      title: 'Ideas',
                      value: ideaStats['total'].toString(),
                      subtitle: '${ideaStats['validated']} validated',
                      icon: Icons.lightbulb,
                      color: Colors.amber,
                    ),
                    StatCard(
                      title: 'Projects',
                      value: projectStats['total'].toString(),
                      subtitle: '${projectStats['active']} active',
                      icon: Icons.work,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Tasks',
                      value: taskStats['total'].toString(),
                      subtitle: '${taskStats['done']} completed',
                      icon: Icons.task,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Revenue',
                      value: '\$${projectStats['totalRevenue'].toStringAsFixed(0)}',
                      subtitle: 'Monthly',
                      icon: Icons.attach_money,
                      color: Colors.purple,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const QuickActions(),
              const SizedBox(height: 32),

              // Recent Items
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final recentIdeas = ideasController.getRecentIdeas(limit: 3);
                final recentProjects = projectsController.getRecentProjects(limit: 3);
                final recentTasks = tasksController.getRecentTasks(limit: 3);

                return Column(
                  children: [
                    if (recentIdeas.isNotEmpty)
                      RecentItemsList(
                        title: 'Recent Ideas',
                        items: recentIdeas.map((idea) => {
                          'title': idea.title,
                          'subtitle': idea.description,
                          'trailing': idea.priority.name,
                          'onTap': () => Get.toNamed('/idea-detail', arguments: idea.id),
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    if (recentProjects.isNotEmpty)
                      RecentItemsList(
                        title: 'Recent Projects',
                        items: recentProjects.map((project) => {
                          'title': project.title,
                          'subtitle': project.description,
                          'trailing': '${(project.progress * 100).toInt()}%',
                          'onTap': () => Get.toNamed('/project-detail', arguments: project.id),
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    if (recentTasks.isNotEmpty)
                      RecentItemsList(
                        title: 'Recent Tasks',
                        items: recentTasks.map((task) => {
                          'title': task.title,
                          'subtitle': task.description,
                          'trailing': task.status.name,
                          'onTap': () => Get.toNamed('/task-detail', arguments: task.id),
                        }).toList(),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}