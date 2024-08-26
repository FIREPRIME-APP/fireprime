class Event {
  final String eventId;
  double probability;

  Event({required this.eventId, required this.probability});

  String getEventId() {
    return eventId;
  }

  double calculateProbability() {
    return probability;
  }
}
