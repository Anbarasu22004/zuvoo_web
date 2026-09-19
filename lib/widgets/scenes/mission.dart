import 'package:flutter/material.dart';

import '../../constants/content.dart';
import '../../constants/layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../reveal.dart';
import '../section.dart';

class MissionScene extends StatelessWidget {
  const MissionScene({super.key});

  @override
  Widget build(BuildContext context) => Section(
        color: AppColors.bg,
        child: Column(children: [
          Reveal(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Text(Content.missionTitle,
                  textAlign: TextAlign.center,
                  style: AppText.display(context.responsive(mobile: 34.0, tablet: 50.0, desktop: 66.0), AppColors.text)),
            ),
          ),
          const SizedBox(height: 28),
          Reveal(
            delay: const Duration(milliseconds: 120),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(Content.mission, textAlign: TextAlign.center, style: AppText.body(18, AppColors.textMuted, height: 1.7)),
            ),
          ),
        ]),
      );
}
