import 'package:flutter/material.dart';

import '../constants/layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'reveal.dart';

class Section extends StatelessWidget {
  const Section({super.key, required this.child, this.top, this.bottom, this.color, this.decoration, this.maxWidth = Breakpoints.maxContent});

  final Widget child;
  final double? top, bottom;
  final Color? color;
  final Decoration? decoration;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final v = context.responsive(mobile: 64.0, tablet: 96.0, desktop: 120.0);
    final g = context.gutter;
    return Container(
      color: decoration == null ? color : null,
      decoration: decoration,
      padding: EdgeInsets.fromLTRB(g, top ?? v, g, bottom ?? v),
      child: Center(
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, this.subtitle, this.center = false, this.light = false});
  final String title;
  final String? subtitle;
  final bool center, light;

  @override
  Widget build(BuildContext context) {
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final ta = center ? TextAlign.center : TextAlign.start;
    return Reveal(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(crossAxisAlignment: align, children: [
          Text(title,
              textAlign: ta,
              style: AppText.heading(context.responsive(mobile: 30.0, desktop: 44.0), light ? Colors.white : AppColors.text)),
          if (subtitle != null) ...[
            const SizedBox(height: 14),
            Text(subtitle!, textAlign: ta, style: AppText.body(17, light ? Colors.white70 : AppColors.textMuted)),
          ],
        ]),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.intro, this.eyebrow});
  final String title, intro;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Section(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.card, AppColors.bg],
        ),
      ),
      top: Breakpoints.navHeight + context.responsive(mobile: 48.0, desktop: 110.0),
      bottom: context.responsive(mobile: 32.0, desktop: 56.0),
      child: Reveal(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (eyebrow != null) ...[
            Text(eyebrow!, style: AppText.eyebrow(AppColors.accentDeep)),
            const SizedBox(height: 16),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Text(title, style: AppText.display(context.responsive(mobile: 38.0, tablet: 52.0, desktop: 64.0), AppColors.text)),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(intro, style: AppText.body(context.responsive(mobile: 17.0, desktop: 19.0), AppColors.textMuted)),
          ),
        ]),
      ),
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.flex,
    this.gap = 32,
    this.breakAt = Breakpoints.mobile,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.reverseWhenStacked = false,
  });

  final List<Widget> children;
  final List<int>? flex;
  final double gap, breakAt;
  final CrossAxisAlignment crossAxisAlignment;
  final bool reverseWhenStacked;

  @override
  Widget build(BuildContext context) {
    final stacked = context.vw < breakAt;
    final items = stacked && reverseWhenStacked ? children.reversed.toList() : children;
    final spaced = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) spaced.add(SizedBox(width: gap, height: gap));
      final fi = stacked && reverseWhenStacked ? items.length - 1 - i : i;
      spaced.add(stacked ? items[i] : Expanded(flex: flex?[fi] ?? 1, child: items[i]));
    }
    if (stacked) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: spaced);
    final row = Row(crossAxisAlignment: crossAxisAlignment, children: spaced);
    return crossAxisAlignment == CrossAxisAlignment.stretch ? IntrinsicHeight(child: row) : row;
  }
}

class ComingSoonBadge extends StatelessWidget {
  const ComingSoonBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.tealBright.withValues(alpha: 0.4)),
        ),
        child: Text('Coming soon', style: AppText.label(AppColors.tealBright, size: 13)),
      );
}
