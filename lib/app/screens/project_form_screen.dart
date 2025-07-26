import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/projects_controller.dart';
import '../data/models/project.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _revenueController = TextEditingController();
  final _userCountController = TextEditingController();

  ProjectStatus _selectedStatus = ProjectStatus.planning;
  DateTime? _selectedDueDate;
  bool _isLoading = false;
  
  // Slider values
  double _progress = 0.0;
  double _monthlyRevenue = 0.0;
  double _userCount = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final project = widget.project!;
    _titleController.text = project.title;
    _descriptionController.text = project.description;
    _tagsController.text = project.tags.join(', ');
    _revenueController.text = project.monthlyRevenue.toString();
    _userCountController.text = project.userCount.toString();
    _selectedStatus = project.status;
    _selectedDueDate = project.dueDate;
    
    // Initialize slider values
    _progress = project.progress;
    _monthlyRevenue = project.monthlyRevenue;
    _userCount = project.userCount.toDouble();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Edit Project'),
        actions: [
          if (widget.project != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProject,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<ProjectStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ProjectStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusLabel(status)),
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
              const SizedBox(height: 16),

              // Due Date
              InkWell(
                onTap: _selectDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDueDate != null
                        ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                        : 'Select due date',
                    style: _selectedDueDate != null
                        ? null
                        : TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress, Revenue, and User Count Sliders
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildProjectSlider(
                      'Progress',
                      _progress,
                      0.0,
                      1.0,
                      Icons.trending_up,
                      Colors.green,
                      (value) => setState(() => _progress = value),
                      suffix: '%',
                      displayValue: (_progress * 100).round().toString(),
                    ),
                    const SizedBox(height: 20),
                    _buildProjectSlider(
                      'Monthly Revenue',
                      _monthlyRevenue,
                      0.0,
                      100000.0,
                      Icons.attach_money,
                      Colors.blue,
                      (value) => setState(() => _monthlyRevenue = value),
                      prefix: '\$',
                      displayValue: _monthlyRevenue.round().toString(),
                    ),
                    const SizedBox(height: 20),
                    _buildProjectSlider(
                      'User Count',
                      _userCount,
                      0.0,
                      1000000.0,
                      Icons.people,
                      Colors.orange,
                      (value) => setState(() => _userCount = value),
                      displayValue: _userCount.round().toString(),
                    ),
                  ],
                ),
               ),
              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  border: OutlineInputBorder(),
                  helperText: 'Separate tags with commas',
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProject,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.project == null ? 'Create Project' : 'Update Project'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
      case ProjectStatus.onHold:
        return 'On Hold';
    }
  }

  Widget _buildProjectSlider(
    String label,
    double value,
    double min,
    double max,
    IconData icon,
    Color color,
    ValueChanged<double> onChanged, {
    String? prefix,
    String? suffix,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${prefix ?? ''}$displayValue${suffix ?? ''}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
            valueIndicatorColor: color,
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final revenue = _monthlyRevenue;
      final userCount = _userCount.round();

      if (widget.project == null) {
        // Create new project
        final project = Project(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          progress: _progress,
          tags: tags,
          dueDate: _selectedDueDate,
          monthlyRevenue: revenue,
          userCount: userCount,
        );

        await Get.find<ProjectsController>().addProject(project);
        Get.back();
        Get.snackbar(
          'Success',
          'Project created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Update existing project
        final updatedProject = widget.project!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          progress: _progress,
          tags: tags,
          dueDate: _selectedDueDate,
          monthlyRevenue: revenue,
          userCount: userCount,
        );

        await Get.find<ProjectsController>().updateProject(updatedProject);
        Get.back();
        Get.snackbar(
          'Success',
          'Project updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save project: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteProject() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Get.find<ProjectsController>().deleteProject(widget.project!.id);
        Get.back();
        Get.snackbar(
          'Success',
          'Project deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete project: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}