class EventModel {
  final String eventId;
  final String buildingCode;
  final String title;
  final String description;
  final DateTime? eventDate;
  final DateTime? createdAt;

  const EventModel({
    required this.eventId,
    required this.buildingCode,
    required this.title,
    required this.description,
    this.eventDate,
    this.createdAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String eventId) {
    return EventModel(
      eventId: eventId,
      buildingCode: map['buildingCode'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      eventDate: (map['eventDate'] as dynamic)?.toDate(),
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buildingCode': buildingCode,
      'title': title,
      'description': description,
      'eventDate': eventDate ?? DateTime.now(),
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  EventModel copyWith({
    String? eventId,
    String? buildingCode,
    String? title,
    String? description,
    DateTime? eventDate,
    DateTime? createdAt,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      buildingCode: buildingCode ?? this.buildingCode,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
