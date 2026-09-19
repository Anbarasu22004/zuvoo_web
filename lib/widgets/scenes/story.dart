import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../constants/content.dart';
import '../../constants/layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../beyond_screen.dart';
import '../effects.dart';
import '../scroll_progress.dart';

/// Pinned story: the 3D scene moves from screen → beyond → real world while
/// the copy explains each step.
class StoryScene extends StatelessWidget {
  const StoryScene({super.key});

  static double lineAlpha(int i, double p) {
    final local = (p - i / 3) * 3;
    final fadeIn = i == 0 ? 1.0 : smoothstep(0.0, 0.2, local);
    final fadeOut = i == 2 ? 1.0 : 1 - smoothstep(0.8, 1.0, local);
    return clamp01(fadeIn * fadeOut);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return PinnedScene(
      screens: mobile ? 3.0 : 3.4,
      builder: (context, info) {
        final size = context.responsive(mobile: 32.0, tablet: 48.0, desktop: 64.0);
        final copy = _StoryCopy(info: info, size: size, center: mobile);
        final visual = Stack(fit: StackFit.expand, children: [
          _WarmGlow(info: info),
          BeyondScreen(info: info, dense: !mobile),
          Align(alignment: Alignment.bottomCenter, child: _Stages(info: info)),
        ]);

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(center: Alignment(0.35, 0), radius: 1.1, colors: [Color(0xFF0B1B1F), AppColors.bg]),
          ),
          child: Stack(fit: StackFit.expand, children: [
            const Dust(count: 36, opacity: 0.5),
            Padding(
              padding: EdgeInsets.fromLTRB(context.gutter, Breakpoints.navHeight + 16, context.gutter, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: mobile
                      ? Column(children: [
                          Expanded(flex: 6, child: visual),
                          Expanded(flex: 4, child: Center(child: copy)),
                        ])
                      : Row(children: [
                          Expanded(flex: 5, child: copy),
                          Expanded(flex: 6, child: visual),
                        ]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _StoryCopy extends StatelessWidget {
  const _StoryCopy({required this.info, required this.size, required this.center});
  final ValueListenable<ScrollInfo> info;
  final double size;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final lines = [
      for (var i = 0; i < Content.story.length; i++)
        Text(
          Content.story[i],
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: AppText.display(size, Colors.white).copyWith(height: 1.05),
        ),
    ];
    return SizedBox(
      height: size * 3.6,
      child: ValueListenableBuilder<ScrollInfo>(
        valueListenable: info,
        builder: (context, i, _) {
          final p = i.top > 99999 ? 0.0 : i.pinned;
          return Stack(alignment: center ? Alignment.center : Alignment.centerLeft, children: [
            for (var k = 0; k < lines.length; k++)
              Opacity(
                opacity: StoryScene.lineAlpha(k, p),
                child: Transform.translate(offset: Offset(0, (0.5 - clamp01((p - k / 3) * 3)) * 28), child: lines[k]),
              ),
          ]);
        },
      ),
    );
  }
}

class _Stages extends StatelessWidget {
  const _Stages({required this.info});
  final ValueListenable<ScrollInfo> info;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ScrollInfo>(
        valueListenable: info,
        builder: (context, i, _) {
          final p = i.top > 99999 ? 0.0 : i.pinned;
          final active = p < 0.33 ? 0 : (p < 0.66 ? 1 : 2);
          return Wrap(spacing: 28, alignment: WrapAlignment.center, children: [
            for (var k = 0; k < Content.storyStages.length; k++)
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('0${k + 1}  ${Content.storyStages[k].toUpperCase()}',
                    style: AppText.eyebrow(k == active ? Colors.white : Colors.white.withValues(alpha: 0.35))),
                const SizedBox(height: 8),
                Container(width: 64, height: 1.5, color: k == active ? AppColors.accent : Colors.white.withValues(alpha: 0.12)),
              ]),
          ]);
        },
      );
}

class _WarmGlow extends StatelessWidget {
  const _WarmGlow({required this.info});
  final ValueListenable<ScrollInfo> info;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ScrollInfo>(
        valueListenable: info,
        child: const Glow(color: AppColors.accent, opacity: 0.22),
        builder: (context, i, child) =>
            Opacity(opacity: smoothstep(0.55, 0.9, i.top > 99999 ? 0 : i.pinned), child: child),
      );
}
