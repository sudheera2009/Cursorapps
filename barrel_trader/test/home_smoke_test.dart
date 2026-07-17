import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barrel_trader/core/theme.dart';
import 'package:barrel_trader/providers/trading_provider.dart';
import 'package:barrel_trader/screens/home_screen.dart';
import 'package:barrel_trader/services/context_provider.dart';
import 'package:barrel_trader/services/market_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home renders and navigates across tabs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = TradingProvider(
      dataSource: SimulatedMarketDataSource(random: Random(3)),
      contextProvider: SimulatedContextProvider(random: Random(3)),
      tickInterval: const Duration(hours: 1),
    );
    await provider.initialize();
    provider.pause();

    await tester.pumpWidget(
      ChangeNotifierProvider<TradingProvider>.value(
        value: provider,
        child: MaterialApp(theme: AppTheme.darkTheme, home: const HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Markets tab is the default landing screen.
    expect(find.text('Markets'), findsWidgets);

    // Navigate to Signals.
    await tester.tap(find.text('Signals'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Signals'), findsWidgets);

    // Navigate to Portfolio.
    await tester.tap(find.text('Portfolio'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('ACCOUNT EQUITY'), findsOneWidget);

    // Navigate to Activity.
    await tester.tap(find.text('Activity'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Trade blotter'), findsOneWidget);

    // Navigate to Account.
    await tester.tap(find.text('Account'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Reset account'), findsOneWidget);

    provider.dispose();
  });
}
