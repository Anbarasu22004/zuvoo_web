import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Page scroller tuned for the web:
///  * mouse-wheel input is eased toward its target (no stepped, jumpy wheel)
///  * children are laid out lazily in a sliver list, so off-screen sections
///    are neither built nor painted — the main cause of scroll lag before
///  * touch and trackpad drags keep native physics
class SmoothScrollView extends StatefulWidget {
  const SmoothScrollView({super.key, required this.controller, required this.children});

  final ScrollController controller;
  final List<Widget> children;

  @override
  State<SmoothScrollView> createState() => _SmoothScrollViewState();
}

class _SmoothScrollViewState extends State<SmoothScrollView> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  double _target = 0;
  Duration _last = Duration.zero;

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (e) {
      final delta = (e as PointerScrollEvent).scrollDelta.dy;
      final pos = widget.controller.position;
      if (MediaQuery.of(context).disableAnimations) {
        pos.jumpTo((pos.pixels + delta).clamp(pos.minScrollExtent, pos.maxScrollExtent));
        return;
      }
      if (!_ticker.isActive) _target = pos.pixels;
      _target = (_target + delta).clamp(pos.minScrollExtent, pos.maxScrollExtent);
      if (!_ticker.isActive) {
        _last = Duration.zero;
        _ticker.start();
      }
    });
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero ? 1 / 60 : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final pos = widget.controller.position;
    // Frame-rate independent exponential ease.
    final k = 1 - math.pow(1 - 0.16, dt * 60).toDouble();
    final next = pos.pixels + (_target - pos.pixels) * k;
    if ((_target - next).abs() < 0.4) {
      pos.jumpTo(_target);
      _ticker.stop();
    } else {
      pos.jumpTo(next);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      controller: widget.controller,
      physics: const ClampingScrollPhysics(),
      viewportBuilder: (context, offset) => Listener(
        onPointerSignal: _onPointerSignal,
        child: Viewport(
          offset: offset,
          cacheExtent: 400,
          slivers: [
            SliverList(delegate: SliverChildListDelegate(widget.children, addAutomaticKeepAlives: false)),
          ],
        ),
      ),
    );
  }
}
