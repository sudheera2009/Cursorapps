import 'aura_type.dart';

/// The result of a single aura scan.
class AuraReading {
  final String typeId;
  final int score; // 0 - 9999
  final DateTime timestamp;

  /// Percentile-style trait readings (0-100) shown on the result card.
  final int charisma;
  final int chaos;
  final int luck;
  final int mystery;

  AuraReading({
    required this.typeId,
    required this.score,
    required this.timestamp,
    required this.charisma,
    required this.chaos,
    required this.luck,
    required this.mystery,
  });

  AuraType get type => AuraTypes.byId(typeId);

  /// A shareable tier label for the score.
  String get tier {
    if (score >= 9000) return 'S+  ASCENDED';
    if (score >= 7500) return 'S  RADIANT';
    if (score >= 6000) return 'A  GLOWING';
    if (score >= 4000) return 'B  STEADY';
    if (score >= 2000) return 'C  FLICKERING';
    return 'D  DIM';
  }

  Map<String, dynamic> toJson() => {
        'typeId': typeId,
        'score': score,
        'timestamp': timestamp.toIso8601String(),
        'charisma': charisma,
        'chaos': chaos,
        'luck': luck,
        'mystery': mystery,
      };

  factory AuraReading.fromJson(Map<String, dynamic> json) => AuraReading(
        typeId: json['typeId'] as String,
        score: json['score'] as int,
        timestamp:
            DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        charisma: json['charisma'] as int? ?? 50,
        chaos: json['chaos'] as int? ?? 50,
        luck: json['luck'] as int? ?? 50,
        mystery: json['mystery'] as int? ?? 50,
      );
}
