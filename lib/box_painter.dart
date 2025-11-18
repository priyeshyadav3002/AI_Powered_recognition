// lib/box_painter.dart
import 'package:flutter/material.dart';
import 'recognition.dart';
import 'dart:ui' as ui;

class DetectionBoxPainter extends CustomPainter {
  final List<Recognition> detections;
  final Size previewSize;
  final Size screenSize;
  final bool mirror;

  DetectionBoxPainter({
    required this.detections,
    required this.previewSize,
    required this.screenSize,
    this.mirror = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final double previewW = previewSize.width;
    final double previewH = previewSize.height;
    final double screenW = screenSize.width;
    final double screenH = screenSize.height;

    // scale to fit (center-crop-like mapping)
    final double previewRatio = previewW / previewH;
    final double screenRatio = screenW / screenH;

    double scaleX, scaleY, dx = 0, dy = 0;
    if (screenRatio > previewRatio) {
      scaleY = screenH / previewH;
      scaleX = scaleY;
      final scaledPreviewW = previewW * scaleX;
      dx = (screenW - scaledPreviewW) / 2;
    } else {
      scaleX = screenW / previewW;
      scaleY = scaleX;
      final scaledPreviewH = previewH * scaleY;
      dy = (screenH - scaledPreviewH) / 2;
    }

    for (final det in detections) {
      final rectNorm = det.location;
      double left = rectNorm.left * previewW * scaleX + dx;
      double top = rectNorm.top * previewH * scaleY + dy;
      double right = rectNorm.right * previewW * scaleX + dx;
      double bottom = rectNorm.bottom * previewH * scaleY + dy;

      if (mirror) {
        final tmpLeft = left;
        left = screenW - right;
        right = screenW - tmpLeft;
      }

      final rect = Rect.fromLTRB(left, top, right, bottom);

      paint.color = _colorForLabel(det.label);
      canvas.drawRect(rect, paint);

      final textSpan = TextSpan(
        text: '${det.label} ${(det.score * 100).toStringAsFixed(0)}%',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      );
      final tp = TextPainter(text: textSpan, textDirection: ui.TextDirection.ltr);
      tp.layout(maxWidth: rect.width - 4);

      final bgRect = Rect.fromLTWH(rect.left, rect.top - tp.height - 6, tp.width + 6, tp.height + 4);
      final rrect = RRect.fromRectAndRadius(bgRect, const Radius.circular(4));
      final bgPaint = Paint()..color = paint.color.withOpacity(0.8);
      canvas.drawRRect(rrect, bgPaint);
      tp.paint(canvas, Offset(rect.left + 3, rect.top - tp.height - 4));
    }
  }

  Color _colorForLabel(String label) {
    final int hash = label.hashCode;
    final int r = (hash & 0xFF0000) >> 16;
    final int g = (hash & 0x00FF00) >> 8;
    final int b = (hash & 0x0000FF);
    return Color.fromARGB(255, r, g, b);
  }

  @override
  bool shouldRepaint(covariant DetectionBoxPainter oldDelegate) {
    return oldDelegate.detections != detections || oldDelegate.previewSize != previewSize || oldDelegate.screenSize != screenSize;
  }
}
