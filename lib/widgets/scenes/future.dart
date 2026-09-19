import 'package:flutter/material.dart';

import '../../constants/content.dart';
import '../../constants/layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../effects.dart';
import '../future_paths.dart';
import '../scroll_progress.dart';

/// Pinned camera move through branching paths.
class FutureScene extends StatelessWidget {
  const FutureScene({super.key});

  @override
  Widget build(BuildContext context) {
    final titleSize = context.responsive(mobile: 30.0, tablet: 44.0, desktop: 58.0);
    return PinnedScene(
      screens: context.isMobile ? 2.2 : 2.6,
      builder: (context, info) => ColoredBox(
        color: AppColors.tealNight,
        child: Stack(fit: StackFit.expand, children: [
          ValueListenableBuilder<ScrollInfo>(
            valueListenable: info,
            builder: (context, i, _) => FuturePaths(
              progress: context.reduceMotion ? 1 : (i.top > 99999 ? 0 : i.pinned),
              labels: Content.futureLabels,
            ),
          ),
          const Dust(count: 30, opacity: 0.5),
          Positioned(
            top: Breakpoints.navHeight + context.responsive(mobile: 32.0, desktop: 56.0),
            left: context.gutter,
            right: context.gutter,
            child: Column(children: [
              Text(Content.futureTitle, textAlign: TextAlign.center, style: AppText.display(titleSize, Colors.white)),
              const SizedBox(height: 24),
              ValueListenableBuilder<ScrollInfo>(
                valueListenable: info,
                builder: (context, i, _) {
                  final p = i.top > 99999 ? 0.0 : i.pinned;
                  return Wrap(alignment: WrapAlignment.center, spacing: 20, runSpacing: 6, children: [
                    for (var k = 0; k < Content.futureLines.length; k++)
                      Opacity(
                        opacity: smoothstep(0.45 + k * 0.1, 0.58 + k * 0.1, p),
                        child: Text(
                          Content.futureLines[k],
                          style: AppText.heading(context.responsive(mobile: 17.0, desktop: 22.0),
                              k == 2 ? AppColors.accent : AppColors.mint, weight: FontWeight.w500),
                        ),
                      ),
                  ]);
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
