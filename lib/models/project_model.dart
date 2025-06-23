import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'project_model.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  ProjectStatus status;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime lastUpdated;

  @HiveField(6)
  List<String> notes;

  @HiveField(7)
  String? abandonReason;

  @HiveField(8)
  List<StatusChange> statusHistory;

  Project({
    String? id,
    required this.name,
    required this.description,
    required this.status,
    DateTime? createdAt,
    DateTime? lastUpdated,
    List<String>? notes,
    this.abandonReason,
    List<StatusChange>? statusHistory,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now(),
        notes = notes ?? [],
        statusHistory = statusHistory ?? [];

  int get daysSinceLastUpdate {
    return DateTime.now().difference(lastUpdated).inDays;
  }

  String get daysSinceLastUpdateText {
    final days = daysSinceLastUpdate;
    if (days == 0) return 'Updated today';
    if (days == 1) return 'Updated yesterday';
    return 'Updated $days days ago';
  }

  void updateStatus(ProjectStatus newStatus, {String? reason}) {
    statusHistory.add(StatusChange(
      from: status,
      to: newStatus,
      timestamp: DateTime.now(),
      reason: reason,
    ));
    status = newStatus;
    lastUpdated = DateTime.now();

    if (newStatus == ProjectStatus.abandoned && reason != null) {
      abandonReason = reason;
    }
  }

  void addNote(String note) {
    notes.add('${DateTime.now().toIso8601String()}|$note');
    lastUpdated = DateTime.now();
  }

  List<Map<String, dynamic>> get parsedNotes {
    return notes.map((note) {
      final parts = note.split('|');
      return {
        'timestamp': DateTime.parse(parts[0]),
        'note': parts.length > 1 ? parts[1] : '',
      };
    }).toList()
      ..sort((a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
  }
}

@HiveType(typeId: 1)
enum ProjectStatus {
  @HiveField(0)
  building,

  @HiveField(1)
  stuck,

  @HiveField(2)
  shipped,

  @HiveField(3)
  abandoned
}

@HiveType(typeId: 2)
class StatusChange {
  @HiveField(0)
  final ProjectStatus from;

  @HiveField(1)
  final ProjectStatus to;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? reason;

  StatusChange({
    required this.from,
    required this.to,
    required this.timestamp,
    this.reason,
  });
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.building:
        return 'Building';
      case ProjectStatus.stuck:
        return 'Stuck';
      case ProjectStatus.shipped:
        return 'Shipped';
      case ProjectStatus.abandoned:
        return 'Abandoned';
    }
  }

  String get emoji {
    switch (this) {
      case ProjectStatus.building:
        return '🔨';
      case ProjectStatus.stuck:
        return '😰';
      case ProjectStatus.shipped:
        return '🚀';
      case ProjectStatus.abandoned:
        return '💀';
    }
  }

  String get description {
    switch (this) {
      case ProjectStatus.building:
        return 'Making progress';
      case ProjectStatus.stuck:
        return 'Hit a roadblock';
      case ProjectStatus.shipped:
        return 'It\'s alive!';
      case ProjectStatus.abandoned:
        return 'Another one bites the dust';
    }
  }
}
