import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SoundService _soundService = SoundService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A1A),
              Color(0xFF0A0A0F),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildSoundSection(),
                const SizedBox(height: 24),
                _buildGameplaySection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
                const SizedBox(height: 24),
                _buildDangerZone(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const Spacer(),
        Text(
          'SETTINGS',
          style: AppTheme.titleStyle.copyWith(letterSpacing: 2),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildSoundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AUDIO',
          style: AppTheme.subtitleStyle.copyWith(
            letterSpacing: 2,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildToggle(
                icon: Icons.volume_up,
                title: 'Sound Effects',
                subtitle: 'Destruction sounds, UI feedback',
                value: _soundService.soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundService.setSoundEnabled(value);
                  });
                },
                color: Colors.cyan,
              ),
              const Divider(color: AppTheme.cardBorder, height: 32),
              _buildToggle(
                icon: Icons.music_note,
                title: 'Background Music',
                subtitle: 'Ambient music during gameplay',
                value: _soundService.musicEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundService.setMusicEnabled(value);
                  });
                },
                color: Colors.purple,
              ),
              const Divider(color: AppTheme.cardBorder, height: 32),
              _buildSlider(
                icon: Icons.volume_up,
                title: 'Sound Volume',
                value: _soundService.soundVolume,
                onChanged: (value) {
                  setState(() {
                    _soundService.setSoundVolume(value);
                  });
                },
                color: Colors.cyan,
              ),
              const SizedBox(height: 16),
              _buildSlider(
                icon: Icons.music_note,
                title: 'Music Volume',
                value: _soundService.musicVolume,
                onChanged: (value) {
                  setState(() {
                    _soundService.setMusicVolume(value);
                  });
                },
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildGameplaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GAMEPLAY',
          style: AppTheme.subtitleStyle.copyWith(
            letterSpacing: 2,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildToggle(
                icon: Icons.vibration,
                title: 'Haptic Feedback',
                subtitle: 'Vibration during destruction',
                value: _soundService.hapticsEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundService.setHapticsEnabled(value);
                  });
                },
                color: Colors.orange,
              ),
              const Divider(color: AppTheme.cardBorder, height: 32),
              _buildToggle(
                icon: Icons.flash_on,
                title: 'Screen Shake',
                subtitle: 'Visual shake effect',
                value: true,
                onChanged: (value) {},
                color: Colors.amber,
              ),
              const Divider(color: AppTheme.cardBorder, height: 32),
              _buildToggle(
                icon: Icons.auto_awesome,
                title: 'Particle Effects',
                subtitle: 'Explosion particles',
                value: true,
                onChanged: (value) {},
                color: Colors.pink,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ABOUT',
          style: AppTheme.subtitleStyle.copyWith(
            letterSpacing: 2,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.info,
                title: 'Version',
                value: '1.1.0',
                color: Colors.blue,
              ),
              const Divider(color: AppTheme.cardBorder, height: 24),
              _buildInfoRow(
                icon: Icons.code,
                title: 'Build',
                value: 'Release',
                color: Colors.green,
              ),
              const Divider(color: AppTheme.cardBorder, height: 24),
              _buildActionRow(
                icon: Icons.star,
                title: 'Rate App',
                subtitle: 'Love RAGE SHAKE? Rate us!',
                color: Colors.amber,
                onTap: () {},
              ),
              const Divider(color: AppTheme.cardBorder, height: 24),
              _buildActionRow(
                icon: Icons.share,
                title: 'Share App',
                subtitle: 'Tell your friends',
                color: Colors.cyan,
                onTap: () {},
              ),
              const Divider(color: AppTheme.cardBorder, height: 24),
              _buildActionRow(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                color: Colors.grey,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DANGER ZONE',
          style: AppTheme.subtitleStyle.copyWith(
            letterSpacing: 2,
            color: Colors.red.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          glowColor: Colors.red.withOpacity(0.3),
          child: Column(
            children: [
              _buildActionRow(
                icon: Icons.restore,
                title: 'Reset Progress',
                subtitle: 'Clear all stats and achievements',
                color: Colors.red,
                onTap: () => _showResetDialog(),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.subtitleStyle.copyWith(fontSize: 16)),
              Text(
                subtitle,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
        ),
      ],
    );
  }

  Widget _buildSlider({
    required IconData icon,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title, style: AppTheme.bodyStyle),
            const Spacer(),
            Text(
              '${(value * 100).toInt()}%',
              style: AppTheme.bodyStyle.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Text(title, style: AppTheme.subtitleStyle.copyWith(fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.subtitleStyle.copyWith(fontSize: 16)),
                Text(
                  subtitle,
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.textMuted),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Progress?',
          style: AppTheme.titleStyle.copyWith(color: Colors.red),
        ),
        content: Text(
          'This will permanently delete all your stats, achievements, and progress. This action cannot be undone.',
          style: AppTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Progress reset!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
