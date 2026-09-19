import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// "What comes next": two named glowing paths lead into the distance, then
/// unnamed paths branch off toward new horizons while the camera drifts forward.
class FuturePaths extends StatefulWidget {
  const FuturePaths({super.key, required this.progress, this.labels = const ['Understand', 'Act']});
  final double progress;
  final List<String> labels;

  @override
  State<FuturePaths> createState() => _FuturePathsState();
}

class _FuturePathsState extends State<FuturePaths> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 20));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          painter: _FuturePainter(_c, widget.progress, widget.labels),
          child: const SizedBox.expand(),
        ),
      );
}

class _FuturePainter extends CustomPainter {
  _FuturePainter(this.time, this.progress, this.labels) : super(repaint: time);
  final Animation<double> time;
  final double progress;
  final List<String> labels;

  static double _s(double e0, double e1, double x) {
    final t = ((x - e0) / (e1 - e0)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = progress;
    final t = time.value;
    final horizonY = h * 0.5;

    // Camera drifts forward: scale the world around the horizon
    final zoom = 1 + p * 0.28;
    canvas.save();
    canvas.translate(w / 2, horizonY);
    canvas.scale(zoom);
    canvas.translate(-w / 2, -horizonY);

    // Horizon glow
    final glowC = Offset(w / 2, horizonY);
    canvas.drawCircle(
      glowC,
      w * 0.45,
      Paint()
        ..shader = RadialGradient(colors: [
          AppColors.accent.withValues(alpha: 0.10 + 0.12 * p),
          AppColors.tealLight.withValues(alpha: 0.10),
          Colors.transparent,
        ], stops: const [0, 0.35, 1]).createShader(Rect.fromCircle(center: glowC, radius: w * 0.45)),
    );

    // Ground lines rushing toward the viewer
    final ground = Paint()..strokeWidth = 1;
    for (var i = 0; i < 14; i++) {
      final k = (i / 14 + t) % 1.0;
      final y = horizonY + math.pow(k, 2.4).toDouble() * (h - horizonY) * 1.05;
      ground.color = AppColors.mint.withValues(alpha: 0.02 + 0.06 * k);
      canvas.drawLine(Offset(0, y), Offset(w, y), ground);
    }

    Path curve(Offset a, Offset b, double bend) => Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(a.dx, a.dy - (a.dy - b.dy) * 0.45, b.dx + bend, b.dy + (a.dy - b.dy) * 0.25, b.dx, b.dy);

    void glowPath(Path path, double frac, Color color, double width, double alpha) {
      if (frac <= 0) return;
      final m = path.computeMetrics().first;
      final part = m.extractPath(0, m.length * frac);
      canvas.drawPath(
        part,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 5
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: alpha * 0.22)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 3),
      );
      canvas.drawPath(
        part,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: alpha),
      );
      // Light pulses travelling outward
      for (var k = 0; k < 3; k++) {
        final u = ((t * 1.4 + k / 3) % 1.0) * frac;
        final pos = m.getTangentForOffset(m.length * u)?.position;
        if (pos == null) continue;
        final fade = 1 - u;
        canvas.drawCircle(pos, width * 1.6, Paint()..color = Colors.white.withValues(alpha: 0.7 * alpha * fade));
      }
    }

    // Named paths
    final named = [
      (Offset(w * 0.30, h + 20), Offset(w * 0.47, horizonY + 2), -w * 0.02, AppColors.mint),
      (Offset(w * 0.70, h + 20), Offset(w * 0.53, horizonY + 2), w * 0.02, AppColors.accent),
    ];
    final namedFrac = _s(0.0, 0.35, p) * 0.94 + 0.06;
    for (final (a, b, bend, c) in named) {
      glowPath(curve(a, b, bend), namedFrac, c, 2.6, 0.95);
    }

    // Unnamed future paths branch off and head to new horizons
    final futures = [
      (0.30, -0.36), (0.30, -0.22), (0.30, -0.10), (0.70, 0.10), (0.70, 0.22), (0.70, 0.36), (0.30, 0.02), (0.70, -0.02),
    ];
    for (var i = 0; i < futures.length; i++) {
      final (startX, endOff) = futures[i];
      final start = Offset(w * startX + (startX < 0.5 ? w * 0.06 : -w * 0.06), h * 0.82);
      final end = Offset(w * (0.5 + endOff), horizonY + 4 + (i.isEven ? 0 : h * 0.01));
      final appear = _s(0.3 + i * 0.05, 0.6 + i * 0.05, p);
      glowPath(curve(start, end, endOff * w * 0.1), appear, AppColors.mintStrong, 1.2, 0.45);
    }
    canvas.restore();

    // Labels at the base of the named paths (unscaled for legibility)
    final labelAlpha = _s(0.05, 0.25, p);
    if (labelAlpha > 0) {
      for (var i = 0; i < math.min(2, labels.length); i++) {
        final tp = TextPainter(
          text: TextSpan(text: labels[i], style: AppText.label(Colors.white.withValues(alpha: labelAlpha), size: 14)),
          textDirection: TextDirection.ltr,
        )..layout();
        final x = w * (i == 0 ? 0.33 : 0.67);
        final y = h * 0.86;
        final r = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: tp.width + 28, height: tp.height + 16),
          const Radius.circular(999),
        );
        canvas.drawRRect(r, Paint()..color = AppColors.tealDeep.withValues(alpha: 0.85 * labelAlpha));
        canvas.drawRRect(r, Paint()
          ..style = PaintingStyle.stroke
          ..color = (i == 0 ? AppColors.mint : AppColors.accent).withValues(alpha: 0.6 * labelAlpha));
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_FuturePainter old) => old.progress != progress;
}
