import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/content.dart';
import '../../constants/layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../reveal.dart';
import '../web_video.dart';

/// Product cards: film melting into a tinted card, details, store and web links.
class ProductsScene extends StatelessWidget {
  const ProductsScene({super.key, this.showIntro = true});
  final bool showIntro;

  @override
  Widget build(BuildContext context) {
    final g = context.gutter;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF07090C), AppColors.bg],
        ),
      ),
      padding: EdgeInsets.fromLTRB(g, context.responsive(mobile: 72.0, desktop: 130.0), g, context.responsive(mobile: 80.0, desktop: 140.0)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(children: [
            if (showIntro) ...[
              Reveal(child: Text(Content.productsEyebrow.toUpperCase(), style: AppText.eyebrow(AppColors.textMuted))),
              const SizedBox(height: 18),
              Reveal(
                delay: const Duration(milliseconds: 100),
                child: Text(Content.productsTitle,
                    textAlign: TextAlign.center,
                    style: AppText.display(context.responsive(mobile: 38.0, tablet: 54.0, desktop: 68.0), AppColors.text)),
              ),
              const SizedBox(height: 16),
              Reveal(
                delay: const Duration(milliseconds: 180),
                child: Text(Content.productsIntro,
                    textAlign: TextAlign.center, style: AppText.body(context.responsive(mobile: 16.0, desktop: 19.0), AppColors.textMuted)),
              ),
              SizedBox(height: context.responsive(mobile: 44.0, desktop: 72.0)),
            ],
            LayoutBuilder(builder: (context, box) {
              final cols = box.maxWidth >= 1000 ? 3 : (box.maxWidth >= 640 ? 2 : 1);
              const gap = 24.0;
              final w = (box.maxWidth - gap * (cols - 1)) / cols;
              final projects = Content.projects;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < projects.length; i++)
                    SizedBox(
                      width: w,
                      child: Reveal(delay: Duration(milliseconds: 110 * (i % cols)), child: _ProductCard(project: projects[i], width: w)),
                    ),
                ],
              );
            }),
          ]),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.project, required this.width});
  final Project project;
  final double width;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hover = false;

  Future<void> _open(String url) => launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final tint = Color(p.tint);
    final mediaH = widget.width * 0.92;
    const radius = 28.0;
    final pad = widget.width < 360 ? 20.0 : 26.0;

    final media = SizedBox(
      height: mediaH,
      child: Stack(fit: StackFit.expand, children: [
        WebVideo(video: p.video, poster: p.poster),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [tint.withValues(alpha: 0), tint.withValues(alpha: 0), tint.withValues(alpha: 0.85), tint],
              stops: const [0, 0.45, 0.8, 1],
            ),
          ),
        ),
        Positioned(
          top: 18,
          left: 18,
          right: 18,
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(p.icon, width: 46, height: 46, filterQuality: FilterQuality.medium),
            ),
            const Spacer(),
            _Glass(child: Text(p.appStore.isEmpty && p.playStore.isEmpty ? 'Coming soon' : 'Available now',
                style: AppText.body(12.5, Colors.white, weight: FontWeight.w500, height: 1))),
          ]),
        ),
      ]),
    );

    final details = Padding(
      padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.category.toUpperCase(), style: AppText.eyebrow(Colors.white.withValues(alpha: 0.6)).copyWith(fontSize: 11.5)),
        const SizedBox(height: 10),
        Text(p.name, style: AppText.heading(context.responsive(mobile: 28.0, desktop: 30.0), Colors.white)),
        const SizedBox(height: 10),
        SizedBox(
          height: 15 * 1.5 * 3,
          child: Text(p.description,
              maxLines: 3, overflow: TextOverflow.ellipsis, style: AppText.body(15, Colors.white.withValues(alpha: 0.72), height: 1.5)),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final c in p.chips) _Glass(child: Text(c, style: AppText.body(12.5, Colors.white, height: 1)))]),
        const SizedBox(height: 22),
        _PillButton(
          label: p.website.isEmpty ? 'Join the waitlist' : 'Visit website',
          icon: p.website.isEmpty ? Icons.arrow_forward_rounded : Icons.north_east_rounded,
          onTap: () {
            if (p.website.isEmpty) {
              context.go('/contact');
            } else {
              _open(p.website);
            }
          },
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _StoreButton(
              store: 'App Store',
              glyph: const Icon(Icons.apple, color: Colors.white, size: 20),
              onTap: p.appStore.isEmpty ? null : () => _open(p.appStore),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StoreButton(
              store: 'Google Play',
              glyph: const SizedBox(width: 17, height: 18, child: CustomPaint(painter: _PlayGlyph())),
              onTap: p.playStore.isEmpty ? null : () => _open(p.playStore),
            ),
          ),
        ]),
      ]),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hover ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withValues(alpha: _hover ? 0.16 : 0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? 0.7 : 0.45),
              blurRadius: 60,
              offset: const Offset(0, 30),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned(top: 0, left: 0, right: 0, child: media),
          Padding(padding: EdgeInsets.only(top: mediaH * 0.74), child: details),
        ]),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: child,
      );
}

class _PillButton extends StatefulWidget {
  const _PillButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: 50,
              decoration: BoxDecoration(
                color: _hover ? const Color(0xFFE8EEEC) : Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(widget.label, style: AppText.label(Colors.black, size: 15)),
                const SizedBox(width: 8),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  offset: Offset(_hover ? 0.2 : 0, 0),
                  child: Icon(widget.icon, size: 17, color: Colors.black),
                ),
              ]),
            ),
          ),
        ),
      );
}

class _StoreButton extends StatefulWidget {
  const _StoreButton({required this.store, required this.glyph, required this.onTap});
  final String store;
  final Widget glyph;
  final VoidCallback? onTap;

  @override
  State<_StoreButton> createState() => _StoreButtonState();
}

class _StoreButtonState extends State<_StoreButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final live = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: live,
      label: live ? 'Get it on ${widget.store}' : '${widget.store}, coming soon',
      child: MouseRegion(
        cursor: live ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: live && _hover ? 0.55 : 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: live && _hover ? 0.4 : 0.16)),
            ),
            child: Opacity(
              opacity: live ? 1 : 0.62,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                widget.glyph,
                const SizedBox(width: 8),
                Flexible(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(live ? 'Get it on' : 'Coming soon', maxLines: 1, style: AppText.body(9.5, Colors.white70, height: 1.1)),
                    Text(widget.store, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.label(Colors.white, size: 13.5)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simplified four-colour Google Play triangle.
class _PlayGlyph extends CustomPainter {
  const _PlayGlyph();

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final mid = Offset(w * 0.62, h / 2);
    void tri(List<Offset> pts, Color c) => canvas.drawPath(Path()..addPolygon(pts, true), Paint()..color = c);
    tri([Offset.zero, mid, Offset(0, h / 2)], const Color(0xFF00D7FE));
    tri([Offset(0, h / 2), mid, Offset(0, h)], const Color(0xFFFF3A44));
    tri([Offset.zero, Offset(w, h / 2), mid], const Color(0xFF32BBFF));
    tri([Offset(0, h), mid, Offset(w, h / 2)], const Color(0xFFFFD500));
    tri([Offset(w * 0.62, h * 0.3), Offset(w, h / 2), Offset(w * 0.62, h * 0.7)], const Color(0xFF00F076));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
