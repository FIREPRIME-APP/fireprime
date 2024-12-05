// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_assessment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RiskAssessmentAdapter extends TypeAdapter<RiskAssessment> {
  @override
  final int typeId = 1;

  @override
  RiskAssessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiskAssessment(
      fields[0] as DateTime,
      fields[1] as String,
      (fields[2] as Map).cast<String, String?>(),
    )
      ..completed = fields[3] as bool
      ..fiDate = fields[4] as DateTime
      ..probability = fields[5] as double
      ..results = (fields[6] as Map).cast<String, double>()
      ..subNodeProbabilities = (fields[7] as Map?)?.map(
            (dynamic k, dynamic v) => MapEntry(
              k as String,
              (v as Map?)?.cast<String, double>() ?? {},
            ),
          ) ??
          {};
  }

  @override
  void write(BinaryWriter writer, RiskAssessment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.iniDate)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.answers)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.fiDate)
      ..writeByte(5)
      ..write(obj.probability)
      ..writeByte(6)
      ..write(obj.results)
      ..writeByte(7)
      ..write(obj.subNodeProbabilities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskAssessmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
