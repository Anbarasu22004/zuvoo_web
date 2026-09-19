import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/buttons.dart';
import '../widgets/section.dart';
import '../widgets/site_scaffold.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => SiteScaffold(
        title: 'Page not found | Zuvoo',
        children: [
          const PageHeader(
            title: 'This page doesn\'t exist.',
            intro: 'The link may be old or mistyped. Head back to the home page to find your way.',
          ),
          Section(
            top: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppButton(label: 'Go to home page', arrow: true, onPressed: () => context.go('/')),
            ),
          ),
        ],
      );
}
