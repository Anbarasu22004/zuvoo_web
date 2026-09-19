import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/content.dart';
import '../constants/layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'brand_icons.dart';
import 'buttons.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final g = context.gutter;

    Widget col(String title, List<(String, VoidCallback)> links) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.label(Colors.white)),
            const SizedBox(height: 16),
            for (final l in links)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextLink(label: l.$1, size: 14, color: Colors.white70, hoverColor: Colors.white, onTap: l.$2),
              ),
          ],
        );

    return Container(
      color: Colors.black,
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _WavePainter())),
        Padding(
          padding: EdgeInsets.fromLTRB(g, 64, g, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContent),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 96, runSpacing: 40, children: [
                  SizedBox(
                    width: 320,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Wordmark(),
                      const SizedBox(height: 14),
                      Text(Content.tagline, style: AppText.body(14, Colors.white70)),
                      if (Content.socials.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Wrap(spacing: 18, children: [
                          for (final s in Content.socials.entries)
                            TextLink(
                              label: s.key,
                              size: 14,
                              color: Colors.white70,
                              hoverColor: Colors.white,
                              onTap: () => launchUrl(Uri.parse(s.value)),
                            ),
                        ]),
                      ],
                    ]),
                  ),
                  col('Quick links', [
                    ('Home', () => context.go('/')),
                    ('About', () => context.go('/about')),
                    ('Products', () => context.go('/products')),
                    ('Contact', () => context.go('/contact')),
                  ]),
                  col('Legal', [
                    ('Privacy Policy', () => context.go('/privacy')),
                    ('Terms of Service', () => context.go('/terms')),
                  ]),
                ]),
                const SizedBox(height: 48),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 8,
                  spacing: 24,
                  children: [
                    Text('© ${DateTime.now().year} Zuvoo. All rights reserved.', style: AppText.body(13, Colors.white60)),
                    Text('Beyond the screen.', style: AppText.body(13, Colors.white60)),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    for (var i = 0; i < 3; i++) {
      final y = s.height * (0.55 + i * 0.12);
      final p = Path()
        ..moveTo(s.width * 0.4, s.height)
        ..cubicTo(s.width * 0.6, y, s.width * 0.8, y + 60, s.width, y - 20)
        ..lineTo(s.width, s.height)
        ..close();
      canvas.drawPath(p, Paint()..color = Colors.white.withValues(alpha: 0.025));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
