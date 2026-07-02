import 'package:flutter_test/flutter_test.dart';
import 'package:rage_shake/core/theme.dart';
import 'package:rage_shake/models/destruction_mode.dart';
import 'package:rage_shake/models/achievement.dart';
import 'package:rage_shake/models/daily_challenge.dart';

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
    test('All 20 achievements are defined', () {
      expect(Achievements.all.length, 20);
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
  });

  group('DailyChallenge tests', () {
    test('All challenges are defined', () {
      expect(DailyChallenges.allChallenges.length, 12);
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
  });
}
