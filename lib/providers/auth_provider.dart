import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:micro_society_app/models/user_model.dart';
import 'package:micro_society_app/services/auth_service.dart';
import 'package:micro_society_app/services/firestore_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _firebaseUser;
  UserModel? _userModel;
  StreamSubscription<User?>? _authSubscription;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isOwner => _userModel?.role == 'owner';
  bool get isTenant => _userModel?.role == 'tenant';
  bool get isApproved => _userModel?.approved ?? false;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _userModel = null;
      notifyListeners();
      return;
    }

    _status = AuthStatus.loading;
    _firebaseUser = user;
    notifyListeners();

    await _loadUserModel(user.uid);

    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      final userData = await _firestoreService.getDocument(
        collection: 'users',
        docId: uid,
      );
      if (userData != null) {
        _userModel = UserModel.fromMap(userData, uid);
      }
    } catch (_) {}
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return e.message ?? 'Login failed';
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return 'An unexpected error occurred';
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return 'Registration failed';
      }

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        role: role,
        approved: role == 'owner',
      );

      await _firestoreService.setDocument(
        collection: 'users',
        docId: user.uid,
        data: userModel.toMap(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return e.message ?? 'Registration failed';
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return 'An unexpected error occurred';
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  Future<void> refreshUser() async {
    if (_firebaseUser != null) {
      await _loadUserModel(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
