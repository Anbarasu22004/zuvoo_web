import 'dart:async';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../constants/content.dart';
import '../constants/layout.dart';
import '../theme/app_text.dart';
import 'web_video.dart';

/// Auto-advancing, swipeable carousel of real-life moments.
///
/// The cards (videos + captions) live in one DOM subtree and move with CSS
/// transforms on the compositor — silky even while videos play. The DOM
/// ignores pointers so page scrolling is never trapped; Flutter handles
/// drag, hover-pause and the arrow controls, then drives the track.
class MomentsCarousel extends StatefulWidget {
  const MomentsCarousel({super.key, required this.height});
  final double height;

  @override
  State<MomentsCarousel> createState() => _MomentsCarouselState();
}

class _MomentsCarouselState extends State<MomentsCarousel> with SingleTickerProviderStateMixin {
  static const _interval = Duration(milliseconds: 4600);
  static const _slide = Duration(milliseconds: 1100);

  final _index = ValueNotifier(0);
  late final AnimationController _progress = AnimationController(vsync: this, duration: _interval);

  web.HTMLDivElement? _track;
  Timer? _settle;
  bool _busy = false, _hovering = false, _dragging = false, _prepended = false;
  double _drag = 0, _step = 0;

  int get _count => Content.moments.length;

  @override
  void initState() {
    super.initState();
    _progress.addStatusListener((s) {
      if (s == AnimationStatus.completed) _next();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _progress.stop();
    } else if (!_hovering && !_dragging) {
      _progress.forward(from: _progress.value);
    }
  }

  @override
  void dispose() {
    _settle?.cancel();
    _progress.dispose();
    _index.dispose();
    super.dispose();
  }

  // ---------------- DOM ----------------

  void _build(Object element) {
    _ensureStyles();
    final root = element as web.HTMLDivElement;
    root.className = 'zv-car';
    final track = web.HTMLDivElement()..className = 'zv-track';
    for (var i = 0; i < _count; i++) {
      final m = Content.moments[i];
      final card = (web.document.createElement('article') as web.HTMLElement)..className = i == 0 ? 'zv-card is-active' : 'zv-card';
      final video = web.HTMLVideoElement();
      configureVideo(
        video,
        src: ui_web.assetManager.getAssetUrl(m.video),
        poster: ui_web.assetManager.getAssetUrl(m.poster),
        playbackRate: 0.7,
      );
      final shade = web.HTMLDivElement()..className = 'zv-shade';
      final meta = web.HTMLDivElement()..className = 'zv-meta';
      final idx = web.HTMLSpanElement()
        ..className = 'zv-idx'
        ..textContent = '${(i + 1).toString().padLeft(2, '0')}  ${m.place.toUpperCase()}';
      final h = web.document.createElement('h3')..textContent = m.title;
      final p = web.HTMLParagraphElement()..textContent = m.line;
      meta
        ..appendChild(idx)
        ..appendChild(h)
        ..appendChild(p);
      card
        ..appendChild(video)
        ..appendChild(shade)
        ..appendChild(meta);
      track.appendChild(card);
    }
    root.appendChild(track);
    _track = track;
    _applyLayout();
  }

  void _ensureStyles() {
    if (web.document.getElementById('zv-car-css') != null) return;
    final style = web.HTMLStyleElement()
      ..id = 'zv-car-css'
      ..textContent = '''
.zv-car{position:relative;width:100%;height:100%;overflow:hidden;pointer-events:none;
  -webkit-mask-image:linear-gradient(90deg,transparent 0,#000 4%,#000 96%,transparent 100%);
          mask-image:linear-gradient(90deg,transparent 0,#000 4%,#000 96%,transparent 100%)}
.zv-track{display:flex;height:100%;gap:var(--gap);padding-left:var(--pad);transform:translate3d(0,0,0);will-change:transform}
.zv-track.anim{transition:transform ${_slide.inMilliseconds}ms cubic-bezier(.77,0,.18,1)}
.zv-card{position:relative;flex:0 0 var(--cw);height:100%;border-radius:18px;overflow:hidden;background:#0b1113;
  box-shadow:0 40px 80px -30px rgba(0,0,0,.8);transform:translateZ(0);outline:1px solid rgba(255,255,255,.07);outline-offset:-1px}
.zv-card video{position:absolute;inset:0;transform:scale(1.08);transition:transform 5s cubic-bezier(.16,1,.3,1),filter 1.2s ease;filter:saturate(.85) brightness(.82)}
.zv-card.is-active video{transform:scale(1);filter:saturate(1) brightness(1)}
.zv-shade{position:absolute;inset:0;background:linear-gradient(180deg,rgba(0,0,0,0) 40%,rgba(0,0,0,.78) 100%)}
.zv-meta{position:absolute;left:clamp(16px,1.8vw,26px);right:clamp(16px,1.8vw,26px);bottom:clamp(16px,1.8vw,24px);color:#fff;
  font-family:"Inter Tight",Inter,system-ui,sans-serif;transform:translate3d(0,8px,0);opacity:.86;transition:transform 1s cubic-bezier(.16,1,.3,1),opacity 1s}
.zv-card.is-active .zv-meta{transform:none;opacity:1}
.zv-idx{font:500 11px/1 Inter,system-ui,sans-serif;letter-spacing:.16em;color:rgba(255,255,255,.7)}
.zv-meta h3{margin:10px 0 6px;font-weight:500;font-size:clamp(20px,1.9vw,30px);line-height:1.1;letter-spacing:-.025em}
.zv-meta p{margin:0;font:400 clamp(13px,1vw,15px)/1.45 Inter,system-ui,sans-serif;color:rgba(255,255,255,.8);max-width:34ch}
@media (prefers-reduced-motion:reduce){.zv-track.anim{transition:none}.zv-card video{transition:none}}
''';
    web.document.head!.appendChild(style);
  }

  void _applyLayout() {
    final t = _track;
    if (t == null || !mounted) return;
    final w = context.vw;
    final cw = context.responsive(mobile: w * 0.8, tablet: w * 0.46, desktop: (w * 0.3).clamp(340.0, 560.0));
    final gap = context.responsive(mobile: 12.0, desktop: 20.0);
    _step = cw + gap;
    t.style
      ..setProperty('--cw', '${cw}px')
      ..setProperty('--gap', '${gap}px')
      ..setProperty('--pad', '${context.gutter}px');
  }

  void _setX(double x, {bool animate = false}) {
    final t = _track;
    if (t == null) return;
    if (animate) {
      t.classList.add('anim');
    } else {
      t.classList.remove('anim');
    }
    t.style.transform = 'translate3d(${x.toStringAsFixed(2)}px,0,0)';
  }

  void _markActive() {
    final cards = _track?.children;
    if (cards == null) return;
    for (var i = 0; i < cards.length; i++) {
      final c = cards.item(i)!;
      if (i == 0) {
        c.classList.add('is-active');
      } else {
        c.classList.remove('is-active');
      }
    }
  }

  void _rotateForward() {
    final t = _track!;
    t.appendChild(t.firstElementChild!);
    _resumeVideo(t.lastElementChild);
  }

  void _rotateBackward() {
    final t = _track!;
    t.insertBefore(t.lastElementChild!, t.firstElementChild);
    _resumeVideo(t.firstElementChild);
  }

  // Re-inserting a <video> pauses it; start it again.
  void _resumeVideo(web.Element? card) {
    final v = card?.querySelector('video');
    if (v != null) (v as web.HTMLVideoElement).play();
  }

  // ---------------- motion ----------------

  void _animateTo(double x, VoidCallback onDone) {
    _busy = true;
    _setX(x, animate: true);
    _settle?.cancel();
    _settle = Timer(_slide, () {
      if (!mounted) return;
      onDone();
      _busy = false;
      _markActive();
      _restartTimer();
    });
  }

  void _next() {
    if (_busy || _track == null) return;
    _index.value = (_index.value + 1) % _count;
    _animateTo(-_step, () {
      _rotateForward();
      _setX(0);
    });
  }

  void _prev() {
    if (_busy || _track == null) return;
    _index.value = (_index.value - 1 + _count) % _count;
    _rotateBackward();
    _setX(-_step);
    _track!.getBoundingClientRect(); // force layout so the transition runs
    _animateTo(0, () {});
  }

  void _restartTimer() {
    if (context.reduceMotion || _hovering || _dragging) return;
    _progress.forward(from: 0);
  }

  void _onDragStart(DragStartDetails _) {
    if (_busy) return;
    _dragging = true;
    _progress.stop();
    _drag = 0;
    _prepended = false;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    _drag = (_drag + d.delta.dx).clamp(-_step, _step);
    if (_drag > 0 && !_prepended) {
      _rotateBackward();
      _prepended = true;
    } else if (_drag <= 0 && _prepended) {
      _rotateForward();
      _prepended = false;
    }
    _setX((_prepended ? -_step : 0) + _drag);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_dragging) return;
    _dragging = false;
    final v = d.primaryVelocity ?? 0;
    final threshold = _step * 0.18;
    if (_prepended) {
      if (_drag > threshold || v > 400) {
        _index.value = (_index.value - 1 + _count) % _count;
        _animateTo(0, () {});
      } else {
        _animateTo(-_step, () {
          _rotateForward();
          _setX(0);
        });
      }
    } else {
      if (_drag < -threshold || v < -400) {
        _index.value = (_index.value + 1) % _count;
        _animateTo(-_step, () {
          _rotateForward();
          _setX(0);
        });
      } else {
        _animateTo(0, () {});
      }
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyLayout());
    final controls = Padding(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      child: Row(children: [
        ValueListenableBuilder<int>(
          valueListenable: _index,
          builder: (context, i, _) => Text(
            '${(i + 1).toString().padLeft(2, '0')} / ${_count.toString().padLeft(2, '0')}',
            style: AppText.caps(Colors.white, size: 13),
          ),
        ),
        const Spacer(),
        const SizedBox(width: 20),
        _RoundButton(icon: Icons.arrow_back_rounded, label: 'Previous moment', onTap: _prev),
        const SizedBox(width: 10),
        _RoundButton(icon: Icons.arrow_forward_rounded, label: 'Next moment', onTap: _next),
      ]),
    );

    return MouseRegion(
      onEnter: (_) {
        _hovering = true;
        _progress.stop();
      },
      onExit: (_) {
        _hovering = false;
        if (!_busy && !context.reduceMotion) _progress.forward();
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        controls,
        const SizedBox(height: 18),
        SizedBox(
          height: widget.height,
          child: Stack(fit: StackFit.expand, children: [
            HtmlElementView.fromTagName(tagName: 'div', onElementCreated: _build),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
            ),
          ]),
        ),
      ]),
    );
  }
}

class _RoundButton extends StatefulWidget {
  const _RoundButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<_RoundButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: widget.label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hover ? Colors.white : Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: Icon(widget.icon, size: 18, color: _hover ? Colors.black : Colors.white),
            ),
          ),
        ),
      );
}
