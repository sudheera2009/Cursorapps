import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../providers/trading_provider.dart';
import '../widgets/panel_card.dart';
import '../widgets/stat_box.dart';
import 'alert_settings_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TradingProvider>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Account', style: AppTheme.headlineStyle),
          const SizedBox(height: 16),
          PanelCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppColors.crude, AppColors.gas]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🛢️',
                          style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paper Trading Account',
                            style: AppTheme.titleStyle),
                        Text('Opened ${Fmt.dateTime(p.createdAt)}',
                            style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: StatBox(
                          label: 'Equity', value: Fmt.money2(p.equity)),
                    ),
                    Expanded(
                      child: StatBox(
                        label: 'All-time P&L',
                        value: Fmt.signedMoney(p.totalPnl),
                        valueColor: AppColors.forChange(p.totalPnl),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: StatBox(
                          label: 'Peak equity',
                          value: Fmt.money2(p.peakEquity)),
                    ),
                    Expanded(
                      child: StatBox(
                          label: 'Deposit',
                          value: Fmt.money0(TradingProvider.startingCash)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PanelCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  value: p.running,
                  onChanged: (_) => p.toggleRunning(),
                  activeThumbColor: AppColors.up,
                  title: Text('Live price feed',
                      style: AppTheme.subtitleStyle
                          .copyWith(color: AppColors.textPrimary)),
                  subtitle: Text(
                    p.running
                        ? 'Prices are updating every second'
                        : 'Price simulation paused',
                    style: AppTheme.bodyStyle.copyWith(fontSize: 12),
                  ),
                  secondary: const Icon(Icons.sensors, color: AppColors.gas),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PanelCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active,
                      color: AppColors.gas),
                  title: Text('Alerts & channels',
                      style: AppTheme.subtitleStyle
                          .copyWith(color: AppColors.textPrimary)),
                  subtitle: Text(
                      p.alertsEnabled
                          ? 'On · min ${(p.alertConfidence * 100).round()}% confidence · ${p.telegramConfigured ? 'Telegram connected' : 'in-app only'}'
                          : 'Off',
                      style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textMuted),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AlertSettingsScreen()),
                  ),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                ListTile(
                  leading:
                      const Icon(Icons.refresh, color: AppColors.crude),
                  title: Text('Reset account',
                      style: AppTheme.subtitleStyle
                          .copyWith(color: AppColors.textPrimary)),
                  subtitle: Text(
                      'Clear all positions & trades, restore ${Fmt.money0(TradingProvider.startingCash)}',
                      style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                  onTap: () => _confirmReset(context, p),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.textMuted),
                  title: Text('About BARREL',
                      style: AppTheme.subtitleStyle
                          .copyWith(color: AppColors.textPrimary)),
                  subtitle: Text('Version 1.0.0',
                      style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.crude.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.crude.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.crude, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Simulation only. Prices are randomly generated and no real '
                    'money or real markets are involved.',
                    style: AppTheme.bodyStyle.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, TradingProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Reset account?', style: AppTheme.titleStyle),
        content: Text(
          'This permanently clears your positions, trade history and P&L, and '
          'restores your balance to ${Fmt.money0(TradingProvider.startingCash)}.',
          style: AppTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.down),
            onPressed: () {
              p.resetAccount();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(const SnackBar(
                  content: Text('Account reset'),
                  behavior: SnackBarBehavior.floating,
                ));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BARREL',
      applicationVersion: '1.0.0',
      applicationLegalese:
          'A paper trading simulator for crude oil & natural gas markets. '
          'For education and entertainment only.',
    );
  }
}
