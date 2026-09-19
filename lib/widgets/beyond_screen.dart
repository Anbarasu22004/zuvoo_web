import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../constants/layout.dart';
import '../theme/app_colors.dart';
import 'scroll_progress.dart';

/// The Zuvoo idea as a 3D scene, driven by scroll:
///
///  1. **On screen** — points form a glass screen showing an interface.
///  2. **Beyond it** — the points break out of the screen toward the viewer.
///  3. **Real world** — they settle into a globe; warm clusters mark real
///     places, linked by arcs of light.
///
/// One point cloud, drawn with a handful of `drawRawPoints` calls per frame.
class BeyondScreen extends StatefulWidget {
  const BeyondScreen({super.key, required this.info, this.dense = true});

  final ValueListenable<ScrollInfo> info;
  final bool dense;

  @override
  State<BeyondScreen> createState() => _BeyondScreenState();
}

class _BeyondScreenState extends State<BeyondScreen> with SingleTickerProviderStateMixin {
  final _clock = _Clock();
  late final Ticker _ticker = createTicker((e) => _clock.tick(e.inMicroseconds / 1e6));
  late _Cloud _cloud = _Cloud(widget.dense);

  @override
  void didUpdateWidget(BeyondScreen old) {
    super.didUpdateWidget(old);
    if (old.dense != widget.dense) _cloud = _Cloud(widget.dense);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      if (_ticker.isActive) _ticker.stop();
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          painter: _BeyondPainter(_cloud, _clock, widget.info),
          child: const SizedBox.expand(),
        ),
      );
}

class _Clock extends ChangeNotifier {
  double t = 0;
  void tick(double v) {
    t = v;
    notifyListeners();
  }
}

/// Precomputed geometry for the three stages.
class _Cloud {
  _Cloud(bool dense) {
    final cols = dense ? 52 : 34, rows = dense ? 32 : 22;
    n = cols * rows;
    ax = Float32List(n);
    ay = Float32List(n);
    bx = Float32List(n);
    by = Float32List(n);
    bz = Float32List(n);
    cx = Float32List(n);
    cy = Float32List(n);
    cz = Float32List(n);
    glow = Float32List(n);
    stagger = Float32List(n);
    warm = List<bool>.filled(n, false);

    final rnd = math.Random(5);
    // Warm "places" on the globe
    for (var j = 0; j < 11; j++) {
      final la = math.acos(1 - 2 * rnd.nextDouble());
      final lo = rnd.nextDouble() * 2 * math.pi;
      places.add([math.sin(la) * math.cos(lo), math.cos(la), math.sin(la) * math.sin(lo)]);
    }
    const golden = math.pi * (3 - 2.2360679775);
    for (var i = 0; i < n; i++) {
      final c = i % cols, r = i ~/ cols;
      // 1 · screen with a simple interface layout
      final x = (c / (cols - 1) - 0.5) * 2.4, y = (0.5 - r / (rows - 1)) * 1.5;
      ax[i] = x;
      ay[i] = y;
      final fc = c / cols, fr = r / rows;
      var g = 0.28;
      if (fr < 0.1) g = 1.0; // top bar
      if (fc > 0.08 && fc < 0.42 && fr > 0.2 && fr < 0.8) g = 0.8; // main card
      if (fc > 0.48 && fc < 0.92 && fr > 0.2 && fr < 0.38) g = 0.9; // headline block
      if (fc > 0.48 && fc < 0.92 && fr > 0.45 && fr < 0.8) g = 0.6; // list
      glow[i] = g;

      // 2 · bursting out of the screen, swirling toward the viewer
      final s = rnd.nextDouble();
      final rot = s * 1.2, k = 1.2 + 0.95 * s;
      bx[i] = (x * math.cos(rot) - y * math.sin(rot)) * k;
      by[i] = (x * math.sin(rot) + y * math.cos(rot)) * k;
      bz[i] = -0.3 - 1.5 * s;

      // 3 · globe (Fibonacci sphere)
      final lat = math.acos(1 - 2 * (i + 0.5) / n), lon = golden * i;
      final ux = math.sin(lat) * math.cos(lon), uy = math.cos(lat), uz = math.sin(lat) * math.sin(lon);
      cx[i] = ux * radius;
      cy[i] = uy * radius;
      cz[i] = uz * radius;
      for (final p in places) {
        if (ux * p[0] + uy * p[1] + uz * p[2] > math.cos(0.17)) warm[i] = true;
      }
      stagger[i] = rnd.nextDouble();
    }
  }

  static const radius = 1.2;
  late final int n;
  late final Float32List ax, ay, bx, by, bz, cx, cy, cz, glow, stagger;
  late final List<bool> warm;
  final places = <List<double>>[];
}

class _BeyondPainter extends CustomPainter {
  _BeyondPainter(this.cloud, this.clock, this.info) : super(repaint: Listenable.merge([clock, info]));

  final _Cloud cloud;
  final _Clock clock;
  final ValueListenable<ScrollInfo> info;

  static const _camD = 4.2;
  static const _mint = Color(0xFFDDF1EE);

