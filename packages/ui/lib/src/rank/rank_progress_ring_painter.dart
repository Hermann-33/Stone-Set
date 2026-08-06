import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class RankProgressRingGeometry {
  static const startAngle = -math.pi / 2;
  static const fullSweep = math.pi * 2;

  static double clamp(double fraction) => fraction.clamp(0.0, 1.0).toDouble();
  static double sweep(double fraction) => fullSweep * clamp(fraction);
  static bool isComplete(double fraction) => clamp(fraction) == 1;
}

class RankProgressRingPainter extends CustomPainter {
  const RankProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.activeColor,
    this.strokeWidth = 10,
    this.provisionalProgress,
    this.provisionalColor,
  });

  final double progress;
  final Color trackColor;
  final Color activeColor;
  final double strokeWidth;
  final double? provisionalProgress;
  final Color? provisionalColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    final value = RankProgressRingGeometry.clamp(progress);
    if (value > 0) {
      final activePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = value == 1 ? StrokeCap.butt : StrokeCap.round
        ..color = activeColor;
      if (value == 1) {
        // A circle avoids the doubled cap or top seam produced by a 2pi arc.
        canvas.drawCircle(center, radius, activePaint);
      } else {
        canvas.drawArc(
          bounds,
          RankProgressRingGeometry.startAngle,
          RankProgressRingGeometry.sweep(value),
          false,
          activePaint,
        );
      }
    }

    final provisional = provisionalProgress;
    if (provisional != null && provisional > value && provisionalColor != null) {
      final provisionalPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, strokeWidth / 3)
        ..strokeCap = StrokeCap.butt
        ..color = provisionalColor!;
      final outerRadius = radius + strokeWidth;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        RankProgressRingGeometry.startAngle,
        RankProgressRingGeometry.sweep(provisional),
        false,
        provisionalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RankProgressRingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      trackColor != oldDelegate.trackColor ||
      activeColor != oldDelegate.activeColor ||
      strokeWidth != oldDelegate.strokeWidth ||
      provisionalProgress != oldDelegate.provisionalProgress ||
      provisionalColor != oldDelegate.provisionalColor;
}
