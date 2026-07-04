import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/enums.dart';
import '../models/tool.dart';
import '../providers/settings_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/tool_card.dart';
import 'dashboard_screen.dart';
import 'recipes_screen.dart';
import 'settings_screen.dart';
import 'tool_flow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      _HubTab(),
      RecipesScreen(),
      DashboardScreen(),
      SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _tab, children: tabs),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Tools'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Recipes'),
          NavigationDestination(
              icon: Icon(Icons.insights), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _HubTab extends StatelessWidget {
  const _HubTab();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text('Image Toolbox', style: AppTheme.headline),
                const SizedBox(height: 4),
                Text('All your image tools, one app',
                    style: AppTheme.body),
                const SizedBox(height: 18),
                _StatsBar(settings: settings),
                const SizedBox(height: 22),
                for (final category in ToolCategory.values) ...[
                  Text(category.label.toUpperCase(), style: AppTheme.label),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: ToolRegistry.byCategory(category)
                        .map((t) => ToolCard(
                              tool: t,
                              onTap: () => openTool(context, t),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final SettingsProvider settings;
  const _StatsBar({required this.settings});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.primary.withValues(alpha: 0.4),
      child: Row(
        children: [
          const Icon(Icons.savings, color: AppColors.primary, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SPACE SAVED', style: AppTheme.label),
                const SizedBox(height: 2),
                Text(Formatters.bytes(settings.bytesSaved),
                    style: AppTheme.title.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('PROCESSED', style: AppTheme.label),
              const SizedBox(height: 2),
              Text('${settings.filesProcessed}',
                  style: AppTheme.title.copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
