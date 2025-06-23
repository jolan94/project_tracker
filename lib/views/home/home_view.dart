import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:project_tracker/controllers/project_controller.dart';
import 'package:project_tracker/widgets/project_card.dart';
import 'package:project_tracker/app/routes/app_routes.dart';
import 'package:project_tracker/app/theme/app_theme.dart';
import 'package:project_tracker/models/project_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectController controller = Get.put(ProjectController());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Projects'),
            Obx(
              () => Text(
                controller.statsText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        toolbarHeight: 72,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                Text(
                  _getRandomLoadingMessage(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        if (controller.projects.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            // Filter chips
            FadeInDown(
              duration: const Duration(milliseconds: 300),
              child: Container(
                height: 60,
                margin: const EdgeInsets.only(top: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    Obx(
                      () => FilterChip(
                        label: const Text('All'),
                        selected: controller.filterStatus.value == null,
                        onSelected: (_) => controller.clearFilter(),
                        backgroundColor: AppTheme.surfaceColor,
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                        side: BorderSide(
                          color: controller.filterStatus.value == null
                              ? AppTheme.primaryColor
                              : AppTheme.borderColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...ProjectStatus.values.map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Obx(
                          () => FilterChip(
                            label: Text(
                              '${status.emoji} ${status.displayName}',
                            ),
                            selected: controller.filterStatus.value == status,
                            onSelected: (_) => controller.setFilter(status),
                            backgroundColor: AppTheme.surfaceColor,
                            selectedColor: _getStatusColor(
                              status,
                            ).withOpacity(0.2),
                            checkmarkColor: _getStatusColor(status),
                            side: BorderSide(
                              color: controller.filterStatus.value == status
                                  ? _getStatusColor(status)
                                  : AppTheme.borderColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.motivationalMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.motivationalMessage,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Obx(() {
                final filteredProjects = controller.filteredProjects;
                if (filteredProjects.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        controller.filterStatus.value != null
                            ? 'No ${controller.filterStatus.value!.displayName.toLowerCase()} projects'
                            : 'No projects yet',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    return FadeInUp(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      child: ProjectCard(
                        project: project,
                        onTap: () => Get.toNamed(
                          AppRoutes.projectDetail.replaceAll(':id', project.id),
                        ),
                        onDelete: () => controller.deleteProject(project.id),
                        onAbandon: (reason) =>
                            controller.abandonProject(project.id, reason),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addProject),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BounceInDown(
              child: Icon(
                Icons.code_off,
                size: 80,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                "No projects yet?",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Text(
                "Time to start something you won't finish! 😅",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  Text(
                    "Tap + to add your first project",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Swipe left to abandon • Swipe right to delete",
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRandomLoadingMessage() {
    final messages = [
      "Counting abandoned dreams...",
      "Loading your digital graveyard...",
      "Preparing excuses...",
      "Fetching unfinished business...",
      "Collecting dust from old projects...",
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.building:
        return AppTheme.buildingColor;
      case ProjectStatus.stuck:
        return AppTheme.stuckColor;
      case ProjectStatus.shipped:
        return AppTheme.shippedColor;
      case ProjectStatus.abandoned:
        return AppTheme.abandonedColor;
    }
  }
}