  @override
  void paint(Canvas canvas, Size size) {
    final i0 = info.value;
    final p = i0.top > 99999 ? 0.0 : i0.pinned;
    final t = clock.t;
    final unit = math.min(size.width, size.height) * 0.3;
    final ox = size.width / 2, oy = size.height / 2;

    final yaw = -0.4 + p * 2.0 + math.sin(t * 0.25) * 0.05;
    final pitch = 0.1 + 0.2 * smoothstep(0.5, 0.9, p) + math.sin(t * 0.2) * 0.02;
    final cyw = math.cos(yaw), syw = math.sin(yaw), cp = math.cos(pitch), sp = math.sin(pitch);

    Offset project(double x, double y, double z) {
      final x1 = x * cyw - z * syw, z1 = x * syw + z * cyw;
      final y2 = y * cp - z1 * sp, z2 = y * sp + z1 * cp;
      final k = _camD / (_camD + z2);
      return Offset(ox + x1 * unit * k, oy - y2 * unit * k);
    }

    // 1 · glass screen frame fades as points leave it
    final frame = 1 - smoothstep(0.18, 0.4, p);
    if (frame > 0.01) {
      final corners = [project(-1.3, 0.86, 0), project(1.3, 0.86, 0), project(1.3, -0.86, 0), project(-1.3, -0.86, 0)];
      final path = Path()..addPolygon(corners, true);
      canvas.drawPath(path, Paint()..color = _mint.withValues(alpha: 0.04 * frame));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _mint.withValues(alpha: 0.65 * frame),
      );
    }

    // Points, bucketed by brightness so the whole cloud is ~6 draw calls.
    final buckets = List.generate(4, (_) => <double>[]);
    final warmPts = <double>[];
    final c = cloud;
    final settled = smoothstep(0.7, 0.95, p);
    for (var i = 0; i < c.n; i++) {
      final lag = c.stagger[i] * 0.08;
      final a = smoothstep(0.18, 0.46, p - lag + 0.04);
      final b = smoothstep(0.54, 0.84, p - lag + 0.04);
      var x = c.ax[i] + (c.bx[i] - c.ax[i]) * a;
      var y = c.ay[i] + (c.by[i] - c.ay[i]) * a;
      var z = c.bz[i] * a;
      x += (c.cx[i] - x) * b;
      y += (c.cy[i] + math.sin(t * 0.8 + i) * 0.004 - y) * b;
      z += (c.cz[i] - z) * b;

      final x1 = x * cyw - z * syw, z1 = x * syw + z * cyw;
      final y2 = y * cp - z1 * sp, z2 = y * sp + z1 * cp;
      final k = _camD / (_camD + z2);
      final sx = ox + x1 * unit * k, sy = oy - y2 * unit * k;

      if (c.warm[i] && b > 0.5) {
        warmPts
          ..add(sx)
          ..add(sy);
        continue;
      }
      final bright = c.glow[i] * (1 - b) + 0.45 * b;
      final depth = ((k - 0.55) / 0.8).clamp(0.2, 1.0);
      final level = (bright * depth * 3.99).floor().clamp(0, 3);
      buckets[level]
        ..add(sx)
        ..add(sy);
    }

    const alphas = [0.16, 0.34, 0.6, 0.95];
    for (var l = 0; l < 4; l++) {
      if (buckets[l].isEmpty) continue;
      canvas.drawRawPoints(
        ui.PointMode.points,
        Float32List.fromList(buckets[l]),
        Paint()
          ..color = _mint.withValues(alpha: alphas[l])
          ..strokeWidth = 1.4 + l * 0.35
          ..strokeCap = StrokeCap.round,
      );
    }

    // 3 · real-world layer: rings, places and the arcs linking them
    if (settled > 0.01) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _mint.withValues(alpha: 0.14 * settled);
      for (final tilt in [0.0, 0.9]) {
        final path = Path();
        for (var s = 0; s <= 72; s++) {
          final a = s / 72 * 2 * math.pi;
          final px = math.cos(a) * _Cloud.radius * 1.28;
          final pz = math.sin(a) * _Cloud.radius * 1.28;
          final pt = project(px, pz * math.sin(tilt), pz * math.cos(tilt));
          if (s == 0) {
            path.moveTo(pt.dx, pt.dy);
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
        }
        canvas.drawPath(path, ring);
      }

      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round
        ..color = AppColors.accent.withValues(alpha: 0.55 * settled);
      final pulse = Paint()..color = Colors.white.withValues(alpha: 0.9 * settled);
      final pl = c.places;
      for (var j = 0; j < pl.length - 1; j += 2) {
        final a = pl[j], b = pl[j + 1];
        final path = Path();
        Offset? mid;
        final pos = (t * 0.35 + j * 0.13) % 1.0;
        for (var s = 0; s <= 28; s++) {
          final u = s / 28;
          var vx = a[0] + (b[0] - a[0]) * u, vy = a[1] + (b[1] - a[1]) * u, vz = a[2] + (b[2] - a[2]) * u;
          final len = math.sqrt(vx * vx + vy * vy + vz * vz);
          final lift = _Cloud.radius * (1 + 0.28 * math.sin(math.pi * u)) / len;
          vx *= lift;
          vy *= lift;
          vz *= lift;
          final pt = project(vx, vy, vz);
          if (s == 0) {
            path.moveTo(pt.dx, pt.dy);
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
          if ((u - pos).abs() < 1 / 56) mid = pt;
        }
        canvas.drawPath(path, arc);
        if (mid != null) canvas.drawCircle(mid, 2.4, pulse);
      }
    }

    if (warmPts.isNotEmpty) {
      final list = Float32List.fromList(warmPts);
      canvas.drawRawPoints(
        ui.PointMode.points,
        list,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.18)
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawRawPoints(
        ui.PointMode.points,
        list,
        Paint()
          ..color = const Color(0xFFFFC98E)
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_BeyondPainter old) => old.cloud != cloud;
}
