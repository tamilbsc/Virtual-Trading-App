import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/portfolio_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/responsive_utils.dart';

import 'screens/home_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/history_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/auth_gate.dart';
import 'screens/profile_screen.dart';
import 'screens/wallet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase ONLY ONCE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const VirtualTradingApp(),
    ),
  );
}

class VirtualTradingApp extends StatelessWidget {
  const VirtualTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Virtual Trading App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blueAccent,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueAccent,
      ),
      home: const AuthGate(child: MainNavigationScreen()),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const WatchlistScreen();
      case 2:
        return const PortfolioScreen();
      case 3:
        return const HistoryScreen();
      case 4:
        return const WalletScreen();
      case 5:
        return const AiAssistantScreen();
      case 6:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = Responsive.isTablet(context) || Responsive.isDesktop(context);

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              extended: Responsive.isDesktop(context),
              labelType: Responsive.isDesktop(context)
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.show_chart),
                  label: Text('Market'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.star_rounded),
                  label: Text('Watchlist'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.pie_chart),
                  label: Text('Portfolio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text('History'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_balance_wallet),
                  label: Text('Funds'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_awesome),
                  label: Text('Trading Assistant'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  label: Text('Profile'),
                ),
              ],
            ),
          Expanded(
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _getScreen(_currentIndex),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.show_chart),
                  label: 'Market',
                ),
                NavigationDestination(
                  icon: Icon(Icons.star_rounded),
                  label: 'Watchlist',
                ),
                NavigationDestination(
                  icon: Icon(Icons.pie_chart),
                  label: 'Portfolio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet),
                  label: 'Funds',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome),
                  label: 'Trading Assistant',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}
