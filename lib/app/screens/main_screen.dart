import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../controllers/ideas_controller.dart';
import '../controllers/projects_controller.dart';
import '../controllers/tasks_controller.dart';
import '../widgets/filter_sort_widget.dart';
import '../data/models/idea.dart';
import '../data/models/project.dart';
import '../data/models/task.dart';
import 'dashboard_screen.dart';
import 'ideas_screen.dart';
import 'projects_screen.dart';
import 'tasks_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'kanban_board_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text(
          _getScreenTitle(appController.currentIndex),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: _getScreenActions(appController.currentIndex),
      ),
      body: IndexedStack(
        index: appController.currentIndex,
        children: const [
          DashboardScreen(),
          IdeasScreen(),
          ProjectsScreen(),
          TasksScreen(),
          AnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: appController.currentIndex,
        onTap: appController.changeTab,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outlined),
            activeIcon: Icon(Icons.lightbulb),
            label: 'Ideas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    ));
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Ideas';
      case 2:
        return 'Projects';
      case 3:
        return 'Tasks';
      case 4:
        return 'Analytics';
      default:
        return 'BuildTrack';
    }
   }

  List<Widget> _getScreenActions(int index) {
    switch (index) {
      case 0: // Dashboard
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh dashboard data
              Get.find<IdeasController>().loadIdeas();
              Get.find<ProjectsController>().loadProjects();
              Get.find<TasksController>().loadTasks();
            },
          ),
        ];
      case 1: // Ideas
        return [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showIdeasFilter(),
          ),
        ];
      case 2: // Projects
        return [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showProjectsFilter(),
          ),
        ];
      case 3: // Tasks
        return [
          IconButton(
            icon: const Icon(Icons.view_kanban),
            onPressed: () {
              Get.to(() => const KanbanBoardScreen());
            },
            tooltip: 'Kanban View',
          ),

          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showTasksFilter(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'toggle_completed') {
                Get.find<TasksController>().toggleShowCompletedTasks();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_completed',
                child: Obx(() {
                  final controller = Get.find<TasksController>();
                  return Row(
                    children: [
                      Icon(
                        controller.showCompletedTasks 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.showCompletedTasks 
                            ? 'Hide Completed' 
                            : 'Show Completed',
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ];
      case 4: // Analytics
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh analytics data
              final ideasController = Get.find<IdeasController>();
              final projectsController = Get.find<ProjectsController>();
              final tasksController = Get.find<TasksController>();
              ideasController.loadIdeas();
              projectsController.loadProjects();
              tasksController.loadTasks();
            },
          ),
          IconButton(
            onPressed: () => Get.to(() => const SettingsScreen()),
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ];
      default:
        return [];
    }
  }

  void _showIdeasFilter() {
    final controller = Get.find<IdeasController>();
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => FilterSortWidget(
        type: FilterSortType.ideas,
        currentFilters: controller.currentFilters,
        currentSort: controller.currentSort,
        onFiltersChanged: (data) {
          controller.updateFiltersAndSort(data);
        },
      ),
    );
  }

  void _showProjectsFilter() {
    final controller = Get.find<ProjectsController>();
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => FilterSortWidget(
        type: FilterSortType.projects,
        currentFilters: controller.currentFilters,
        currentSort: controller.currentSort,
        onFiltersChanged: (data) {
          controller.updateFiltersAndSort(data);
        },
      ),
    );
  }

  void _showTasksFilter() {
    final controller = Get.find<TasksController>();
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => FilterSortWidget(
        type: FilterSortType.tasks,
        currentFilters: controller.currentFilters,
        currentSort: controller.currentSort,
        onFiltersChanged: (data) {
          controller.updateFiltersAndSort(data);
        },
      ),
    );
  }
}