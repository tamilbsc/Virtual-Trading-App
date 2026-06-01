import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showErr('Please enter a valid email');
      return;
    }

    setState(() => _loading = true);
    final error = await AuthService.sendPasswordResetEmail(email);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showErr(error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reset link sent to your email!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showErr(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.lock_reset,
                  color: Colors.blueAccent,
                  size: 50,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Enter your registered email address to receive a password reset link.',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 20),
                _field(
                  _emailCtrl,
                  'Email Address',
                  Icons.email_outlined,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                _btn('Send Reset Link', _sendResetEmail, loading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? type,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type ?? TextInputType.text,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap, {bool loading = false}) =>
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: loading ? null : onTap,
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      );
}
