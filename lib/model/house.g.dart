// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HouseAdapter extends TypeAdapter<House> {
  @override
  final int typeId = 0;

  @override
  House read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return House(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
    )
      ..riskAssessmentIds = (fields[3] as List).cast<String>()
      ..hazard = fields[4] as double?
      ..lat = fields[5] as double?
      ..long = fields[6] as double?;
  }

  @override
  void write(BinaryWriter writer, House obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.environment)
      ..writeByte(3)
      ..write(obj.riskAssessmentIds)
      ..writeByte(4)
      ..write(obj.hazard)
      ..writeByte(5)
      ..write(obj.lat)
      ..writeByte(6)
      ..write(obj.long);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HouseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
