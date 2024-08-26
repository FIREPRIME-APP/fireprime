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

  void setProbability(double probability) {
    this.probability = probability;
  }
}
