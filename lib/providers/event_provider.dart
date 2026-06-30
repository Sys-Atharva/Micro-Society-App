import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:micro_society_app/models/event_model.dart';
import 'package:micro_society_app/services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _eventsSubscription;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<EventModel> get upcomingEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _events
        .where((e) =>
            e.status == 'upcoming' &&
            e.eventDate != null &&
            !e.eventDate!.isBefore(today))
        .toList()
      ..sort((a, b) => a.eventDate!.compareTo(b.eventDate!));
  }

  List<EventModel> get sortedEvents {
    final copy = List<EventModel>.from(_events);
    copy.sort((a, b) {
      const statusOrder = {'upcoming': 0, 'completed': 1, 'cancelled': 2};
      final sa = statusOrder[a.status] ?? 3;
      final sb = statusOrder[b.status] ?? 3;
      if (sa != sb) return sa.compareTo(sb);
      return (b.eventDate ?? DateTime(0)).compareTo(a.eventDate ?? DateTime(0));
    });
    return copy;
  }

  void streamEventsByBuilding(String buildingCode) {
    _eventsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _eventsSubscription = _firestoreService
        .streamDocuments(
          collection: 'events',
          field: 'buildingCode',
          isEqualTo: buildingCode,
          orderByField: 'eventDate',
          descending: false,
        )
        .listen(
      (data) {
        _events = data
            .map((d) => EventModel.fromMap(d, d['id'] as String))
            .toList();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load events';
        notifyListeners();
      },
    );
  }

  Future<String?> addEvent(EventModel event) async {
    try {
      await _firestoreService.setDocument(
        collection: 'events',
        docId: event.eventId,
        data: event.toMap(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateEvent(
      String eventId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'events',
        docId: eventId,
        data: data,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteEvent(String eventId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: 'events',
        docId: eventId,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void checkAndAutoCompleteEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final event in _events) {
      if (event.status == 'upcoming' &&
          event.eventDate != null &&
          event.eventDate!.isBefore(today)) {
        updateEvent(event.eventId, {'status': 'completed'});
      }
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}
