enum EventType {
  click,
  keyboard,
  mouseMove,
  system,
  window
}

class RecordedEvent {
  final String id;
  final DateTime timestamp;
  final EventType type;
  final String description;
  final Offset? position;

  RecordedEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    this.position,
  });
}
