import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

typedef _Pt = Offset Function(double x, double y);
_Pt _norm(Size s) => (x, y) => Offset(x * s.width, y * s.height);

Paint _stroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Leaf/feather mark with a light vein cut through it.
class LeafMark extends StatelessWidget {
  const LeafMark({super.key, this.size = 28, this.color = AppColors.teal, this.vein = Colors.white});
  final double size;
  final Color color, vein;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: CustomPaint(painter: _LeafPainter(color, vein)));
}

class _LeafPainter extends CustomPainter {
  _LeafPainter(this.color, this.vein);
  final Color color, vein;

  @override
  void paint(Canvas canvas, Size s) {
    final o = _norm(s);
    Path leaf(double dx, double dy, double k) {
      Offset q(double x, double y) => o(dx + x * k, dy + y * k);
      return Path()
        ..moveTo(q(0.10, 0.92).dx, q(0.10, 0.92).dy)
        ..cubicTo(q(0.02, 0.48).dx, q(0.02, 0.48).dy, q(0.42, 0.06).dx, q(0.42, 0.06).dy, q(0.92, 0.04).dx, q(0.92, 0.04).dy)
        ..cubicTo(q(0.96, 0.52).dx, q(0.96, 0.52).dy, q(0.58, 0.94).dx, q(0.58, 0.94).dy, q(0.10, 0.92).dx, q(0.10, 0.92).dy)
        ..close();
    }

    final cut = vein.a == 0;
    if (cut) canvas.saveLayer(Offset.zero & s, Paint());
    canvas.drawPath(leaf(0, 0, 1), Paint()..color = color);
    final v = Path()
      ..moveTo(o(0.06, 0.98).dx, o(0.06, 0.98).dy)
      ..quadraticBezierTo(o(0.40, 0.62).dx, o(0.40, 0.62).dy, o(0.78, 0.20).dx, o(0.78, 0.20).dy);
    canvas.drawPath(v, _stroke(cut ? Colors.black : vein, s.width * 0.075)..blendMode = cut ? BlendMode.clear : BlendMode.srcOver);
    if (cut) canvas.restore();
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.color != color || old.vein != vein;
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 20, this.color = Colors.white, this.linked = true});
  final double size;
  final Color color;
  final bool linked;

  @override
  Widget build(BuildContext context) {
    final mark = Row(mainAxisSize: MainAxisSize.min, children: [
      LeafMark(size: size * 1.45, color: color, vein: Colors.transparent),
      SizedBox(width: size * 0.55),
      Text('ZUVOO', style: AppText.caps(color, size: size).copyWith(fontWeight: FontWeight.w600, letterSpacing: size * 0.16)),
    ]);
    if (!linked) return mark;
    return Semantics(
      link: true,
      label: 'Zuvoo home',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: () => context.go('/'), child: ExcludeSemantics(child: mark)),
      ),
    );
  }
}

enum ValueKind { simplicity, trust, speed }

class ValueIcon extends StatelessWidget {
  const ValueIcon({super.key, required this.kind, this.size = 44});
  final ValueKind kind;
  final double size;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: CustomPaint(painter: _ValuePainter(kind)));
}

class _ValuePainter extends CustomPainter {
  _ValuePainter(this.kind);
  final ValueKind kind;

  @override
  void paint(Canvas canvas, Size s) {
    final o = _norm(s);
    final p = _stroke(AppColors.tealBright, 1.6);
    switch (kind) {
      case ValueKind.simplicity:
        canvas.drawCircle(o(0.5, 0.5), s.width * 0.36, p);
        canvas.drawCircle(o(0.5, 0.5), s.width * 0.05, Paint()..color = AppColors.accent);
      case ValueKind.trust:
        final path = Path()
          ..moveTo(o(0.5, 0.1).dx, o(0.5, 0.1).dy)
          ..lineTo(o(0.84, 0.24).dx, o(0.84, 0.24).dy)
          ..lineTo(o(0.84, 0.5).dx, o(0.84, 0.5).dy)
          ..cubicTo(o(0.84, 0.72).dx, o(0.84, 0.72).dy, o(0.66, 0.84).dx, o(0.66, 0.84).dy, o(0.5, 0.9).dx, o(0.5, 0.9).dy)
          ..cubicTo(o(0.34, 0.84).dx, o(0.34, 0.84).dy, o(0.16, 0.72).dx, o(0.16, 0.72).dy, o(0.16, 0.5).dx, o(0.16, 0.5).dy)
          ..lineTo(o(0.16, 0.24).dx, o(0.16, 0.24).dy)
          ..close();
        canvas.drawPath(path, p);
      case ValueKind.speed:
        final l1 = Path()
          ..moveTo(o(0.1, 0.38).dx, o(0.1, 0.38).dy)
          ..lineTo(o(0.62, 0.38).dx, o(0.62, 0.38).dy)
          ..cubicTo(o(0.84, 0.38).dx, o(0.84, 0.38).dy, o(0.84, 0.14).dx, o(0.84, 0.14).dy, o(0.66, 0.16).dx, o(0.66, 0.16).dy);
        final l2 = Path()
          ..moveTo(o(0.1, 0.56).dx, o(0.1, 0.56).dy)
          ..lineTo(o(0.76, 0.56).dx, o(0.76, 0.56).dy)
          ..cubicTo(o(0.94, 0.56).dx, o(0.94, 0.56).dy, o(0.94, 0.8).dx, o(0.94, 0.8).dy, o(0.78, 0.8).dx, o(0.78, 0.8).dy);
        canvas.drawPath(l1, p);
        canvas.drawPath(l2, p);
        canvas.drawLine(o(0.24, 0.74), o(0.5, 0.74), _stroke(AppColors.accent, 1.8));
    }
  }

  @override
  bool shouldRepaint(_ValuePainter old) => old.kind != kind;
}
