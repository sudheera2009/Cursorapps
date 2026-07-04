import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_meter/models/aura_type.dart';
import 'package:aura_meter/models/aura_reading.dart';
import 'package:aura_meter/models/daily_challenge.dart';
import 'package:aura_meter/models/user_profile.dart';
import 'package:aura_meter/widgets/aura_orb.dart';

void main() {
  group('AuraTypes', () {
    test('exposes 10 unique aura types', () {
      final ids = AuraTypes.all.map((a) => a.id).toSet();
      expect(AuraTypes.all.length, 10);
      expect(ids.length, 10);
    });

    test('byId falls back to first type for unknown ids', () {
      expect(AuraTypes.byId('does-not-exist').id, AuraTypes.all.first.id);
    });
  });

  group('AuraReading', () {
    test('serializes round-trip', () {
      final reading = AuraReading(
        typeId: 'gold',
        score: 9123,
        timestamp: DateTime(2026, 1, 1, 12),
        charisma: 80,
        chaos: 40,
        luck: 90,
        mystery: 60,
      );
      final restored = AuraReading.fromJson(reading.toJson());
      expect(restored.typeId, reading.typeId);
      expect(restored.score, reading.score);
      expect(restored.charisma, reading.charisma);
      expect(restored.tier.isNotEmpty, true);
    });
  });

  group('UserProfile', () {
    test('level scales with total scans', () {
      final p = UserProfile(totalScans: 12);
      expect(p.level, 3);
      expect(p.levelProgress, closeTo(0.4, 0.001));
    });

    test('frame unlock respects aura balance', () {
      final p = UserProfile(auraPoints: 100);
      expect(p.unlockFrame('neon', 500), false);
      p.auraPoints = 600;
      expect(p.unlockFrame('neon', 500), true);
      expect(p.auraPoints, 100);
      expect(p.unlockedFrames.contains('neon'), true);
    });
  });

  group('DailyChallenges', () {
    test('returns a stable set of 3 for a given day', () {
      final a = DailyChallenges.forDay(DateTime(2026, 7, 4));
      final b = DailyChallenges.forDay(DateTime(2026, 7, 4));
      expect(a.length, 3);
      expect(a.map((c) => c.id).toList(), b.map((c) => c.id).toList());
    });
  });

  testWidgets('AuraOrb renders its emoji', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: AuraOrb(
            colors: [Colors.purple, Colors.blue],
            emoji: '🔮',
            pulsing: false,
          ),
        ),
      ),
    ));
    expect(find.text('🔮'), findsOneWidget);
  });
}
