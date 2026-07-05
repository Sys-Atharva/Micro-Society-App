import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:micro_society_app/models/payment_request_model.dart';
import 'package:micro_society_app/services/firestore_service.dart';

class PaymentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<PaymentRequestModel> _paymentRequests = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _paymentSubscription;

  List<PaymentRequestModel> get paymentRequests => _paymentRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<PaymentRequestModel> getPaymentsByFlat(String flatId) {
    return _paymentRequests
        .where((p) => p.flatId == flatId)
        .toList();
  }

  void streamPaymentRequestsByBuilding(String buildingCode) {
    _paymentSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _paymentSubscription = _firestoreService
        .streamDocuments(
          collection: 'payments',
          field: 'buildingCode',
          isEqualTo: buildingCode,
          orderByField: 'createdAt',
          descending: true,
        )
        .listen(
          (data) {
            _paymentRequests = data
                .map((d) =>
                    PaymentRequestModel.fromMap(d, d['id'] as String))
                .toList();
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Failed to load payment requests';
            notifyListeners();
          },
        );
  }

  void streamPaymentRequestsByTenant(String tenantId) {
    _paymentSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _paymentSubscription = _firestoreService
        .streamDocuments(
          collection: 'payments',
          field: 'tenantId',
          isEqualTo: tenantId,
          orderByField: 'createdAt',
          descending: true,
        )
        .listen(
          (data) {
            _paymentRequests = data
                .map((d) =>
                    PaymentRequestModel.fromMap(d, d['id'] as String))
                .toList();
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Failed to load payment history';
            notifyListeners();
          },
        );
  }

  Future<String?> createPaymentRequest(
      Map<String, dynamic> data) async {
    try {
      await _firestoreService.setDocument(
        collection: 'payments',
        docId:
            '${data['buildingCode']}_${data['tenantId']}_${DateTime.now().millisecondsSinceEpoch}',
        data: data,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updatePaymentStatus({
    required String paymentId,
    required String status,
    String? ownerNote,
  }) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (ownerNote != null) {
        data['ownerNote'] = ownerNote;
      }
      if (status == 'approved') {
        data['paidDate'] = DateTime.now();
      }
      await _firestoreService.updateDocument(
        collection: 'payments',
        docId: paymentId,
        data: data,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  void dispose() {
    _paymentSubscription?.cancel();
    super.dispose();
  }
}
