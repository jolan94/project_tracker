import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_tracker/controllers/project_controller.dart';
import 'package:project_tracker/models/project_model.dart';
import 'package:project_tracker/widgets/status_badge.dart';
import 'package:project_tracker/app/theme/app_theme.dart';
import 'package:project_tracker/app/routes/app_routes.dart';

class ProjectDetailView extends StatelessWidget {
  ProjectDetailView({super.key});

  final ProjectController projectController = Get.find<ProjectController>();

  @override
  Widget build(BuildContext context) {
    final projectId = Get.parameters['id'];
    if (projectId == null) {
      Get.back();
      return const SizedBox.shrink();
    }

    return Obx(() {
      final project = projectController.getProject(projectId);
      if (project == null) {
        Get.back();
        return const SizedBox.shrink();
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(project.name),
          actions: [
            IconButton(
              onPressed: () => Get.toNamed(
                AppRoutes.editProject.replaceAll(':id', project.id),
              ),
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Project Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Project Info',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              if (project.description.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  project.description,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ],
                          ),
                        ),
                        StatusBadge(status: project.status, large: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'Created',
                      DateFormat.yMMMd().format(project.createdAt),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Last Updated',
                      project.daysSinceLastUpdateText,
                    ),
                    if (project.abandonReason != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        'Abandon Reason',
                        project.abandonReason!,
                        icon: Icons.sentiment_very_dissatisfied,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Status Update Section
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Update',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    if (project.status != ProjectStatus.abandoned) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _showStatusUpdateSheet(context, project),
                          child: const Text('Update Status'),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: AppTheme.errorColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Project Abandoned',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppTheme.errorColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'This project has been laid to rest. RIP. 💀',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Notes Section
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IconButton(
                          onPressed: () => _showAddNoteDialog(context, project),
                          icon: const Icon(Icons.add_comment),
                        ),
                      ],
                    ),
                    if (project.notes.isEmpty) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No notes yet. Add your thoughts!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      ...project.parsedNotes.map(
                        (note) => _buildNoteItem(
                          context,
                          note['note'] as String,
                          note['timestamp'] as DateTime,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            if (project.status != ProjectStatus.abandoned) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppTheme.errorColor),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showAbandonDialog(context, project),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: const BorderSide(color: AppTheme.errorColor),
                          ),
                          child: const Text('Mark as Abandoned'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
        ],
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildNoteItem(BuildContext context, String note, DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(
            DateFormat.yMMMd().add_jm().format(timestamp),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateSheet(BuildContext context, Project project) {
    final availableStatuses = ProjectStatus.values
        .where((s) => s != project.status && s != ProjectStatus.abandoned)
        .toList();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Current: ${project.status.displayName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ...availableStatuses.map(
              (status) => ListTile(
                onTap: () {
                  projectController.updateProjectStatus(project.id, status);
                  Get.back();
                },
                leading: Text(
                  status.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(status.displayName),
                subtitle: Text(status.description),
                trailing: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, Project project) {
    final noteController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (noteController.text.trim().isNotEmpty) {
                projectController.addNote(
                  project.id,
                  noteController.text.trim(),
                );
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAbandonDialog(BuildContext context, Project project) {
    final reasons = [
      "Found something shinier ✨",
      "Imposter syndrome kicked in 😰",
      "Realized it's already been done 😅",
      "Lost interest (happens to the best of us)",
      "Went down a rabbit hole refactoring",
    ];

    String? selectedReason;
    final customReasonController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Abandon Project?'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why are you abandoning "${project.name}"?',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map(
                    (reason) => RadioListTile<String>(
                      value: reason,
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                          customReasonController.clear();
                        });
                      },
                      title: Text(reason),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  RadioListTile<String>(
                    value: 'custom',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                    title: const Text('Custom reason'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (selectedReason == 'custom') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customReasonController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Tell us why...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Keep Working'),
              ),
              TextButton(
                onPressed: () {
                  final reason = selectedReason == 'custom'
                      ? customReasonController.text.trim()
                      : selectedReason;

                  if (reason != null && reason.isNotEmpty) {
                    projectController.abandonProject(project.id, reason);
                    Get.back();
                    Get.back(); // Go back to home
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Abandon'),
              ),
            ],
          );
        },
      ),
    );
  }
}
