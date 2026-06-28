import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:micro_society_app/models/issue_model.dart';
import 'package:micro_society_app/services/firestore_service.dart';

class IssueProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<IssueModel> _issues = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _issuesSubscription;

  List<IssueModel> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void streamIssuesByBuilding(String buildingCode) {
    _issuesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _issuesSubscription = _firestoreService
        .streamDocuments(
          collection: 'issues',
          field: 'buildingCode',
          isEqualTo: buildingCode,
          orderByField: 'createdAt',
          descending: true,
        )
        .listen((data) {
          _issues = data
              .map((d) => IssueModel.fromMap(d, d['id'] as String))
              .toList();
          _isLoading = false;
          notifyListeners();
        });
  }

  void streamIssuesByTenant(String tenantId) {
    _issuesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _issuesSubscription = _firestoreService
        .streamDocuments(
          collection: 'issues',
          field: 'tenantId',
          isEqualTo: tenantId,
          orderByField: 'createdAt',
          descending: true,
        )
        .listen((data) {
          _issues = data
              .map((d) => IssueModel.fromMap(d, d['id'] as String))
              .toList();
          _isLoading = false;
          notifyListeners();
        });
  }

  Future<String?> addIssue(IssueModel issue) async {
    try {
      await _firestoreService.setDocument(
        collection: 'issues',
        docId: issue.issueId,
        data: issue.toMap(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateIssue(
      String issueId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'issues',
        docId: issueId,
        data: data,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  void dispose() {
    _issuesSubscription?.cancel();
    super.dispose();
  }
}
