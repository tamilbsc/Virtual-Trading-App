import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), elevation: 0),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
                : [Colors.blue.shade50, Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              user.username.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            // Mobile
            Text(
              '+91 ${user.mobile}',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 32),

            // Settings Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(13) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(50)),
                boxShadow: isDark ? [] : [
                  BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: SwitchListTile(
                title: Text('Dark Mode', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.blueAccent),
                value: isDark,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme(value);
                },
                activeThumbColor: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),

            // Stats Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(13) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(50)),
                boxShadow: isDark ? [] : [
                  BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.verified,
                    'KYC Status',
                    user.isKycVerified ? 'Verified' : 'Pending',
                    user.isKycVerified ? Colors.green : Colors.amber,
                    isDark,
                  ),
                  Divider(height: 30, color: isDark ? Colors.white10 : Colors.grey.shade300),
                  _infoRow(
                    Icons.calendar_today,
                    'Joined',
                    _formatDate(user.createdAt),
                    Colors.blueAccent,
                    isDark,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _showLogoutDialog(context, auth),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 12),
                      Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF203A43),
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: Colors.white60),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            auth.logout();

            // We need to import login_screen to do this correctly, so adding it below.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          child: const Text(
            'LOGOUT',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}}
