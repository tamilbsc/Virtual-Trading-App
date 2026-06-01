import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_trading_app/screens/kyc_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;
  if (_passwordCtrl.text != _confirmCtrl.text) {
    _showErr('Passwords do not match');
    return;
  }

  setState(() => _loading = true);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  final error = await authProvider.register(
    email: _emailCtrl.text.trim(),
    mobile: _mobileCtrl.text.trim(),
    username: _usernameCtrl.text.trim(),
    password: _passwordCtrl.text,
  );

  if (!mounted) return;
  setState(() => _loading = false);

  if (error != null) {
    _showErr(error);
  } else {
    // Auto-login after register
    final success = await authProvider.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const KycScreen()),
      );
    }
  }
}

  void _showErr(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );

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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Icon(Icons.person_add_alt_1, color: Colors.blueAccent, size: 52),
                  const SizedBox(height: 12),
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text('Start your trading journey', style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 32),

                  _field(_mobileCtrl, 'Mobile Number', Icons.phone, type: TextInputType.phone),
                  const SizedBox(height: 14),
                  _field(_emailCtrl, 'Email Address', Icons.email_outlined, type: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _field(_usernameCtrl, 'Username', Icons.person_outline),
                  const SizedBox(height: 14),
                  _field(
                    _passwordCtrl,
                    'Password',
                    Icons.lock_outline,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _field(_confirmCtrl, 'Confirm Password', Icons.lock_outline, obscure: true),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('Already have an account? Login', style: TextStyle(color: Colors.white60)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType? type, bool obscure = false, Widget? suffix}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type ?? TextInputType.text,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: _deco(label, icon).copyWith(suffixIcon: suffix),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
      );
}