import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:micro_society_app/models/flat_model.dart';
import 'package:micro_society_app/models/user_model.dart';
import 'package:micro_society_app/services/firestore_service.dart';

class PendingRequest {
  final UserModel tenant;
  final FlatModel flat;

  const PendingRequest({
    required this.tenant,
    required this.flat,
  });
}

class TenantRequestProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<PendingRequest> _pendingRequests = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _usersSubscription;
  StreamSubscription? _flatsSubscription;

  List<PendingRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void streamPendingTenants(String buildingCode) {
    _usersSubscription?.cancel();
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
          (flatData) {
            final flats = <String, FlatModel>{};
            for (final d in flatData) {
              final flat = FlatModel.fromMap(d, d['id'] as String);
              flats[flat.flatId] = flat;
            }

            _usersSubscription?.cancel();
            _usersSubscription = _firestoreService
                .streamDocuments(
                  collection: 'users',
                  field: 'buildingCode',
                  isEqualTo: buildingCode,
                )
                .listen(
                  (userData) {
                    final result = <PendingRequest>[];
                    for (final d in userData) {
                      final user = UserModel.fromMap(d, d['id'] as String);
                      if (user.role == 'tenant' && !user.approved) {
                        final flatId = user.flatId;
                        final flat = flatId != null ? flats[flatId] : null;
                        if (flat != null) {
                          result.add(PendingRequest(
                            tenant: user,
                            flat: flat,
                          ));
                        }
                      }
                    }
                    _pendingRequests = result;
                    _isLoading = false;
                    _errorMessage = null;
                    notifyListeners();
                  },
                  onError: (error) {
                    _isLoading = false;
                    _errorMessage = 'Failed to load pending tenants';
                    notifyListeners();
                  },
                );
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Failed to load flats';
            notifyListeners();
          },
        );
  }

  Future<String?> approveTenant({
    required String tenantId,
    required String flatId,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'users',
        docId: tenantId,
        data: {'approved': true},
      );
      await _firestoreService.updateDocument(
        collection: 'flats',
        docId: flatId,
        data: {'status': 'occupied'},
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> rejectTenant({
    required String tenantId,
    required String flatId,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'users',
        docId: tenantId,
        data: {'buildingCode': null, 'flatId': null},
      );
      await _firestoreService.updateDocument(
        collection: 'flats',
        docId: flatId,
        data: {'tenantId': null, 'status': 'vacant'},
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _flatsSubscription?.cancel();
    super.dispose();
  }
}
