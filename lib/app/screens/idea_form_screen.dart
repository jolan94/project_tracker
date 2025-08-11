import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.idea == null ? 'New Idea' : 'Edit Idea'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (widget.idea != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteIdea,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionHeader('Basic Information', Icons.lightbulb_outline),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Idea Title',
                      hint: 'Enter a compelling title for your idea',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe your idea in detail',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Classification Section
                    _buildSectionHeader('Classification', Icons.flag_outlined),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<IdeaPriority>(
                            value: _selectedPriority,
                            label: 'Priority',
                            items: IdeaPriority.values,
                            itemBuilder: (priority) => _getPriorityLabel(priority),
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown<IdeaStatus>(
                            value: _selectedStatus,
                            label: 'Status',
                            items: IdeaStatus.values,
                            itemBuilder: (status) => _getStatusLabel(status),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Market Analysis Section
                    _buildSectionHeader('Market Analysis', Icons.analytics_outlined),
                    const SizedBox(height: 20),
                    _buildRatingSlider(
                      'Market Sales Potential',
                      'How big is the market opportunity?',
                      _marketSize,
                      Icons.trending_up,
                      Colors.green,
                      (value) => setState(() => _marketSize = value),
                    ),
                    const SizedBox(height: 24),
                    _buildRatingSlider(
                      'Competition Level',
                      'How competitive is this market?',
                      _competition,
                      Icons.people,
                      Colors.orange,
                      (value) => setState(() => _competition = value),
                    ),
                    const SizedBox(height: 24),
                    _buildRatingSlider(
                      'Feasibility',
                      'How feasible is this idea to implement?',
                      _feasibility,
                      Icons.build,
                      Colors.blue,
                      (value) => setState(() => _feasibility = value),
                    ),
                    const SizedBox(height: 32),

                    // Additional Information Section
                    _buildSectionHeader('Additional Information', Icons.info_outline),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _tagsController,
                      label: 'Tags',
                      hint: 'Enter tags separated by commas (e.g., mobile, ai, saas)',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Additional notes and observations',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Bottom Save Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveIdea,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.idea == null ? 'Create Idea' : 'Update Idea',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
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
                  title,
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
                  '${value.round()}/10',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
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
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
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
        
        // Calculate validation score
        idea.updateValidationScore();

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
        
        // Calculate validation score
        updatedIdea.updateValidationScore();

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