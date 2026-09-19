import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/content.dart';
import '../constants/layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/buttons.dart';
import '../widgets/future_paths.dart';
import '../widgets/reveal.dart';
import '../widgets/scenes/building.dart';
import '../widgets/scenes/products.dart';
import '../widgets/scenes/story.dart';
import '../widgets/section.dart';
import '../widgets/site_scaffold.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteScaffold(
      title: Content.titles['/products']!,
      children: [
        const PageHeader(
          eyebrow: 'What we build',
          title: 'AI systems for real-world experiences.',
          intro: Content.buildIntro,
        ),
        const ProductsScene(),
        const BuildingScene(),
        const StoryScene(),
        Container(
          height: context.responsive(mobile: 520.0, desktop: 640.0),
          color: AppColors.tealNight,
          child: Stack(fit: StackFit.expand, children: [
            const FuturePaths(progress: 1, labels: Content.futureLabels),
            Positioned(
              top: 64,
              left: context.gutter,
              right: context.gutter,
              child: Reveal(
                child: Column(children: [
                  Text(Content.futureTitle,
                      textAlign: TextAlign.center,
                      style: AppText.display(context.responsive(mobile: 30.0, desktop: 48.0), Colors.white)),
                  const SizedBox(height: 28),
                  AppButton(label: 'Build with us', caps: true, kind: ButtonStyleKind.white, onPressed: () => context.go('/contact')),
                ]),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
