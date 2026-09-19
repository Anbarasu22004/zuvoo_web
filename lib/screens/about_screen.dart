import 'package:flutter/material.dart';

import '../constants/content.dart';
import '../constants/layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/brand_icons.dart';
import '../widgets/reveal.dart';
import '../widgets/section.dart';
import '../widgets/site_scaffold.dart';
import '../widgets/tilt.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteScaffold(
      title: Content.titles['/about']!,
      children: [
        const PageHeader(
          eyebrow: 'About Zuvoo',
          title: 'Building AI for the world beyond the screen.',
          intro: 'Life is already complicated. Technology shouldn\'t be. That belief shapes everything we build.',
        ),
        Section(
          top: context.responsive(mobile: 32.0, desktop: 56.0),
          child: ResponsiveRow(
            breakAt: Breakpoints.tablet,
            flex: const [5, 6],
            gap: context.responsive(mobile: 40.0, desktop: 88.0),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Reveal(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Stack(fit: StackFit.expand, children: [
                      Image.asset('assets/images/about_journey.jpg', fit: BoxFit.cover, alignment: const Alignment(0.3, 0)),
                    ]),
                  ),
                ),
              ),
              Reveal(
                delay: const Duration(milliseconds: 120),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('A note from the founder', style: AppText.heading(context.responsive(mobile: 26.0, desktop: 34.0), AppColors.text)),
                  const SizedBox(height: 24),
                  Text(Content.founderStatement,
                      style: AppText.body(context.responsive(mobile: 17.0, desktop: 19.0), AppColors.text, height: 1.75)),
                  const SizedBox(height: 32),
                  Text(Content.founderName, style: AppText.label(AppColors.text, size: 16)),
                  const SizedBox(height: 4),
                  Text('Founder of Zuvoo', style: AppText.body(15, AppColors.textMuted)),
                ]),
              ),
            ],
          ),
        ),
        Section(
          color: AppColors.bg2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeading(
              title: 'Why the name Zuvoo',
              subtitle: 'Fast and open, like the sky. Two ideas everyday software should never trade away.',
              light: true,
            ),
            const SizedBox(height: 48),
            Reveal(
              child: ResponsiveRow(gap: 40, children: [
                for (final item in Content.nameStory)
                  Container(
                    padding: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.accent.withValues(alpha: 0.7)))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.$1, style: AppText.heading(26, Colors.white)),
                      const SizedBox(height: 12),
                      Text(item.$2, style: AppText.body(17, Colors.white70)),
                    ]),
                  ),
              ]),
            ),
          ]),
        ),
        Section(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeading(title: 'What we hold to'),
            const SizedBox(height: 44),
            Reveal(
              child: ResponsiveRow(
                gap: 20,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < Content.values.length; i++)
                    Tilt(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          ValueIcon(kind: ValueKind.values[i]),
                          const SizedBox(height: 22),
                          Text(Content.values[i].$1, style: AppText.heading(22, AppColors.text)),
                          const SizedBox(height: 10),
                          Text(Content.values[i].$2, style: AppText.body(16, AppColors.textMuted)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
