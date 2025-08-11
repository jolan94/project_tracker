import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/task.dart';
import '../controllers/tasks_controller.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  Duration _breakTime = Duration.zero;
  bool _isRunning = false;
  bool _isOnBreak = false;
  bool _isPaused = false;

  List<Duration> _workSessions = [];
  List<Duration> _breaks = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedTime();
  }

  void _initializeAnimations() {
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimationController.repeat(reverse: true);
  }

  void _loadSavedTime() {
    // Load any previously saved time for this task
    // This would typically come from a persistence layer
    setState(() {
      _elapsedTime = Duration(minutes: widget.task.actualHours * 60);
    });
  }

  void _startTimer() {
    if (_isPaused) {
      _resumeTimer();
      return;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timerAnimationController.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isOnBreak) {
          _breakTime += const Duration(seconds: 1);
        } else {
          _elapsedTime += const Duration(seconds: 1);
        }
      });
    });

    // Mark task as started if it's not already
    if (widget.task.status == TaskStatus.todo) {
      Get.find<TasksController>().markTaskAsStarted(widget.task.id);
    }
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });

    _timer?.cancel();
    _timerAnimationController.stop();
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });

    _timerAnimationController.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isOnBreak) {
          _breakTime += const Duration(seconds: 1);
        } else {
          _elapsedTime += const Duration(seconds: 1);
        }
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    _timer?.cancel();
    _timerAnimationController.stop();
    _timerAnimationController.reset();

    // Save the current session
    if (!_isOnBreak && _elapsedTime > Duration.zero) {
      _workSessions.add(_elapsedTime);
    }

    _saveTimeToTask();
  }

  void _toggleBreak() {
    setState(() {
      _isOnBreak = !_isOnBreak;
    });

    if (_isOnBreak) {
      // Starting a break
      _breaks.add(Duration.zero);
    } else {
      // Ending a break
      if (_breaks.isNotEmpty) {
        _breaks[_breaks.length - 1] = _breakTime;
      }
      _breakTime = Duration.zero;
    }
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _elapsedTime = Duration.zero;
      _breakTime = Duration.zero;
      _workSessions.clear();
      _breaks.clear();
    });
  }

  void _saveTimeToTask() {
    final totalHours = _elapsedTime.inMinutes / 60;
    final updatedTask = widget.task.copyWith(actualHours: totalHours.ceil());
    Get.find<TasksController>().updateTask(updatedTask);
  }

  void _editTask() {
    Get.to(() => TaskFormScreen(task: widget.task))?.then((_) {
      // Refresh the screen if task was updated
      setState(() {});
    });
  }

  void _deleteTask() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.find<TasksController>().deleteTask(widget.task.id);
              Get.back(); // Close dialog
              Get.back(); // Go back to tasks screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.testing:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.blocked:
        return Colors.red;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Task Timer',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: _editTask,
                    icon: Icon(
                      Icons.edit_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: _deleteTask,
                    icon: const Icon(Icons.delete_rounded, color: Colors.red),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Task Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    widget.task.status,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      widget.task.status,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  widget.task.statusDisplayName,
                                  style: TextStyle(
                                    color: _getStatusColor(widget.task.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(
                                    widget.task.priority,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getPriorityColor(
                                      widget.task.priority,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  widget.task.priority.name.toUpperCase(),
                                  style: TextStyle(
                                    color: _getPriorityColor(
                                      widget.task.priority,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.task.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          if (widget.task.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              widget.task.description,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                    height: 1.5,
                                  ),
                            ),
                          ],
                          if (widget.task.dueDate != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Due: ${widget.task.dueDate!.day}/${widget.task.dueDate!.month}/${widget.task.dueDate!.year}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Timer Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
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
                      child: Column(
                        children: [
                          // Timer Circle
                          AnimatedBuilder(
                            animation: _isRunning
                                ? _pulseAnimation
                                : _timerAnimationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isRunning ? _pulseAnimation.value : 1.0,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: _isRunning
                                          ? _isOnBreak
                                                ? [
                                                    Colors.orange.shade400,
                                                    Colors.orange.shade600,
                                                  ]
                                                : [
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.7),
                                                  ]
                                          : [
                                              Colors.grey.shade400,
                                              Colors.grey.shade600,
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (_isRunning
                                                    ? _isOnBreak
                                                          ? Colors.orange
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                    : Colors.grey)
                                                .withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isOnBreak ? 'BREAK' : 'WORK',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatDuration(
                                            _isOnBreak
                                                ? _breakTime
                                                : _elapsedTime,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Control Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Start/Pause/Resume Button
                              ElevatedButton(
                                onPressed: _isRunning
                                    ? _pauseTimer
                                    : _startTimer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isRunning
                                      ? Colors.orange
                                      : Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isRunning
                                          ? _isPaused
                                                ? Icons.play_arrow_rounded
                                                : Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isRunning
                                          ? _isPaused
                                                ? 'Resume'
                                                : 'Pause'
                                          : 'Start',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Stop Button
                              if (_isRunning || _isPaused)
                                ElevatedButton(
                                  onPressed: _stopTimer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.stop_rounded, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Stop',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Break Button
                          if (_isRunning)
                            ElevatedButton(
                              onPressed: _toggleBreak,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isOnBreak
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isOnBreak
                                        ? Icons.work_rounded
                                        : Icons.coffee_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isOnBreak ? 'End Break' : 'Take Break',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Reset Button
                          if (!_isRunning && _elapsedTime > Duration.zero)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: TextButton(
                                onPressed: _resetTimer,
                                child: Text(
                                  'Reset Timer',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Session Summary
                    if (_workSessions.isNotEmpty || _breaks.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session Summary',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Work Sessions',
                                    '${_workSessions.length}',
                                    Icons.work_rounded,
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Breaks Taken',
                                    '${_breaks.length}',
                                    Icons.coffee_rounded,
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryItem(
                              'Total Time',
                              _formatDuration(_elapsedTime),
                              Icons.schedule_rounded,
                              Colors.green,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
