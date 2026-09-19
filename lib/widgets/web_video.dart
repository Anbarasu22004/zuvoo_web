import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

import '../constants/layout.dart';

/// Native `<video muted autoplay loop playsinline>` — reliable browser
/// autoplay, GPU-decoded. The poster paints instantly underneath; with OS
/// reduce-motion on only the poster is shown.
class WebVideo extends StatelessWidget {
  const WebVideo({
    super.key,
    required this.video,
    required this.poster,
    this.alignment = Alignment.center,
    this.playbackRate = 1,
  });

  /// Asset keys, e.g. 'assets/video/hero_journey.mp4'
  final String video, poster;
  final Alignment alignment;
  final double playbackRate;

  @override
  Widget build(BuildContext context) {
    final still = Image.asset(
      poster,
      fit: BoxFit.cover,
      alignment: alignment,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
    );
    if (context.reduceMotion) return still;

    return Stack(fit: StackFit.expand, children: [
      still,
      IgnorePointer(
        child: HtmlElementView.fromTagName(
          tagName: 'video',
          onElementCreated: (Object element) => configureVideo(
            element as web.HTMLVideoElement,
            src: ui_web.assetManager.getAssetUrl(video),
            poster: ui_web.assetManager.getAssetUrl(poster),
            alignment: alignment,
            playbackRate: playbackRate,
          ),
        ),
      ),
    ]);
  }
}

/// Shared setup for background videos (also used by the moments carousel).
void configureVideo(
  web.HTMLVideoElement v, {
  required String src,
  required String poster,
  Alignment alignment = Alignment.center,
  double playbackRate = 1,
}) {
  v
    ..muted = true
    ..defaultMuted = true
    ..autoplay = true
    ..loop = true
    ..playsInline = true
    ..preload = 'auto'
    ..poster = poster
    ..src = src;
  v.setAttribute('muted', '');
  v.setAttribute('playsinline', '');
  v.setAttribute('disablepictureinpicture', '');
  v.style
    ..width = '100%'
    ..height = '100%'
    ..objectFit = 'cover'
    ..objectPosition = '${(alignment.x + 1) * 50}% ${(alignment.y + 1) * 50}%'
    ..pointerEvents = 'none'
    ..display = 'block';
  v.defaultPlaybackRate = playbackRate;
  v.playbackRate = playbackRate;
  v.play();
}
