import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  // ─── Register ─────────────────────────────────────────────────────────────
  static Future<String?> register({
    required String email,
    required String mobile,
    required String username,
    required String password,
  }) async {
    // Basic validation
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (username.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    try {
      // 1. Create Firebase Auth User
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = UserModel(
        mobile: mobile,
        username: username.trim(),
        email: email.trim(),
        uid: credential.user!.uid,
        passwordHash: '', // Password is managed by Firebase Auth
        createdAt: DateTime.now(),
      );

      // 2. Save user metadata to Firestore
      await FirebaseService.saveUser(user);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during registration';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────
  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        return await FirebaseService.getUserData(credential.user!.uid);
      }
    } catch (_) {}
    return null;
  }

  // ─── Log Out ──────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────
  static Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ─── KYC Submit ───────────────────────────────────────────────────────────
  static Future<String?> submitKyc({
    required UserModel user,
    required String fullName,
    required String dob,
    required String pan,
    required String aadhaar,
    required String address,
  }) async {
    if (fullName.trim().isEmpty) return 'Full name is required';
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dob)) {
      return 'DOB format: DD/MM/YYYY';
    }
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan.toUpperCase())) {
      return 'Invalid PAN format (e.g. ABCDE1234F)';
    }
    if (!RegExp(r'^\d{12}$').hasMatch(aadhaar)) {
      return 'Aadhaar must be 12 digits';
    }
    if (address.trim().length < 10) return 'Please enter a complete address';

    user.kycFullName = fullName.trim();
    user.kycDob = dob;
    user.kycPan = pan.toUpperCase();
    user.kycAadhaar = aadhaar;
    user.kycAddress = address.trim();
    user.isKycVerified = true;

    await FirebaseService.updateUser(user);
    return null;
  }
}
