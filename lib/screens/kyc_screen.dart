import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:virtual_trading_app/screens/login_screen.dart';
import '../providers/auth_provider.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dob = TextEditingController();
  final _pan = TextEditingController();
  final _aadhaar = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _dob.dispose();
    _pan.dispose();
    _aadhaar.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.blueAccent),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dob.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

 Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _loading = true);

  final provider = Provider.of<AuthProvider>(context, listen: false);
  final error = await provider.submitKyc(
    fullName: _name.text,
    dob: _dob.text,
    pan: _pan.text,
    aadhaar: _aadhaar.text,
    address: _address.text,
  );

  if (!mounted) return;
  setState(() => _loading = false);

  if (error == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('KYC Submitted Successfully! Verifying...'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to Login Page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );

  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }
}

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
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_user,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KYC Verification',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Know Your Customer',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Complete KYC to start trading. Your data is stored securely in our encrypted cloud storage.',
                            style: TextStyle(color: Colors.amber, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _field(_name, 'Full Name (as per PAN)', Icons.person_outline),
                  const SizedBox(height: 14),

                  // DOB with date picker
                  TextFormField(
                    controller: _dob,
                    readOnly: true,
                    onTap: _pickDate,
                    style: const TextStyle(color: Colors.white),
                    decoration: _deco('Date of Birth', Icons.cake_outlined)
                        .copyWith(
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.white54,
                            size: 18,
                          ),
                          hintText: 'DD/MM/YYYY',
                          hintStyle: const TextStyle(color: Colors.white38),
                        ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Select date of birth'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _pan,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 10,
                    decoration: _deco(
                      'PAN Number',
                      Icons.credit_card,
                    ).copyWith(counterText: ''),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!RegExp(
                        r'^[A-Z]{5}[0-9]{4}[A-Z]$',
                      ).hasMatch(v.toUpperCase())) {
                        return 'Invalid PAN (e.g. ABCDE1234F)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _aadhaar,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    style: const TextStyle(color: Colors.white),
                    decoration: _deco(
                      'Aadhaar Number (12 digits)',
                      Icons.fingerprint,
                    ).copyWith(counterText: ''),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!RegExp(r'^\d{12}$').hasMatch(v)) {
                        return 'Aadhaar must be 12 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _address,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: _deco('Full Address', Icons.home_outlined),
                    validator: (v) {
                      if (v == null || v.trim().length < 10) {
                        return 'Enter a complete address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

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
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'SUBMIT KYC & CONTINUE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: _deco(label, icon),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white60),
    prefixIcon: Icon(icon, color: Colors.white54),
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
  );
}
