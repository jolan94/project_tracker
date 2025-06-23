import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracker/controllers/project_controller.dart';
import 'package:project_tracker/models/project_model.dart';
import 'package:project_tracker/app/theme/app_theme.dart';

class AddProjectView extends StatefulWidget {
  final bool isEditing;

  const AddProjectView({
    super.key,
    this.isEditing = false,
  });

  @override
  State<AddProjectView> createState() => _AddProjectViewState();
}

class _AddProjectViewState extends State<AddProjectView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ProjectStatus _selectedStatus = ProjectStatus.building;

  late final ProjectController projectController;
  Project? editingProject;

  @override
  void initState() {
    super.initState();
    projectController = Get.find<ProjectController>();

    if (widget.isEditing) {
      final projectId = Get.parameters['id'];
      if (projectId != null) {
        editingProject = projectController.getProject(projectId);
        if (editingProject != null) {
          _nameController.text = editingProject!.name;
          _descriptionController.text = editingProject!.description;
          _selectedStatus = editingProject!.status;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProject() async {
    if (_formKey.currentState!.validate()) {
      if (widget.isEditing && editingProject != null) {
        editingProject!.name = _nameController.text.trim();
        editingProject!.description = _descriptionController.text.trim();
        editingProject!.lastUpdated = DateTime.now();

        await projectController.updateProject(editingProject!);
      } else {
        final project = Project(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
        );

        await projectController.addProject(project);
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Project' : 'Add Project'),
        actions: [
          TextButton(
            onPressed: _saveProject,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Details',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      autofocus: !widget.isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Project Name',
                        hintText: 'My Awesome App',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Project name required (we know, obvious, but still...)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'What\'s this project about?',
                        alignLabelWithHint: true,
                      ),
                    ),
                    if (!widget.isEditing) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<ProjectStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Initial Status',
                        ),
                        items: [
                          ProjectStatus.building,
                          ProjectStatus.stuck,
                        ].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Text(status.emoji),
                                const SizedBox(width: 8),
                                Text(status.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pro Tips',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Keep project names short and memorable\n'
                      '• Don\'t overthink the description\n'
                      '• Starting as "Stuck" is totally valid\n'
                      '• You can always change everything later',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
