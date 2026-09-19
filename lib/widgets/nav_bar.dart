import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'brand_icons.dart';
import 'buttons.dart';

const navItems = [('Home', '/'), ('About', '/about'), ('What we build', '/products'), ('Contact', '/contact')];

/// Cinematic header: transparent over video, solid black once scrolled.
class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.solid});
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final mobile = context.isMobile;
    return RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          height: Breakpoints.navHeight,
          padding: EdgeInsets.symmetric(horizontal: context.responsive(mobile: 20.0, desktop: 40.0)),
          decoration: BoxDecoration(
            color: solid ? Colors.black.withValues(alpha: 0.92) : null,
            gradient: solid
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.35), Colors.black.withValues(alpha: 0)],
                  ),
          ),
          child: Row(children: [
            const Wordmark(),
            Expanded(
              child: mobile
                  ? const SizedBox.shrink()
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (final item in navItems)
                        _NavLink(label: item.$1, path: item.$2, active: path == item.$2),
                    ]),
            ),
            if (mobile)
              IconButton(
                tooltip: 'Open menu',
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
              )
            else ...[
              AppButton(
                label: 'Get in touch',
                caps: true,
                compact: true,
                kind: ButtonStyleKind.white,
                onPressed: () => context.go('/contact'),
              ),
            ],
          ]),
        ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.path, required this.active});
  final String label, path;
  final bool active;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final on = _hover || widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: Semantics(
          link: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(widget.label.toUpperCase(), style: AppText.caps(Colors.white.withValues(alpha: on ? 1 : 0.86), size: 14.5)),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: on ? 22 : 0,
                height: 1.5,
                color: widget.active ? AppColors.accent : Colors.white,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return Drawer(
      backgroundColor: Colors.black,
      width: MediaQuery.sizeOf(context).width,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 12, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Wordmark(),
              const Spacer(),
              IconButton(
                tooltip: 'Close menu',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
              ),
            ]),
            const SizedBox(height: 48),
            for (final item in navItems)
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(item.$2);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(item.$1,
                      style: AppText.display(44, path == item.$2 ? Colors.white : Colors.white.withValues(alpha: 0.5))),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Get in touch',
                caps: true,
                kind: ButtonStyleKind.white,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/contact');
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
