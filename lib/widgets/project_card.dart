import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:project_tracker/models/project_model.dart';
import 'package:project_tracker/widgets/status_badge.dart';
import 'package:project_tracker/app/theme/app_theme.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Function(String)? onAbandon;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onDelete,
    this.onAbandon,
  });

  Color get _urgencyColor {
    final days = project.daysSinceLastUpdate;
    if (days < 3) return AppTheme.successColor;
    if (days < 7) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  @override
  Widget build(BuildContext context) {
    final isAbandoned = project.status == ProjectStatus.abandoned;

    return Dismissible(
      key: Key(project.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isAbandoned ? AppTheme.errorColor : AppTheme.warningColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isAbandoned ? Icons.delete_outline : Icons.archive_outlined,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Right swipe - Delete
          return await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Delete Project?'),
                  content: Text(
                    'Are you sure you want to delete "${project.name}"?\n\n'
                    '${isAbandoned ? "It\'s already abandoned, might as well clear it out." : "This will permanently remove the project."}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Keep it'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ) ??
              false;
        } else {
          // Left swipe - Abandon (only for non-abandoned projects)
          if (!isAbandoned) {
            final reason = await _showQuickAbandonDialog(context, project);
            if (reason != null && reason.isNotEmpty) {
              onAbandon?.call(reason);
            }
          }
          return false; // Don't dismiss the card for abandon
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          if (project.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              project.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusBadge(status: project.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _urgencyColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      project.daysSinceLastUpdateText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    if (project.status == ProjectStatus.abandoned &&
                        project.abandonReason != null) ...[
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showQuickAbandonDialog(
    BuildContext context,
    Project project,
  ) async {
    final quickReasons = [
      "Too busy right now 🏃",
      "Lost motivation 😴",
      "Found a better solution 💡",
      "It's complicated... 🤷",
    ];

    return await Get.dialog<String>(
      AlertDialog(
        title: Text('Quick Abandon "${project.name}"?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Swipe left = quick abandon. Pick a reason:'),
            const SizedBox(height: 16),
            ...quickReasons.map(
              (reason) => InkWell(
                onTap: () => Get.back(result: reason),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(reason),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
