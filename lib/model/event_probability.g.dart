// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_probability.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventProbabilityAdapter extends TypeAdapter<EventProbability> {
  @override
  final int typeId = 2;

  @override
  EventProbability read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventProbability(
      fields[0] as String,
      fields[1] as double,
      (fields[2] as Map?)?.cast<String, EventProbability>(),
    );
  }

  @override
  void write(BinaryWriter writer, EventProbability obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.probability)
      ..writeByte(2)
      ..write(obj.subEvents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventProbabilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
