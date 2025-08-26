// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BasicResultAdapter extends TypeAdapter<BasicResult> {
  @override
  final int typeId = 3;

  @override
  BasicResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BasicResult(
      fields[0] as DateTime,
      (fields[1] as Map).cast<String, String?>(),
    )
      ..completed = fields[2] as bool
      ..fiDate = fields[3] as DateTime
      ..risk = fields[4] as int
      ..riskLevel = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, BasicResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.iniDate)
      ..writeByte(1)
      ..write(obj.answers)
      ..writeByte(2)
      ..write(obj.completed)
      ..writeByte(3)
      ..write(obj.fiDate)
      ..writeByte(4)
      ..write(obj.risk)
      ..writeByte(5)
      ..write(obj.riskLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasicResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
