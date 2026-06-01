import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  fb.User? _firebaseUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isKycVerified => _currentUser?.isKycVerified ?? false;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    fb.FirebaseAuth.instance.authStateChanges().listen((fb.User? user) async {
      _firebaseUser = user;
      if (user != null) {
        _currentUser = await FirebaseService.getUserData(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<String?> register({
    required String email,
    required String mobile,
    required String username,
    required String password,
  }) async {
    final error = await AuthService.register(
      email: email,
      mobile: mobile,
      username: username,
      password: password,
    );
    return error;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final user = await AuthService.login(
      email: email,
      password: password,
    );
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<String?> submitKyc({
    required String fullName,
    required String dob,
    required String pan,
    required String aadhaar,
    required String address,
  }) async {
    if (_currentUser == null) return 'Not logged in';

    final error = await AuthService.submitKyc(
      user: _currentUser!,
      fullName: fullName,
      dob: dob,
      pan: pan,
      aadhaar: aadhaar,
      address: address,
    );

    if (error == null) {
      // Re-fetch user data to get updated KYC status
      _currentUser = await FirebaseService.getUserData(_currentUser!.uid);
      notifyListeners();
    }
    return error;
  }

  Future<void> refreshCurrentUser() async {
    if (_firebaseUser != null) {
      _currentUser = await FirebaseService.getUserData(_firebaseUser!.uid);
      notifyListeners();
    }
  }
}

