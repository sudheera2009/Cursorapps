import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/glass_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedTimeRange = 7; // Days

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildOverviewCards(progress),
                    const SizedBox(height: 24),
                    _buildDestructionChart(provider),
                    const SizedBox(height: 24),
                    _buildModeBreakdown(provider),
                    const SizedBox(height: 24),
                    _buildRageDistribution(provider),
                    const SizedBox(height: 24),
                    _buildRecords(progress),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
        const SizedBox(width: 16),
        Text(
          'STATISTICS',
          style: AppTheme.titleStyle.copyWith(letterSpacing: 2),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bar_chart, color: Colors.purple),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(UserProgress progress) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Damage',
            progress.formattedTotalDestruction,
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Objects',
            '${progress.totalObjects}',
            Icons.broken_image,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Sessions',
            '${progress.totalSessions}',
            Icons.play_circle,
            Colors.orange,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.numberStyle.copyWith(
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 10,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestructionChart(GameProvider provider) {
    final history = provider.userProgress.sessionHistory;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'DESTRUCTION HISTORY',
              style: AppTheme.subtitleStyle.copyWith(
                letterSpacing: 2,
                color: AppTheme.textMuted,
              ),
            ),
            const Spacer(),
            _buildTimeRangeSelector(),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 200,
            child: history.isEmpty
                ? Center(
                    child: Text(
                      'Play more sessions to see your history!',
                      style: AppTheme.bodyStyle.copyWith(color: AppTheme.textMuted),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) => Text(
                              _formatChartValue(value.toInt()),
                              style: AppTheme.bodyStyle.copyWith(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getChartSpots(history),
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.orange.withOpacity(0.3),
                                Colors.orange.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        value: _selectedTimeRange,
        dropdownColor: AppTheme.cardBackground,
        underline: const SizedBox(),
        style: AppTheme.bodyStyle.copyWith(fontSize: 12),
        items: const [
          DropdownMenuItem(value: 7, child: Text('7 Days')),
          DropdownMenuItem(value: 14, child: Text('14 Days')),
          DropdownMenuItem(value: 30, child: Text('30 Days')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedTimeRange = value);
          }
        },
      ),
    );
  }

  List<FlSpot> _getChartSpots(List<SessionRecord> history) {
    if (history.isEmpty) return [const FlSpot(0, 0)];
    
    final recent = history.take(_selectedTimeRange).toList().reversed.toList();
    return List.generate(recent.length, (i) {
      return FlSpot(i.toDouble(), recent[i].damage.toDouble());
    });
  }

  String _formatChartValue(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(0)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toString();
  }

  Widget _buildModeBreakdown(GameProvider provider) {
    final modeStats = provider.userProgress.modePlayCounts;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MODE BREAKDOWN',
          style: AppTheme.subtitleStyle.copyWith(
            letterSpacing: 2,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 200,
            child: modeStats.isEmpty
                ? Center(
                    child: Text(
                      'Play different modes to see breakdown!',
                      style: AppTheme.bodyStyle.copyWith(color: AppTheme.textMuted),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _getPieChartSections(modeStats),
                    ),
                  ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  List<PieChartSectionData> _getPieChartSections(Map<String, int> modeStats) {
    final colors = [
      Colors.blue, Colors.red, Colors.orange, Colors.purple,
      Colors.deepOrange, Colors.cyan, Colors.teal, Colors.deepPurple,
    ];
    
    final total = modeStats.values.fold(0, (a, b) => a + b);
    if (total == 0) return [];
    
    int colorIndex = 0;
    return modeStats.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final color = colors[colorIndex++ % colors.length];
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '$percentage%',
        radius: 50,
        titleStyle: AppTheme.bodyStyle.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildRageDistribution(GameProvider provider) {
    final rageStats = provider.userProgress.rageLevelCounts;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RAGE LEVEL DISTRIBUTION',
          style: AppTheme.subtitleStyle.copyWith(
            letterSpacing: 2,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxRageCount(rageStats).toDouble() + 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['Calm', 'Annoyed', 'Heated', 'Furious', 'Nuclear'];
                        if (value.toInt() < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: AppTheme.bodyStyle.copyWith(
                              fontSize: 8,
                              color: AppTheme.textMuted,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: _getRageBarGroups(rageStats),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  int _getMaxRageCount(Map<String, int> rageStats) {
    if (rageStats.isEmpty) return 5;
    return rageStats.values.fold(0, (a, b) => a > b ? a : b);
  }

  List<BarChartGroupData> _getRageBarGroups(Map<String, int> rageStats) {
    final levels = ['calm', 'annoyed', 'heated', 'furious', 'nuclear'];
    final colors = [
      const Color(0xFF4FC3F7),
      const Color(0xFFFFEB3B),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
      const Color(0xFFFF0000),
    ];
    
    return List.generate(5, (i) {
      final count = rageStats[levels[i]] ?? 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: colors[i],
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  Widget _buildRecords(UserProgress progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERSONAL RECORDS',
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
              _buildRecordRow(
                'Best Session Damage',
                progress.bestSessionDamage > 0 
                    ? _formatDamage(progress.bestSessionDamage)
                    : 'N/A',
                Icons.emoji_events,
                Colors.amber,
              ),
              const Divider(color: AppTheme.cardBorder, height: 24),
              _buildRecordRow(
                'Highest Combo',
                '${progress.highestCombo}x',
                Icons.bolt,
                Colors.yellow,
              ),
              const Divider(color: AppTheme.cardBorder, height: 24),
              _buildRecordRow(
                'Most Objects (Session)',
                '${progress.mostObjectsSession}',
                Icons.broken_image,
                Colors.blue,
              ),
              const Divider(color: AppTheme.cardBorder, height: 24),
              _buildRecordRow(
                'Longest Session',
                _formatDuration(progress.longestSession),
                Icons.timer,
                Colors.green,
              ),
              const Divider(color: AppTheme.cardBorder, height: 24),
              _buildRecordRow(
                'Current Streak',
                '${progress.dailyStreak} days',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRecordRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTheme.bodyStyle),
        ),
        Text(
          value,
          style: AppTheme.numberStyle.copyWith(
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  String _formatDamage(int damage) {
    if (damage >= 1000000000) return '\$${(damage / 1000000000).toStringAsFixed(1)}B';
    if (damage >= 1000000) return '\$${(damage / 1000000).toStringAsFixed(1)}M';
    if (damage >= 1000) return '\$${(damage / 1000).toStringAsFixed(1)}K';
    return '\$$damage';
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return 'N/A';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins}m ${secs}s';
  }
}
