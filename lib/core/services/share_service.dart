import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Captures a [RepaintBoundary] (referenced by [boundaryKey]) into a PNG and
/// hands it to the system share sheet. Falls back to text-only share if the
/// boundary isn't available (e.g. widget hasn't been laid out yet).
class ShareService {
  /// Web has no temp dir + share_plus image-share — fall back to text there.
  Future<bool> shareResult({
    required GlobalKey boundaryKey,
    required String fallbackText,
    String subject = 'My ChromaPulse score',
  }) async {
    if (kIsWeb) {
      await Share.share(fallbackText, subject: subject);
      return true;
    }
    try {
      final pngBytes = await _capture(boundaryKey);
      if (pngBytes == null) {
        await Share.share(fallbackText, subject: subject);
        return true;
      }
      final dir = Directory.systemTemp;
      final file = File(
        '${dir.path}/chromapulse_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: fallbackText,
        subject: subject,
      );
      return true;
    } catch (_) {
      // If anything goes wrong, fall back to text share so the player still
      // gets something useful.
      try {
        await Share.share(fallbackText, subject: subject);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<Uint8List?> _capture(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
