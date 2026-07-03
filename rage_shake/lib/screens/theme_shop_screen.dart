import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/app_theme.dart';
import '../providers/game_provider.dart';
import '../widgets/glass_card.dart';

class ThemeShopScreen extends StatelessWidget {
  const ThemeShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final progress = provider.userProgress;
        
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0A2A), Color(0xFF0A0A0F)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, progress.rageCoins),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCurrentTheme(provider),
                          const SizedBox(height: 24),
                          _buildSectionTitle('FREE THEMES'),
                          const SizedBox(height: 12),
                          _buildThemeGrid(context, provider, AppThemes.freeThemes),
                          const SizedBox(height: 24),
                          _buildSectionTitle('PREMIUM THEMES'),
                          const SizedBox(height: 12),
                          _buildThemeGrid(context, provider, AppThemes.premiumThemes),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int rageCoins) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
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
          const SizedBox(width: 16),
          Text(
            'THEME SHOP',
            style: AppTheme.titleStyle.copyWith(letterSpacing: 2),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.withOpacity(0.3), Colors.orange.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '$rageCoins',
                  style: AppTheme.numberStyle.copyWith(
                    color: Colors.amber,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTheme(GameProvider provider) {
    final currentTheme = AppThemes.getTheme(provider.userProgress.currentTheme);
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [currentTheme.primaryColor, currentTheme.accentColor],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(currentTheme.iconEmoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT THEME',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  currentTheme.name,
                  style: AppTheme.subtitleStyle.copyWith(
                    color: currentTheme.primaryColor,
                  ),
                ),
                Text(
                  currentTheme.description,
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 28),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.subtitleStyle.copyWith(
        letterSpacing: 2,
        color: AppTheme.textMuted,
      ),
    );
  }

  Widget _buildThemeGrid(BuildContext context, GameProvider provider, List<CustomTheme> themes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        return _buildThemeCard(context, provider, themes[index], index);
      },
    );
  }

  Widget _buildThemeCard(BuildContext context, GameProvider provider, CustomTheme theme, int index) {
    final isUnlocked = provider.userProgress.unlockedThemes.contains(theme.id);
    final isCurrentTheme = provider.userProgress.currentTheme == theme.id;
    final canAfford = provider.userProgress.rageCoins >= theme.cost;

    return GestureDetector(
      onTap: () => _handleThemeTap(context, provider, theme, isUnlocked, isCurrentTheme, canAfford),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentTheme 
                ? Colors.green 
                : isUnlocked 
                    ? theme.primaryColor.withOpacity(0.5)
                    : AppTheme.cardBorder,
            width: isCurrentTheme ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Theme preview background
              Container(
                decoration: BoxDecoration(
                  gradient: theme.backgroundGradient,
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme icon
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.accentColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(theme.iconEmoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      theme.name,
                      style: AppTheme.subtitleStyle.copyWith(
                        fontSize: 14,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.description,
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    
                    // Status/Price
                    if (isCurrentTheme)
                      _buildStatusBadge('ACTIVE', Colors.green)
                    else if (isUnlocked)
                      _buildStatusBadge('OWNED', Colors.blue)
                    else
                      _buildPriceBadge(theme.cost, canAfford),
                  ],
                ),
              ),

              // Locked overlay
              if (!isUnlocked && !canAfford)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock,
                        color: Colors.white.withOpacity(0.5),
                        size: 32,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: AppTheme.bodyStyle.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildPriceBadge(int cost, bool canAfford) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: canAfford ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canAfford ? Colors.amber.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🪙', style: TextStyle(fontSize: 12, color: canAfford ? null : Colors.grey)),
          const SizedBox(width: 4),
          Text(
            '$cost',
            style: AppTheme.numberStyle.copyWith(
              fontSize: 12,
              color: canAfford ? Colors.amber : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _handleThemeTap(
    BuildContext context,
    GameProvider provider,
    CustomTheme theme,
    bool isUnlocked,
    bool isCurrentTheme,
    bool canAfford,
  ) {
    if (isCurrentTheme) return;

    if (isUnlocked) {
      // Apply theme
      provider.setTheme(theme.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme "${theme.name}" applied!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (canAfford) {
      // Show purchase dialog
      _showPurchaseDialog(context, provider, theme);
    } else {
      // Show not enough coins message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need ${theme.cost - provider.userProgress.rageCoins} more Rage Coins'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showPurchaseDialog(BuildContext context, GameProvider provider, CustomTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(theme.iconEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Unlock ${theme.name}?',
                style: AppTheme.subtitleStyle,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(theme.description, style: AppTheme.bodyStyle),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '${theme.cost}',
                    style: AppTheme.numberStyle.copyWith(
                      color: Colors.amber,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyStyle.copyWith(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final success = provider.purchaseTheme(theme.id, theme.cost);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${theme.name} unlocked and applied!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}
