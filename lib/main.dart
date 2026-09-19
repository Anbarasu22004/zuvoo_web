import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  usePathUrlStrategy();
  runApp(const ZuvooApp());
}

class ZuvooApp extends StatelessWidget {
  const ZuvooApp({super.key});

  static final _theme = AppTheme.dark();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Zuvoo',
        debugShowCheckedModeBanner: false,
        theme: _theme,
        routerConfig: appRouter,
      );
}
