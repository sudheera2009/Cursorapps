import 'package:flutter_test/flutter_test.dart';
import 'package:rage_shake/core/theme.dart';
import 'package:rage_shake/models/destruction_mode.dart';
import 'package:rage_shake/models/achievement.dart';
import 'package:rage_shake/models/daily_challenge.dart';
import 'package:rage_shake/models/app_theme.dart';
import 'package:rage_shake/models/game_state.dart';

void main() {
  group('Theme tests', () {
    test('RageColors returns correct colors for levels', () {
      expect(RageColors.getLevel(0.0), RageLevel.calm);
      expect(RageColors.getLevel(0.3), RageLevel.annoyed);
      expect(RageColors.getLevel(0.5), RageLevel.heated);
      expect(RageColors.getLevel(0.7), RageLevel.furious);
      expect(RageColors.getLevel(0.9), RageLevel.nuclear);
    });
  });

  group('DestructionMode tests', () {
    test('All 8 modes are defined', () {
      expect(DestructionModes.all.length, 8);
      expect(DestructionModes.office.name, 'OFFICE RAMPAGE');
      expect(DestructionModes.kitchen.name, 'KITCHEN CHAOS');
      expect(DestructionModes.cars.name, 'CAR CRUSHER');
      expect(DestructionModes.city.name, 'CITY DESTROYER');
      expect(DestructionModes.volcano.name, 'VOLCANO FURY');
      expect(DestructionModes.underwater.name, 'DEEP SEA HAVOC');
      expect(DestructionModes.space.name, 'SPACE ANNIHILATOR');
      expect(DestructionModes.haunted.name, 'HAUNTED HORROR');
    });

    test('Mode unlock levels are correct', () {
      expect(DestructionModes.office.requiredLevel, 1);
      expect(DestructionModes.kitchen.requiredLevel, 1);
      expect(DestructionModes.cars.requiredLevel, 3);
      expect(DestructionModes.city.requiredLevel, 5);
      expect(DestructionModes.volcano.requiredLevel, 7);
      expect(DestructionModes.underwater.requiredLevel, 8);
      expect(DestructionModes.space.requiredLevel, 10);
      expect(DestructionModes.haunted.requiredLevel, 12);
    });

    test('Mode isUnlocked works correctly', () {
      expect(DestructionModes.office.isUnlocked(1), true);
      expect(DestructionModes.cars.isUnlocked(2), false);
      expect(DestructionModes.cars.isUnlocked(3), true);
      expect(DestructionModes.space.isUnlocked(5), false);
      expect(DestructionModes.space.isUnlocked(10), true);
      expect(DestructionModes.haunted.isUnlocked(11), false);
      expect(DestructionModes.haunted.isUnlocked(12), true);
    });

    test('getById returns correct mode', () {
      expect(DestructionModes.getById('office').name, 'OFFICE RAMPAGE');
      expect(DestructionModes.getById('space').name, 'SPACE ANNIHILATOR');
      expect(DestructionModes.getById('volcano').name, 'VOLCANO FURY');
      expect(DestructionModes.getById('haunted').name, 'HAUNTED HORROR');
    });
  });

  group('Achievement tests', () {
    test('All 30 achievements are defined', () {
      expect(Achievements.all.length, 30); // 20 original + 10 new
    });

    test('getById returns correct achievement', () {
      final achievement = Achievements.getById('first_blood');
      expect(achievement, isNotNull);
      expect(achievement!.name, 'First Blood');
    });

    test('getByType returns correct achievements', () {
      final comboAchievements = Achievements.getByType(AchievementType.maxCombo);
      expect(comboAchievements.length, 3);
    });

    test('New achievements exist', () {
      expect(Achievements.getById('coin_collector_1k'), isNotNull);
      expect(Achievements.getById('level_50'), isNotNull);
      expect(Achievements.getById('early_bird'), isNotNull);
      expect(Achievements.getById('night_owl'), isNotNull);
    });
  });

  group('DailyChallenge tests', () {
    test('All challenges are defined', () {
      expect(DailyChallenges.allChallenges.length, 19); // 12 original + 7 new
    });

    test('getDailyChallenges returns 3 challenges', () {
      final challenges = DailyChallenges.getDailyChallenges(DateTime.now());
      expect(challenges.length, 3);
    });

    test('Same date returns same challenges', () {
      final date = DateTime(2024, 1, 15);
      final challenges1 = DailyChallenges.getDailyChallenges(date);
      final challenges2 = DailyChallenges.getDailyChallenges(date);
      expect(challenges1.map((c) => c.id), challenges2.map((c) => c.id));
    });

    test('Different dates return different challenges', () {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 1, 16);
      final challenges1 = DailyChallenges.getDailyChallenges(date1);
      final challenges2 = DailyChallenges.getDailyChallenges(date2);
      expect(challenges1.map((c) => c.id), isNot(challenges2.map((c) => c.id)));
    });

    test('New challenge types exist', () {
      final allChallenges = DailyChallenges.allChallenges;
      expect(allChallenges.any((c) => c.type == DailyChallengeType.playDuration), true);
      expect(allChallenges.any((c) => c.type == DailyChallengeType.earnCoins), true);
    });
  });

  group('AppThemes tests', () {
    test('All 8 themes are defined', () {
      expect(AppThemes.all.length, 8);
    });

    test('Default theme is free', () {
      final defaultTheme = AppThemes.getTheme('default');
      expect(defaultTheme.type, ThemeType.free);
      expect(defaultTheme.cost, 0);
    });

    test('Premium themes have costs', () {
      final neonTheme = AppThemes.getTheme('neon_cyber');
      expect(neonTheme.type, ThemeType.premium);
      expect(neonTheme.cost, greaterThan(0));
    });

    test('getTheme returns default for unknown id', () {
      final theme = AppThemes.getTheme('unknown_theme');
      expect(theme.id, 'default');
    });
  });

  group('UserProgress tests', () {
    test('Initial values are correct', () {
      final progress = UserProgress();
      expect(progress.rageCoins, 0);
      expect(progress.currentTheme, 'default');
      expect(progress.unlockedThemes.contains('default'), true);
      expect(progress.sessionHistory.isEmpty, true);
    });

    test('unlockTheme works correctly', () {
      final progress = UserProgress(rageCoins: 1000);
      final result = progress.unlockTheme('neon_cyber', 500);
      expect(result, true);
      expect(progress.rageCoins, 500);
      expect(progress.unlockedThemes.contains('neon_cyber'), true);
    });

    test('unlockTheme fails without enough coins', () {
      final progress = UserProgress(rageCoins: 100);
      final result = progress.unlockTheme('neon_cyber', 500);
      expect(result, false);
      expect(progress.rageCoins, 100);
    });
  });

  group('SessionRecord tests', () {
    test('toJson and fromJson work correctly', () {
      final record = SessionRecord(
        damage: 1000000,
        objects: 50,
        maxCombo: 25,
        modeId: 'office',
        peakRage: 'furious',
        durationSeconds: 120,
        playedAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = record.toJson();
      final restored = SessionRecord.fromJson(json);

      expect(restored.damage, 1000000);
      expect(restored.objects, 50);
      expect(restored.maxCombo, 25);
      expect(restored.modeId, 'office');
      expect(restored.peakRage, 'furious');
      expect(restored.durationSeconds, 120);
    });
  });
}
