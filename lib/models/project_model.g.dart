// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String,
      status: fields[3] as ProjectStatus,
      createdAt: fields[4] as DateTime?,
      lastUpdated: fields[5] as DateTime?,
      notes: (fields[6] as List?)?.cast<String>(),
      abandonReason: fields[7] as String?,
      statusHistory: (fields[8] as List?)?.cast<StatusChange>(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.abandonReason)
      ..writeByte(8)
      ..write(obj.statusHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatusChangeAdapter extends TypeAdapter<StatusChange> {
  @override
  final int typeId = 2;

  @override
  StatusChange read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatusChange(
      from: fields[0] as ProjectStatus,
      to: fields[1] as ProjectStatus,
      timestamp: fields[2] as DateTime,
      reason: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StatusChange obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.reason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusChangeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectStatusAdapter extends TypeAdapter<ProjectStatus> {
  @override
  final int typeId = 1;

  @override
  ProjectStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectStatus.building;
      case 1:
        return ProjectStatus.stuck;
      case 2:
        return ProjectStatus.shipped;
      case 3:
        return ProjectStatus.abandoned;
      default:
        return ProjectStatus.building;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectStatus obj) {
    switch (obj) {
      case ProjectStatus.building:
        writer.writeByte(0);
        break;
      case ProjectStatus.stuck:
        writer.writeByte(1);
        break;
      case ProjectStatus.shipped:
        writer.writeByte(2);
        break;
      case ProjectStatus.abandoned:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
