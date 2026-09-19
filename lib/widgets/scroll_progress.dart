import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/layout.dart';

/// Where a section sits relative to the viewport.
@immutable
class ScrollInfo {
  const ScrollInfo({required this.top, required this.height, required this.viewport});
  static const offscreen = ScrollInfo(top: 100000, height: 1, viewport: 1);

  final double top, height, viewport;

  /// 0 when the section's top reaches the viewport bottom, 1 when its bottom leaves the top.
  double get through => clamp01((viewport - top) / (height + viewport));

  /// 0..1 while a tall section is pinned.
  double get pinned => height <= viewport ? 0 : clamp01(-top / (height - viewport));

  /// Fraction of the section scrolled above the viewport top.
  double get exited => clamp01(-top / height);

  double get pinOffset => (-top).clamp(0.0, math.max(0.0, height - viewport));

  bool sameAs(ScrollInfo o) => (top - o.top).abs() < 0.25 && height == o.height && viewport == o.viewport;
}

/// Tracks a section's scroll position in a [ValueNotifier] — no rebuilds.
/// Animate only the leaves that need it with [ValueListenableBuilder] or a
/// painter's `repaint`, so scrolling stays cheap.
class SectionScroll extends StatefulWidget {
  const SectionScroll({super.key, required this.builder});
  final Widget Function(BuildContext context, ValueListenable<ScrollInfo> info) builder;

  @override
  State<SectionScroll> createState() => _SectionScrollState();
}

class _SectionScrollState extends State<SectionScroll> {
  final _info = ValueNotifier(ScrollInfo.offscreen);
  ScrollPosition? _position;
  double _vh = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pos = Scrollable.maybeOf(context)?.position;
    if (pos != _position) {
      _position?.removeListener(_measure);
      _position = pos;
      _position?.addListener(_measure);
    }
  }

  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final next = ScrollInfo(top: box.localToGlobal(Offset.zero).dy, height: box.size.height, viewport: _vh);
    if (!next.sameAs(_info.value)) _info.value = next;
  }

  @override
  void dispose() {
    _position?.removeListener(_measure);
    _info.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _vh = MediaQuery.sizeOf(context).height;
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    return widget.builder(context, _info);
  }
}

/// A section [screens] viewport-heights tall whose content stays pinned while
/// scrolling through it. The content is built once; only a paint-time
/// translate runs per frame.
class PinnedScene extends StatelessWidget {
  const PinnedScene({super.key, required this.screens, required this.builder});
  final double screens;
  final Widget Function(BuildContext context, ValueListenable<ScrollInfo> info) builder;

  @override
  Widget build(BuildContext context) {
    final vh = context.vh;
    return SizedBox(
      height: vh * screens,
      child: SectionScroll(
        builder: (context, info) => Stack(clipBehavior: Clip.hardEdge, children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: vh,
            child: ValueListenableBuilder<ScrollInfo>(
              valueListenable: info,
              child: RepaintBoundary(child: builder(context, info)),
              builder: (context, i, child) =>
                  Transform.translate(offset: Offset(0, i.top > 99999 ? 0 : i.pinOffset), child: child),
            ),
          ),
        ]),
      ),
    );
  }
}
