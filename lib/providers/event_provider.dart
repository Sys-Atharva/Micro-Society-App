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
        .listen((data) {
          _events = data
              .map((d) => EventModel.fromMap(d, d['id'] as String))
              .toList();
          _isLoading = false;
          notifyListeners();
        });
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

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}
