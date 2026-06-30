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

  List<IssueModel> get sortedIssues {
    final copy = List<IssueModel>.from(_issues);
    copy.sort((a, b) {
      const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      final pa = priorityOrder[a.priority] ?? 3;
      final pb = priorityOrder[b.priority] ?? 3;
      if (pa != pb) return pa.compareTo(pb);
      return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
    });
    return copy;
  }

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
        .listen(
      (data) {
        _issues = data
            .map((d) => IssueModel.fromMap(d, d['id'] as String))
            .toList();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load issues';
        notifyListeners();
      },
    );
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
        .listen(
      (data) {
        _issues = data
            .map((d) => IssueModel.fromMap(d, d['id'] as String))
            .toList();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load issues';
        notifyListeners();
      },
    );
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

  Future<String?> deleteIssue(String issueId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: 'issues',
        docId: issueId,
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
