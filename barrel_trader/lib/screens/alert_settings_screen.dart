import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/trading_provider.dart';
import '../widgets/panel_card.dart';

class AlertSettingsScreen extends StatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  late final TextEditingController _tokenCtrl;
  late final TextEditingController _chatCtrl;

  @override
  void initState() {
    super.initState();
    final p = context.read<TradingProvider>();
    _tokenCtrl = TextEditingController(text: p.telegramToken);
    _chatCtrl = TextEditingController(text: p.telegramChatId);
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _chatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TradingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          PanelCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              value: p.alertsEnabled,
              onChanged: p.setAlertsEnabled,
              activeThumbColor: AppColors.up,
              title: Text('Signal alerts',
                  style: AppTheme.subtitleStyle
                      .copyWith(color: AppColors.textPrimary)),
              subtitle: Text('Fire when a call crosses your confidence bar',
                  style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
              secondary:
                  const Icon(Icons.notifications_active, color: AppColors.gas),
            ),
          ),
          const SizedBox(height: 16),
          PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('MINIMUM CONFIDENCE', style: AppTheme.labelStyle),
                    const Spacer(),
                    Text('${(p.alertConfidence * 100).round()}%',
                        style: AppTheme.mono(size: 14, color: AppColors.gas)),
                  ],
                ),
                Slider(
                  value: p.alertConfidence,
                  min: 0.1,
                  max: 0.95,
                  divisions: 17,
                  activeColor: AppColors.gas,
                  onChanged: p.setAlertConfidence,
                ),
                Text(
                  'Only signals at or above this confidence trigger alerts.',
                  style: AppTheme.bodyStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Delivery channels', style: AppTheme.titleStyle),
          const SizedBox(height: 8),
          _channelTile('In-app feed', 'Always on', Icons.inbox, true),
          _channelTile(
            'Telegram',
            p.telegramConfigured ? 'Connected' : 'Add a bot token & chat id',
            Icons.send,
            p.telegramConfigured,
          ),
          _channelTile('WhatsApp', 'Coming soon (adapter stub)',
              Icons.chat_bubble_outline, false),
          _channelTile(
              'Email', 'Coming soon (adapter stub)', Icons.email_outlined, false),
          const SizedBox(height: 16),
          PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TELEGRAM BOT', style: AppTheme.labelStyle),
                const SizedBox(height: 4),
                Text(
                  'Create a bot with @BotFather, then get your chat id from '
                  '@userinfobot.',
                  style: AppTheme.bodyStyle.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tokenCtrl,
                  style: AppTheme.mono(size: 13),
                  decoration: _dec('Bot token'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _chatCtrl,
                  style: AppTheme.mono(size: 13),
                  keyboardType: TextInputType.number,
                  decoration: _dec('Chat id'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gas),
                    onPressed: () {
                      p.setTelegram(
                        token: _tokenCtrl.text,
                        chatId: _chatCtrl.text,
                      );
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(const SnackBar(
                          content: Text('Telegram settings saved'),
                          behavior: SnackBarBehavior.floating,
                        ));
                    },
                    child: Text('Save Telegram',
                        style: AppTheme.titleStyle
                            .copyWith(color: Colors.black, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyStyle,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      );

  Widget _channelTile(
      String name, String subtitle, IconData icon, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: active ? AppColors.up : AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: AppTheme.subtitleStyle
                      .copyWith(color: AppColors.textPrimary)),
              Text(subtitle, style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
            ],
          ),
          const Spacer(),
          Icon(
            active ? Icons.check_circle : Icons.circle_outlined,
            color: active ? AppColors.up : AppColors.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }
}
