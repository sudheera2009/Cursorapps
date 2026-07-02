import 'package:flutter_test/flutter_test.dart';
import 'package:rage_shake/core/theme.dart';
import 'package:rage_shake/models/destruction_mode.dart';

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
    test('All modes are defined', () {
      expect(DestructionModes.all.length, 5);
      expect(DestructionModes.office.name, 'OFFICE RAMPAGE');
      expect(DestructionModes.kitchen.name, 'KITCHEN CHAOS');
      expect(DestructionModes.cars.name, 'CAR CRUSHER');
      expect(DestructionModes.city.name, 'CITY DESTROYER');
      expect(DestructionModes.space.name, 'SPACE ANNIHILATOR');
    });

    test('Mode unlock levels are correct', () {
      expect(DestructionModes.office.requiredLevel, 1);
      expect(DestructionModes.kitchen.requiredLevel, 1);
      expect(DestructionModes.cars.requiredLevel, 3);
      expect(DestructionModes.city.requiredLevel, 5);
      expect(DestructionModes.space.requiredLevel, 10);
    });

    test('Mode isUnlocked works correctly', () {
      expect(DestructionModes.office.isUnlocked(1), true);
      expect(DestructionModes.cars.isUnlocked(2), false);
      expect(DestructionModes.cars.isUnlocked(3), true);
      expect(DestructionModes.space.isUnlocked(5), false);
      expect(DestructionModes.space.isUnlocked(10), true);
    });

    test('getById returns correct mode', () {
      expect(DestructionModes.getById('office').name, 'OFFICE RAMPAGE');
      expect(DestructionModes.getById('space').name, 'SPACE ANNIHILATOR');
    });
  });
}
