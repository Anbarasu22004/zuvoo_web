import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/content.dart';
import '../../constants/layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../buttons.dart';
import '../moments_carousel.dart';
import '../reveal.dart';
import '../web_video.dart';

/// Full-bleed film, the Zuvoo statement, and a carousel of real-life moments.
class HeroScene extends StatelessWidget {
  const HeroScene({super.key, required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final carouselH = context.responsive(mobile: 300.0, tablet: 320.0, desktop: (context.vh * 0.34).clamp(280.0, 380.0));
    final headline = context.responsive(mobile: 34.0, tablet: 52.0, desktop: 68.0);
    // Enough room for copy + carousel at any window height.
    final natural = context.responsive(mobile: 720.0, tablet: 720.0, desktop: 720.0) + carouselH;
    final height = math.max(context.vh, natural);

    return SizedBox(
      height: height,
      child: Stack(children: [
        const Positioned.fill(
          child: WebVideo(video: 'assets/video/hero_journey.mp4', poster: 'assets/images/hero_journey.jpg'),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Color(0x4D000000), Color(0x80000000), AppColors.bg],
                stops: [0.0, 0.35, 0.72, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(children: [
            SizedBox(height: Breakpoints.navHeight + context.responsive(mobile: 48.0, desktop: 96.0)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.gutter),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(children: [
                  Reveal(child: Text(Content.heroEyebrow.toUpperCase(), style: AppText.eyebrow(Colors.white.withValues(alpha: 0.8)))),
                  const SizedBox(height: 22),
                  Reveal(
                    delay: const Duration(milliseconds: 120),
                    offsetY: 36,
                    child: Text(Content.heroHeadline, textAlign: TextAlign.center, style: AppText.display(headline, Colors.white).copyWith(height: 1.05)),
                  ),
                  const SizedBox(height: 24),
                  Reveal(
                    delay: const Duration(milliseconds: 260),
                    child: Text(Content.heroSupport,
                        textAlign: TextAlign.center,
                        style: AppText.body(context.responsive(mobile: 15.0, desktop: 19.0), Colors.white.withValues(alpha: 0.86))),
                  ),
                  SizedBox(height: context.responsive(mobile: 28.0, desktop: 36.0)),
                  Reveal(
                    delay: const Duration(milliseconds: 380),
                    child: AppButton(label: Content.heroCta, caps: true, kind: ButtonStyleKind.white, compact: mobile, onPressed: onExplore),
                  ),
                ]),
              ),
            ),
            const Spacer(),
            Reveal(delay: const Duration(milliseconds: 500), offsetY: 60, child: MomentsCarousel(height: carouselH)),
            SizedBox(height: context.responsive(mobile: 28.0, desktop: 44.0)),
          ]),
        ),
      ]),
    );
  }
}
