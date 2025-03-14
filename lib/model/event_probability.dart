import 'package:hive/hive.dart';

part 'event_probability.g.dart';

@HiveType(typeId: 2)
class EventProbability {
  @HiveField(0)
  String eventId;
  @HiveField(1)
  double probability;
  @HiveField(2)
  Map<String, EventProbability>? subEvents = {};

  EventProbability(this.eventId, this.probability, this.subEvents);
}
