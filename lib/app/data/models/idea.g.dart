// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaAdapter extends TypeAdapter<Idea> {
  @override
  final int typeId = 0;

  @override
  Idea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Idea(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      tags: (fields[3] as List).cast<String>(),
      priority: fields[4] as IdeaPriority,
      status: fields[5] as IdeaStatus,
      validationScore: fields[6] as int,
      marketSize: fields[7] as int,
      competition: fields[8] as int,
      feasibility: fields[9] as int,
      attachments: (fields[10] as List).cast<String>(),
      notes: fields[11] as String,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Idea obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.validationScore)
      ..writeByte(7)
      ..write(obj.marketSize)
      ..writeByte(8)
      ..write(obj.competition)
      ..writeByte(9)
      ..write(obj.feasibility)
      ..writeByte(10)
      ..write(obj.attachments)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IdeaPriorityAdapter extends TypeAdapter<IdeaPriority> {
  @override
  final int typeId = 1;

  @override
  IdeaPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IdeaPriority.low;
      case 1:
        return IdeaPriority.medium;
      case 2:
        return IdeaPriority.high;
      default:
        return IdeaPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, IdeaPriority obj) {
    switch (obj) {
      case IdeaPriority.low:
        writer.writeByte(0);
        break;
      case IdeaPriority.medium:
        writer.writeByte(1);
        break;
      case IdeaPriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IdeaStatusAdapter extends TypeAdapter<IdeaStatus> {
  @override
  final int typeId = 2;

  @override
  IdeaStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IdeaStatus.backlog;
      case 1:
        return IdeaStatus.validated;
      case 2:
        return IdeaStatus.archived;
      default:
        return IdeaStatus.backlog;
    }
  }

  @override
  void write(BinaryWriter writer, IdeaStatus obj) {
    switch (obj) {
      case IdeaStatus.backlog:
        writer.writeByte(0);
        break;
      case IdeaStatus.validated:
        writer.writeByte(1);
        break;
      case IdeaStatus.archived:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
