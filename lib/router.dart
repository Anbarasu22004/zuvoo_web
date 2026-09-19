import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/about_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/home_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/products_screen.dart';

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 380),
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut), child: child),
    );

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', pageBuilder: (c, s) => _fade(s, const HomeScreen())),
    GoRoute(path: '/about', pageBuilder: (c, s) => _fade(s, const AboutScreen())),
    GoRoute(path: '/products', pageBuilder: (c, s) => _fade(s, const ProductsScreen())),
    GoRoute(path: '/contact', pageBuilder: (c, s) => _fade(s, const ContactScreen())),
    GoRoute(path: '/privacy', pageBuilder: (c, s) => _fade(s, const LegalScreen(kind: LegalKind.privacy))),
    GoRoute(path: '/terms', pageBuilder: (c, s) => _fade(s, const LegalScreen(kind: LegalKind.terms))),
  ],
  errorPageBuilder: (c, s) => _fade(s, const NotFoundScreen()),
);
