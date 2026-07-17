import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/signal_alert.dart';

/// A destination for outbound alerts — the last node of the pipeline
/// (Telegram / WhatsApp / Email).
abstract class NotificationChannel {
  String get id;
  String get name;
  bool get enabled;

  /// Delivers [alert]. Returns true on success. Implementations must never
  /// throw — failures are swallowed/logged so one channel can't break others.
  Future<bool> send(SignalAlert alert);
}

/// The always-on in-app feed. Delivery is handled by storing the alert in the
/// provider's list; this channel is a no-op marker used for UI/config parity.
class InAppChannel implements NotificationChannel {
  const InAppChannel();

  @override
  String get id => 'in_app';
  @override
  String get name => 'In-app feed';
  @override
  bool get enabled => true;

  @override
  Future<bool> send(SignalAlert alert) async => true;
}

/// Real Telegram delivery via the Bot API.
///
/// Create a bot with @BotFather to get a token, then get your chat id (e.g. via
/// @userinfobot). Configure both in Account → Alert channels.
class TelegramChannel implements NotificationChannel {
  const TelegramChannel({this.botToken = '', this.chatId = ''});

  final String botToken;
  final String chatId;

  @override
  String get id => 'telegram';
  @override
  String get name => 'Telegram';
  @override
  bool get enabled => botToken.isNotEmpty && chatId.isNotEmpty;

  @override
  Future<bool> send(SignalAlert alert) async {
    if (!enabled) return false;
    try {
      final uri = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
      final resp = await http.post(uri, body: {
        'chat_id': chatId,
        'text': alert.message,
        'parse_mode': 'Markdown',
      }).timeout(const Duration(seconds: 8));
      return resp.statusCode == 200;
    } catch (e) {
      debugPrint('TelegramChannel send failed: $e');
      return false;
    }
  }
}

/// WhatsApp delivery (integration stub).
///
/// Implement against the WhatsApp Cloud API or Twilio:
/// `POST https://graph.facebook.com/v19.0/{phone_number_id}/messages` with a
/// bearer token, or Twilio's `Messages` endpoint. Requires an approved template
/// for business-initiated messages.
class WhatsAppChannel implements NotificationChannel {
  const WhatsAppChannel({this.accessToken = '', this.toNumber = ''});

  final String accessToken;
  final String toNumber;

  @override
  String get id => 'whatsapp';
  @override
  String get name => 'WhatsApp';
  @override
  bool get enabled => false; // enable once implemented + configured

  @override
  Future<bool> send(SignalAlert alert) async => false;
}

/// Email delivery (integration stub).
///
/// Implement against a transactional email provider (SendGrid, Postmark, SES)
/// or SMTP via the `mailer` package. Provide the API key/credentials and a
/// verified sender through secure configuration.
class EmailChannel implements NotificationChannel {
  const EmailChannel({this.apiKey = '', this.toAddress = ''});

  final String apiKey;
  final String toAddress;

  @override
  String get id => 'email';
  @override
  String get name => 'Email';
  @override
  bool get enabled => false; // enable once implemented + configured

  @override
  Future<bool> send(SignalAlert alert) async => false;
}
