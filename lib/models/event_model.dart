class EventModel {
  final String eventId;
  final String buildingCode;
  final String title;
  final String description;
  final String location;
  final DateTime? eventDate;
  final String eventTime;
  final String status;
  final String createdBy;
  final DateTime? createdAt;

  const EventModel({
    required this.eventId,
    required this.buildingCode,
    required this.title,
    this.description = '',
    this.location = '',
    this.eventDate,
    this.eventTime = '',
    this.status = 'upcoming',
    this.createdBy = '',
    this.createdAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isUpcoming => status == 'upcoming';

  factory EventModel.fromMap(Map<String, dynamic> map, String eventId) {
    return EventModel(
      eventId: eventId,
      buildingCode: map['buildingCode'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      eventDate: (map['eventDate'] as dynamic)?.toDate(),
      eventTime: map['eventTime'] as String? ?? '',
      status: map['status'] as String? ?? 'upcoming',
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buildingCode': buildingCode,
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate ?? DateTime.now(),
      'eventTime': eventTime,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  EventModel copyWith({
    String? eventId,
    String? buildingCode,
    String? title,
    String? description,
    String? location,
    DateTime? eventDate,
    String? eventTime,
    String? status,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      buildingCode: buildingCode ?? this.buildingCode,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
