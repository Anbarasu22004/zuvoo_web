import 'package:flutter/material.dart';

import '../constants/content.dart';
import '../widgets/scenes/building.dart';
import '../widgets/scenes/closing.dart';
import '../widgets/scenes/future.dart';
import '../widgets/scenes/hero.dart';
import '../widgets/scenes/mission.dart';
import '../widgets/scenes/products.dart';
import '../widgets/scenes/story.dart';
import '../widgets/site_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteScaffold(
      title: Content.titles['/']!,
      children: [
        Builder(
          builder: (context) => HeroScene(
            // Hero is exactly one section tall, so the next section starts at its bottom.
            onExplore: () {
              final pos = Scrollable.of(context).position;
              pos.animateTo(
                (context.size?.height ?? 900).clamp(0, pos.maxScrollExtent),
                duration: const Duration(milliseconds: 1200),
                curve: const Cubic(0.65, 0, 0.35, 1),
              );
            },
          ),
        ),
        const BuildingScene(),
        const ProductsScene(),
        const StoryScene(),
        const MissionScene(),
        const FutureScene(),
        const ClosingScene(),
      ],
    );
  }
}
