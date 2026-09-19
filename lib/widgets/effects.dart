import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/layout.dart';
import '../theme/app_colors.dart';

/// Soft drifting light particles for dark story scenes.
class Dust extends StatefulWidget {
  const Dust({super.key, this.color = Colors.white, this.count = 60, this.opacity = 1});
  final Color color;
  final int count;
  final double opacity;

  @override
  State<Dust> createState() => _DustState();
}

class _DustState extends State<Dust> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 30));

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
          painter: _DustPainter(_c, widget.color, widget.count, widget.opacity),
          child: const SizedBox.expand(),
        ),
      );
}

class _DustPainter extends CustomPainter {
  _DustPainter(this.a, this.color, this.count, this.opacity) : super(repaint: a);
  final Animation<double> a;
  final Color color;
  final int count;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;
    final rnd = math.Random(21);
    final p = Paint();
    for (var i = 0; i < count; i++) {
      final speed = 0.3 + rnd.nextDouble();
      final x = (rnd.nextDouble() + a.value * 0.05 * speed) % 1.0;
      final y = (rnd.nextDouble() - a.value * 0.12 * speed) % 1.0;
      final r = 0.6 + rnd.nextDouble() * 1.6;
      final tw = 0.5 + 0.5 * math.sin(a.value * 2 * math.pi * 3 + i);
      p.color = color.withValues(alpha: clamp01((0.08 + rnd.nextDouble() * 0.3) * tw * opacity));
      canvas.drawCircle(Offset(x * size.width, y * size.height), r, p);
    }
  }

  @override
  bool shouldRepaint(_DustPainter old) => old.opacity != opacity || old.color != color;
}

/// Radial warm/teal glow used behind 3D objects.
class Glow extends StatelessWidget {
  const Glow({super.key, this.color = AppColors.accent, this.opacity = 0.3});
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ]),
        ),
      );
}
