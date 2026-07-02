import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:micro_society_app/models/flat_model.dart';
import 'package:micro_society_app/services/firestore_service.dart';

class FlatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<FlatModel> _flats = [];
  List<FlatModel> _filteredFlats = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _statusFilter = 'All';
  StreamSubscription? _flatsSubscription;

  List<FlatModel> get flats => _filteredFlats;
  List<FlatModel> get allFlats => _flats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_statusFilter == 'All') {
      _filteredFlats = List.from(_flats);
    } else {
      _filteredFlats = _flats
          .where((flat) =>
              flat.status.toLowerCase() == _statusFilter.toLowerCase())
          .toList();
    }
  }

  void streamFlatsByBuilding(String buildingCode) {
    _flatsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _flatsSubscription = _firestoreService
        .streamDocuments(
          collection: 'flats',
          field: 'buildingCode',
          isEqualTo: buildingCode,
        )
        .listen(
          (data) {
            _flats = data
                .map((d) => FlatModel.fromMap(d, d['id'] as String))
                .toList();
            _applyFilter();
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Failed to load flats';
            notifyListeners();
          },
        );
  }

  void streamFlatsByOwner(String ownerId) {
    _flatsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _flatsSubscription = _firestoreService
        .streamDocuments(
          collection: 'flats',
          field: 'ownerId',
          isEqualTo: ownerId,
        )
        .listen(
          (data) {
            _flats = data
                .map((d) => FlatModel.fromMap(d, d['id'] as String))
                .toList();
            _applyFilter();
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Failed to load flats';
            notifyListeners();
          },
        );
  }

  Future<String?> addFlat(FlatModel flat) async {
    try {
      await _firestoreService.setDocument(
        collection: 'flats',
        docId: flat.flatId,
        data: flat.toMap(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateFlat(String flatId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'flats',
        docId: flatId,
        data: data,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteFlat(String flatId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: 'flats',
        docId: flatId,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> assignTenant({
    required String flatId,
    required String tenantId,
  }) async {
    return await updateFlat(flatId, {
      'tenantId': tenantId,
      'status': 'occupied',
    });
  }

  Future<String?> removeTenant(String flatId) async {
    return await updateFlat(flatId, {
      'tenantId': null,
      'status': 'vacant',
    });
  }

  @override
  void dispose() {
    _flatsSubscription?.cancel();
    super.dispose();
  }
}
