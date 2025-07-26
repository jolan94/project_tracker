import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ideas_controller.dart';
import '../data/models/idea.dart';

class IdeaFormScreen extends StatefulWidget {
  final Idea? idea;

  const IdeaFormScreen({super.key, this.idea});

  @override
  State<IdeaFormScreen> createState() => _IdeaFormScreenState();
}

class _IdeaFormScreenState extends State<IdeaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();

  IdeaPriority _selectedPriority = IdeaPriority.medium;
  IdeaStatus _selectedStatus = IdeaStatus.backlog;
  double _marketSize = 5.0;
  double _competition = 5.0;
  double _feasibility = 5.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.idea != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final idea = widget.idea!;
    _titleController.text = idea.title;
    _descriptionController.text = idea.description;
    _tagsController.text = idea.tags.join(', ');
    _notesController.text = idea.notes;
    _marketSize = idea.marketSize.toDouble();
    _competition = idea.competition.toDouble();
    _feasibility = idea.feasibility.toDouble();
    _selectedPriority = idea.priority;
    _selectedStatus = idea.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.idea == null ? 'New Idea' : 'Edit Idea'),
        actions: [
          if (widget.idea != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteIdea,
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

              // Priority
              DropdownButtonFormField<IdeaPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: IdeaPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(_getPriorityLabel(priority)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<IdeaStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: IdeaStatus.values.map((status) {
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

              // Rating Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Idea Evaluation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Market Size Slider
                    _buildRatingSlider(
                      'Market Sales Potential',
                      'How big is the market opportunity?',
                      _marketSize,
                      Icons.trending_up,
                      Colors.green,
                      (value) => setState(() => _marketSize = value),
                    ),
                    const SizedBox(height: 20),
                    
                    // Competition Slider
                    _buildRatingSlider(
                      'Competition Level',
                      'How competitive is this market?',
                      _competition,
                      Icons.people,
                      Colors.orange,
                      (value) => setState(() => _competition = value),
                    ),
                    const SizedBox(height: 20),
                    
                    // Feasibility Slider
                    _buildRatingSlider(
                      'Feasibility',
                      'How feasible is this idea to implement?',
                      _feasibility,
                      Icons.build,
                      Colors.blue,
                      (value) => setState(() => _feasibility = value),
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
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveIdea,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.idea == null ? 'Create Idea' : 'Update Idea'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSlider(
    String title,
    String description,
    double value,
    IconData icon,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                '${value.round()}/10',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
            valueIndicatorColor: color,
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _getPriorityLabel(IdeaPriority priority) {
    switch (priority) {
      case IdeaPriority.low:
        return 'Low';
      case IdeaPriority.medium:
        return 'Medium';
      case IdeaPriority.high:
        return 'High';
    }
  }

  String _getStatusLabel(IdeaStatus status) {
    switch (status) {
      case IdeaStatus.backlog:
        return 'Backlog';
      case IdeaStatus.validated:
        return 'Validated';
      case IdeaStatus.archived:
        return 'Archived';
    }
  }

  void _saveIdea() async {
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

      final marketSize = _marketSize.round();
      final competition = _competition.round();
      final feasibility = _feasibility.round();

      final notes = _notesController.text.trim();

      if (widget.idea == null) {
        // Create new idea
        final idea = Idea(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          status: _selectedStatus,
          tags: tags,
          marketSize: marketSize,
          competition: competition,
          feasibility: feasibility,
          notes: notes,
        );

        await Get.find<IdeasController>().addIdea(idea);
        Get.back();
        Get.snackbar(
          'Success',
          'Idea created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Update existing idea
        final updatedIdea = widget.idea!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          status: _selectedStatus,
          tags: tags,
          marketSize: marketSize,
          competition: competition,
          feasibility: feasibility,
          notes: notes,
        );

        await Get.find<IdeasController>().updateIdea(updatedIdea);
        Get.back();
        Get.snackbar(
          'Success',
          'Idea updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save idea: $e',
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

  void _deleteIdea() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Idea'),
        content: const Text('Are you sure you want to delete this idea?'),
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
        await Get.find<IdeasController>().deleteIdea(widget.idea!.id);
        Get.back();
        Get.snackbar(
          'Success',
          'Idea deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete idea: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}