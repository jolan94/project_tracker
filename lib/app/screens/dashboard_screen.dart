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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ideasController.loadIdeas(),
            projectsController.loadProjects(),
            tasksController.loadTasks(),
          ]);
        },
        color: colorScheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.secondary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your ideas, manage projects, and achieve your goals.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Overview Section
              _SectionHeader(
                title: 'Overview',
                subtitle: 'Your progress at a glance',
                theme: theme,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 20),
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
                  childAspectRatio: 1.1,
                  children: [
                    StatCard(
                      title: 'Ideas',
                      value: ideaStats['total'].toString(),
                      subtitle: '${ideaStats['validated']} validated',
                      icon: Icons.lightbulb_outline,
                      color: Colors.amber.shade600,
                    ),
                    StatCard(
                      title: 'Projects',
                      value: projectStats['total'].toString(),
                      subtitle: '${projectStats['active']} active',
                      icon: Icons.work_outline,
                      color: Colors.blue.shade600,
                    ),
                    StatCard(
                      title: 'Tasks',
                      value: taskStats['total'].toString(),
                      subtitle: '${taskStats['done']} completed',
                      icon: Icons.task_outlined,
                      color: Colors.green.shade600,
                    ),
                    StatCard(
                      title: 'Revenue',
                      value: '\$${projectStats['totalRevenue'].toStringAsFixed(0)}',
                      subtitle: 'Monthly',
                      icon: Icons.attach_money,
                      color: Colors.purple.shade600,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 40),

              // Quick Actions Section
              _SectionHeader(
                title: 'Quick Actions',
                subtitle: 'Create new content quickly',
                theme: theme,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 20),
              const QuickActions(),
              const SizedBox(height: 40),

              // Recent Activity Section
              _SectionHeader(
                title: 'Recent Activity',
                subtitle: 'Your latest updates',
                theme: theme,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 20),
              Obx(() {
                final recentIdeas = ideasController.getRecentIdeas(limit: 3);
                final recentProjects = projectsController.getRecentProjects(limit: 3);
                final recentTasks = tasksController.getRecentTasks(limit: 3);

                final recentItems = <Map<String, dynamic>>[
                  ...recentIdeas.map((idea) => {
                    'title': idea.title,
                    'subtitle': 'Idea • ${idea.description}',
                    'trailing': idea.priority.name.toUpperCase(),
                    'onTap': () => Get.toNamed('/idea-detail', arguments: idea.id),
                  }),
                  ...recentProjects.map((project) => {
                    'title': project.title,
                    'subtitle': 'Project • ${project.description}',
                    'trailing': '${(project.progress * 100).toInt()}%',
                    'onTap': () => Get.toNamed('/project-detail', arguments: project.id),
                  }),
                  ...recentTasks.map((task) => {
                    'title': task.title,
                    'subtitle': 'Task • ${task.description}',
                    'trailing': task.status.name.toUpperCase(),
                    'onTap': () => Get.toNamed('/task-detail', arguments: task.id),
                  }),
                ];

                return RecentItemsList(
                  title: '',
                  items: recentItems.take(5).toList(),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}