import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'account_screen.dart';
import 'history_screen.dart';
import 'market_screen.dart';
import 'portfolio_screen.dart';
import 'signals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _screens = [
    MarketScreen(),
    SignalsScreen(),
    PortfolioScreen(),
    HistoryScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundAlt,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.primary.withValues(alpha: 0.16),
            labelTextStyle: WidgetStateProperty.all(
              AppTheme.labelStyle.copyWith(fontSize: 11, letterSpacing: 0.5),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            height: 66,
            backgroundColor: Colors.transparent,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.candlestick_chart_outlined),
                selectedIcon: Icon(Icons.candlestick_chart, color: AppColors.primary),
                label: 'Markets',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_graph_outlined),
                selectedIcon: Icon(Icons.auto_graph, color: AppColors.primary),
                label: 'Signals',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet,
                    color: AppColors.primary),
                label: 'Portfolio',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon:
                    Icon(Icons.receipt_long, color: AppColors.primary),
                label: 'Activity',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.primary),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
