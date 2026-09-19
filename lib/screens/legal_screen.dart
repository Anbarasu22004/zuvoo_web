import 'package:flutter/material.dart';

import '../constants/content.dart';
import '../constants/layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/section.dart';
import '../widgets/site_scaffold.dart';

enum LegalKind { privacy, terms }

/// Placeholder legal outlines. Replace with final text before any app launch.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.kind});
  final LegalKind kind;

  static const _privacy = [
    ('Information we collect', 'Describe what personal information Zuvoo systems and this website collect, such as account details, usage context, contact messages, and device information.'),
    ('How we use it', 'Explain the purposes: providing the service, responding to messages, improving the apps, and meeting legal obligations.'),
    ('Sharing', 'List third parties that process data on Zuvoo\'s behalf, such as hosting, payments and analytics, and state that data is never sold.'),
    ('Storage and security', 'Describe where data is stored, how long it is kept, and how it is protected.'),
    ('Your choices', 'Explain how people can access, correct, export, or delete their data.'),
    ('Contact', 'Questions about this policy: ${Content.contactEmail}'),
  ];

  static const _terms = [
    ('Using our services', 'Set out who can use Zuvoo systems and the basic rules for acceptable use.'),
    ('Accounts', 'Explain account responsibilities, including keeping login details secure.'),
    ('Payments', 'Describe pricing, payments, cancellations, and refunds for any paid service.'),
    ('Your content', 'Clarify that people own the content they create, and what licence Zuvoo needs to run the service.'),
    ('Liability', 'State the limits of Zuvoo\'s liability as permitted by applicable law.'),
    ('Changes and contact', 'Explain how these terms may be updated. Questions: ${Content.contactEmail}'),
  ];

  @override
  Widget build(BuildContext context) {
    final privacy = kind == LegalKind.privacy;
    return SiteScaffold(
      title: Content.titles[privacy ? '/privacy' : '/terms']!,
      children: [
        PageHeader(
          eyebrow: 'Legal',
          title: privacy ? 'Privacy Policy' : 'Terms of Service',
          intro: 'Draft outline. Final text will be published before launch.',
        ),
        Section(
          top: context.responsive(mobile: 16.0, desktop: 32.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final s in privacy ? _privacy : _terms) ...[
                  Text(s.$1, style: AppText.heading(22, AppColors.text)),
                  const SizedBox(height: 10),
                  Text(s.$2, style: AppText.body(16, AppColors.textMuted, height: 1.7)),
                  const SizedBox(height: 36),
                ],
              ]),
            ),
          ),
        ),
      ],
    );
  }
}
