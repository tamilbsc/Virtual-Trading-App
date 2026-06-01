import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'kyc_screen.dart';

/// Decides what to show based on auth state:
/// - Not logged in → LoginScreen
/// - Logged in, KYC pending → KycScreen
/// - Logged in & KYC done → child (main app)
class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) return const LoginScreen();
    if (!auth.isKycVerified) return const KycScreen();
    return child;
  }
}
