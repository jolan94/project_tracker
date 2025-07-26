import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'idea.g.dart';

@HiveType(typeId: 0)
class Idea extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> tags;

  @HiveField(4)
  IdeaPriority priority;

  @HiveField(5)
  IdeaStatus status;

  @HiveField(6)
  int validationScore;

  @HiveField(7)
  int marketSize;

  @HiveField(8)
  int competition;

  @HiveField(9)
  int feasibility;

  @HiveField(10)
  List<String> attachments;

  @HiveField(11)
  String notes;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime updatedAt;

  Idea({
    String? id,
    required this.title,
    required this.description,
    this.tags = const [],
    this.priority = IdeaPriority.medium,
    this.status = IdeaStatus.backlog,
    this.validationScore = 0,
    this.marketSize = 0,
    this.competition = 0,
    this.feasibility = 0,
    this.attachments = const [],
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  void updateValidationScore() {
    validationScore = ((marketSize + (10 - competition) + feasibility) / 3).round();
  }

  Idea copyWith({
    String? title,
    String? description,
    List<String>? tags,
    IdeaPriority? priority,
    IdeaStatus? status,
    int? validationScore,
    int? marketSize,
    int? competition,
    int? feasibility,
    List<String>? attachments,
    String? notes,
  }) {
    return Idea(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      validationScore: validationScore ?? this.validationScore,
      marketSize: marketSize ?? this.marketSize,
      competition: competition ?? this.competition,
      feasibility: feasibility ?? this.feasibility,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags,
      'priority': priority.name,
      'status': status.name,
      'validationScore': validationScore,
      'marketSize': marketSize,
      'competition': competition,
      'feasibility': feasibility,
      'attachments': attachments,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      priority: IdeaPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => IdeaPriority.medium,
      ),
      status: IdeaStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IdeaStatus.backlog,
      ),
      validationScore: json['validationScore'] ?? 0,
      marketSize: json['marketSize'] ?? 0,
      competition: json['competition'] ?? 0,
      feasibility: json['feasibility'] ?? 0,
      attachments: List<String>.from(json['attachments'] ?? []),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

@HiveType(typeId: 1)
enum IdeaPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 2)
enum IdeaStatus {
  @HiveField(0)
  backlog,
  @HiveField(1)
  validated,
  @HiveField(2)
  archived,
}