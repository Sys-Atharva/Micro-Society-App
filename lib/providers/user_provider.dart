import 'package:flutter/foundation.dart';
import 'package:micro_society_app/models/user_model.dart';
import 'package:micro_society_app/services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _firestoreService.getDocument(
        collection: 'users',
        docId: uid,
      );
      if (data != null) {
        _userModel = UserModel.fromMap(data, uid);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'users',
        docId: uid,
        data: data,
      );

      if (_userModel != null) {
        _userModel = _userModel!.copyWith(
          name: data['name'] as String?,
          phone: data['phone'] as String?,
          societyName: data['societyName'] as String?,
          propertyAddress: data['propertyAddress'] as String?,
          bankDetails: data['bankDetails'] != null
              ? BankDetails.fromMap(
                  data['bankDetails'] as Map<String, dynamic>)
              : null,
        );
      }

      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> approveUser(String uid) async {
    await _firestoreService.updateDocument(
      collection: 'users',
      docId: uid,
      data: {'approved': true},
    );
  }

  Future<List<UserModel>> getTenantsByBuilding(String buildingCode) async {
    final data = await _firestoreService.getDocuments(
      collection: 'users',
      field: 'buildingCode',
      isEqualTo: buildingCode,
    );
    return data.map((d) => UserModel.fromMap(d, d['id'] as String)).toList();
  }

  Future<UserModel?> getOwnerByBuilding(String buildingCode) async {
    final data = await _firestoreService.getDocuments(
      collection: 'users',
      field: 'buildingCode',
      isEqualTo: buildingCode,
    );
    final owners = data
        .map((d) => UserModel.fromMap(d, d['id'] as String))
        .where((u) => u.role == 'owner')
        .toList();
    return owners.isNotEmpty ? owners.first : null;
  }
}
