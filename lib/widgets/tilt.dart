import 'package:flutter/material.dart';

import '../constants/layout.dart';

/// Tilts its child toward the cursor with a little depth. Springs back on exit.
class Tilt extends StatefulWidget {
  const Tilt({super.key, required this.child, this.maxAngle = 0.06, this.lift = 6});
  final Widget child;
  final double maxAngle, lift;

  @override
  State<Tilt> createState() => _TiltState();
}

class _TiltState extends State<Tilt> {
  Offset _t = Offset.zero;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onHover: (e) {
        final s = context.size;
        if (s == null) return;
        setState(() => _t = Offset(e.localPosition.dx / s.width * 2 - 1, e.localPosition.dy / s.height * 2 - 1));
      },
      onExit: (_) => setState(() {
        _hover = false;
        _t = Offset.zero;
      }),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(end: _t),
        duration: const Duration(milliseconds: 500),
        curve: const Cubic(0.16, 1, 0.3, 1),
        builder: (context, v, child) => TweenAnimationBuilder<double>(
          tween: Tween(end: _hover ? 1 : 0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, h, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-v.dy * widget.maxAngle)
              ..rotateY(v.dx * widget.maxAngle)
              ..setTranslationRaw(0, -widget.lift * h, 0),
            child: child,
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
