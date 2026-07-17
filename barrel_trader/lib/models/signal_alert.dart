import 'trade_signal.dart';

/// A fired alert — a strong signal that crossed the user's confidence
/// threshold. Shown in the in-app feed and dispatched to any enabled external
/// channels (Telegram / WhatsApp / Email).
class SignalAlert {
  final String id;
  final String instrumentId;
  final SignalAction action;
  final double confidence;
  final double price;
  final String message;
  final DateTime timestamp;

  const SignalAlert({
    required this.id,
    required this.instrumentId,
    required this.action,
    required this.confidence,
    required this.price,
    required this.message,
    required this.timestamp,
  });

  int get confidencePercent => (confidence * 100).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'instrumentId': instrumentId,
        'action': action.name,
        'confidence': confidence,
        'price': price,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SignalAlert.fromJson(Map<String, dynamic> json) => SignalAlert(
        id: json['id'] as String,
        instrumentId: json['instrumentId'] as String,
        action: SignalAction.values.firstWhere(
          (a) => a.name == json['action'],
          orElse: () => SignalAction.wait,
        ),
        confidence: (json['confidence'] as num).toDouble(),
        price: (json['price'] as num?)?.toDouble() ?? 0,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
