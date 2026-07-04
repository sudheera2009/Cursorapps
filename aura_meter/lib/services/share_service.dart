import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Aura card capture failed: $e');
      return null;
    }
  }

  Future<void> shareCard(Uint8List bytes, {String? text}) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File(
          '${directory.path}/aura_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? 'Check my aura on AURA METER 🔮 #AuraMeter',
      );
    } catch (e) {
      debugPrint('Aura card share failed: $e');
    }
  }

  Future<void> shareText(String text) async {
    try {
      await Share.share(text);
    } catch (e) {
      debugPrint('Share text failed: $e');
    }
  }
}
