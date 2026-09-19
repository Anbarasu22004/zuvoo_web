import 'package:flutter/material.dart';

import '../../constants/content.dart';
import '../../constants/layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../reveal.dart';
import '../web_video.dart';

/// "What we're building": three capabilities, each with its own film.
class BuildingScene extends StatelessWidget {
  const BuildingScene({super.key, this.showIntro = true});
  final bool showIntro;

  @override
  Widget build(BuildContext context) {
    final g = context.gutter;
    final columns = context.responsive(mobile: 1, tablet: 1, desktop: 3);
    final items = Content.building;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bg, Color(0xFF0A1315), Colors.black],
        ),
      ),
      padding: EdgeInsets.fromLTRB(g, context.responsive(mobile: 80.0, desktop: 140.0), g, context.responsive(mobile: 80.0, desktop: 140.0)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Column(children: [
            if (showIntro) ...[
              Reveal(child: Text(Content.buildTitle.toUpperCase(), style: AppText.eyebrow(AppColors.textMuted))),
              const SizedBox(height: 20),
              Reveal(
                delay: const Duration(milliseconds: 100),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Text(Content.buildIntro,
                      textAlign: TextAlign.center,
                      style: AppText.display(context.responsive(mobile: 34.0, tablet: 50.0, desktop: 62.0), AppColors.text)),
                ),
              ),
              SizedBox(height: context.responsive(mobile: 48.0, desktop: 88.0)),
            ],
            if (columns == 1)
              Column(children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 24),
                  Reveal(child: _BuildCard(item: items[i])),
                ],
              ])
            else
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 24),
                  Expanded(child: Reveal(delay: Duration(milliseconds: 120 * i), child: _BuildCard(item: items[i]))),
                ],
              ]),
          ]),
        ),
      ),
    );
  }
}

class _BuildCard extends StatefulWidget {
  const _BuildCard({required this.item});
  final BuildItem item;

  @override
  State<_BuildCard> createState() => _BuildCardState();
}

class _BuildCardState extends State<_BuildCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final media = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: WebVideo(video: item.video, poster: item.poster),
    );
    final text = Padding(
      padding: EdgeInsets.all(context.responsive(mobile: 24.0, desktop: 32.0)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.label.toUpperCase(), style: AppText.eyebrow(AppColors.accent)),
        const SizedBox(height: 16),
        Text(item.title, style: AppText.heading(context.responsive(mobile: 26.0, desktop: 30.0), AppColors.text)),
        const SizedBox(height: 12),
        Text(item.body, style: AppText.body(context.responsive(mobile: 15.0, desktop: 16.5), AppColors.textMuted, height: 1.6)),
      ]),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: _hover ? 0.2 : 0.07)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AspectRatio(aspectRatio: 16 / 11, child: media),
          text,
        ]),
      ),
    );
  }
}
