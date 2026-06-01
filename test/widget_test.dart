import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:virtual_trading_app/main.dart';
import 'package:virtual_trading_app/providers/auth_provider.dart';
import 'package:virtual_trading_app/providers/portfolio_provider.dart';

void main() {
  setUpAll(() async {
    // Firebase initialization for tests would go here if needed
  });


  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ],
        child: const VirtualTradingApp(),
      ),
    );

    // Verify that the app title or a key element is present.
    expect(find.byType(VirtualTradingApp), findsOneWidget);
  });
}
