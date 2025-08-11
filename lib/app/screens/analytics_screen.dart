import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ideasController.loadIdeas(),
            projectsController.loadProjects(),
            tasksController.loadTasks(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analytics Dashboard',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A),
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track your progress and insights',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Overview Stats
              const _SectionHeader(
                title: 'Overview',
                subtitle: 'Key metrics at a glance',
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
                  childAspectRatio: 1,
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
                      value:
                          '\$${projectStats['totalRevenue'].toStringAsFixed(0)}',
                      subtitle: '${projectStats['totalUsers']} users',
                      icon: Icons.attach_money,
                      color: Colors.purple,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 40),

              // Charts Section
              const _SectionHeader(
                title: 'Visual Analytics',
                subtitle: 'Data visualization and trends',
              ),
              const SizedBox(height: 20),
              Obx(() {
                final taskStats = tasksController.getTaskStats();
                final projectStats = projectsController.getProjectStats();
                return Column(
                  children: [
                    // Task Status Pie Chart
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.08,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.pie_chart_rounded,
                                    size: 24,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Task Distribution',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1A1A1A),
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Current task status breakdown',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 240,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 50,
                                  sections: [
                                    PieChartSectionData(
                                      color: const Color(0xFF6B7280),
                                      value: taskStats['todo'].toDouble(),
                                      title: 'To Do\n${taskStats['todo']}',
                                      radius: 70,
                                      titleStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: const Color(0xFF3B82F6),
                                      value: taskStats['inProgress'].toDouble(),
                                      title:
                                          'In Progress\n${taskStats['inProgress']}',
                                      radius: 70,
                                      titleStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: const Color(0xFF10B981),
                                      value: taskStats['done'].toDouble(),
                                      title: 'Done\n${taskStats['done']}',
                                      radius: 70,
                                      titleStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Project Progress Bar Chart
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.08,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart_rounded,
                                    size: 24,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Project Status Overview',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1A1A1A),
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Project progress comparison',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY:
                                      (projectStats['total'] as int)
                                          .toDouble() +
                                      1,
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final textColor = isDark
                                              ? Colors.white
                                              : Colors.black87;
                                          switch (value.toInt()) {
                                            case 0:
                                              return Text(
                                                'Active',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 12,
                                                ),
                                              );
                                            case 1:
                                              return Text(
                                                'Completed',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 12,
                                                ),
                                              );
                                            case 2:
                                              return Text(
                                                'Overdue',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 12,
                                                ),
                                              );
                                            default:
                                              return const Text('');
                                          }
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          final textColor = isDark
                                              ? Colors.white
                                              : Colors.black87;
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    BarChartGroupData(
                                      x: 0,
                                      barRods: [
                                        BarChartRodData(
                                          toY: (projectStats['active'] as int)
                                              .toDouble(),
                                          color: const Color(0xFF10B981),
                                          width: 40,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 1,
                                      barRods: [
                                        BarChartRodData(
                                          toY:
                                              (projectStats['completed'] as int)
                                                  .toDouble(),
                                          color: const Color(0xFF3B82F6),
                                          width: 40,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 2,
                                      barRods: [
                                        BarChartRodData(
                                          toY: (projectStats['overdue'] as int)
                                              .toDouble(),
                                          color: const Color(0xFFEF4444),
                                          width: 40,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 40),

              // Ideas Analytics
              const _SectionHeader(
                title: 'Ideas Analytics',
                subtitle: 'Innovation and validation metrics',
              ),
              const SizedBox(height: 20),
              Obx(() {
                final ideaStats = ideasController.getIdeaStats();
                return _AnalyticsCard(
                  title: 'Ideas Overview',
                  icon: Icons.lightbulb_rounded,
                  iconColor: Colors.amber,
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
                      value: (ideaStats['averageScore'] ?? 0.0).toStringAsFixed(
                        1,
                      ),
                      color: Colors.blue,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),

              // Projects Analytics
              const _SectionHeader(
                title: 'Projects Analytics',
                subtitle: 'Project progress and performance',
              ),
              const SizedBox(height: 20),
              Obx(() {
                final projectStats = projectsController.getProjectStats();
                return _AnalyticsCard(
                  title: 'Projects Overview',
                  icon: Icons.work_rounded,
                  iconColor: Colors.blue,
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
                      value:
                          '${(projectStats['averageProgress'] * 100).toInt()}%',
                      color: Colors.orange,
                    ),
                    _AnalyticsRow(
                      label: 'Overdue Projects',
                      value: projectStats['overdue'].toString(),
                      color: Colors.red,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),

              // Tasks Analytics
              const _SectionHeader(
                title: 'Tasks Analytics',
                subtitle: 'Task completion and time tracking',
              ),
              const SizedBox(height: 20),
              Obx(() {
                final taskStats = tasksController.getTaskStats();
                return _AnalyticsCard(
                  title: 'Tasks Overview',
                  icon: Icons.task_alt_rounded,
                  iconColor: Colors.green,
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
                      value:
                          '${taskStats['totalTimeSpent'].toStringAsFixed(1)}h',
                      color: Colors.purple,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _AnalyticsCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
