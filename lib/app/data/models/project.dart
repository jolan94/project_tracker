import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'task.dart';

part 'project.g.dart';

@HiveType(typeId: 3)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  ProjectStatus status;

  @HiveField(4)
  double progress;

  @HiveField(5)
  double monthlyRevenue;

  @HiveField(6)
  int userCount;

  @HiveField(7)
  DateTime? dueDate;

  @HiveField(8)
  List<String> tags;

  @HiveField(9)
  String? ideaId; // Reference to the original idea

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  String? imageUrl;

  @HiveField(13)
  List<String> taskIds; // References to tasks

  Project({
    String? id,
    required this.title,
    required this.description,
    this.status = ProjectStatus.planning,
    this.progress = 0.0,
    this.monthlyRevenue = 0.0,
    this.userCount = 0,
    this.dueDate,
    this.tags = const [],
    this.ideaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.imageUrl,
    this.taskIds = const [],
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Project copyWith({
    String? title,
    String? description,
    ProjectStatus? status,
    double? progress,
    double? monthlyRevenue,
    int? userCount,
    DateTime? dueDate,
    List<String>? tags,
    String? ideaId,
    String? imageUrl,
    List<String>? taskIds,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      userCount: userCount ?? this.userCount,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      ideaId: ideaId ?? this.ideaId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      imageUrl: imageUrl ?? this.imageUrl,
      taskIds: taskIds ?? this.taskIds,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get progressPercentage => '${(progress * 100).toInt()}%';

  String get revenueDisplay {
    if (monthlyRevenue == 0) return '\$0 MRR';
    if (monthlyRevenue >= 1000) {
      return '\$${(monthlyRevenue / 1000).toStringAsFixed(1)}K MRR';
    }
    return '\$${monthlyRevenue.toInt()} MRR';
  }

  String get userCountDisplay {
    if (userCount == 0) return '0 users';
    if (userCount >= 1000) {
      return '${(userCount / 1000).toStringAsFixed(1)}K users';
    }
    return '$userCount users';
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != ProjectStatus.completed;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'progress': progress,
      'monthlyRevenue': monthlyRevenue,
      'userCount': userCount,
      'dueDate': dueDate?.toIso8601String(),
      'tags': tags,
      'ideaId': ideaId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'taskIds': taskIds,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      progress: (json['progress'] ?? 0.0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0.0).toDouble(),
      userCount: json['userCount'] ?? 0,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      ideaId: json['ideaId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      imageUrl: json['imageUrl'],
      taskIds: List<String>.from(json['taskIds'] ?? []),
    );
  }
}

@HiveType(typeId: 4)
enum ProjectStatus {
  @HiveField(0)
  planning,
  @HiveField(1)
  active,
  @HiveField(2)
  completed,
  @HiveField(3)
  onHold,
  @HiveField(4)
  cancelled,
}