import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/content.dart';
import '../../constants/layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../brand_icons.dart';
import '../buttons.dart';
import '../reveal.dart';
import '../section.dart';

class ClosingScene extends StatelessWidget {
  const ClosingScene({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return Section(
      top: context.responsive(mobile: 56.0, desktop: 96.0),
      child: Reveal(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(children: [
            Positioned.fill(child: Image.asset('assets/images/closing_sunset.jpg', fit: BoxFit.cover, alignment: Alignment.centerRight)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: mobile ? Alignment.topCenter : Alignment.centerLeft,
                    end: mobile ? Alignment.bottomCenter : Alignment.centerRight,
                    colors: const [Color(0xF2050708), Color(0xB3050708), Color(0x33050708)],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.responsive(mobile: 26.0, desktop: 64.0)),
              child: ResponsiveRow(
                breakAt: Breakpoints.tablet,
                crossAxisAlignment: CrossAxisAlignment.center,
                flex: const [6, 5],
                gap: 40,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(Content.closingEyebrow.toUpperCase(), style: AppText.eyebrow(AppColors.accent)),
                    const SizedBox(height: 14),
                    Text(Content.closingTitle, style: AppText.display(context.responsive(mobile: 36.0, desktop: 60.0), Colors.white)),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Text(Content.closingBody, style: AppText.body(17, AppColors.text)),
                    ),
                    const SizedBox(height: 28),
                    const Wordmark(size: 20, linked: false),
                    const SizedBox(height: 6),
                    Text(Content.tagline, style: AppText.body(15, AppColors.textMuted)),
                  ]),
                  const _JoinForm(),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _JoinForm extends StatefulWidget {
  const _JoinForm();

  @override
  State<_JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<_JoinForm> {
  final _email = TextEditingController();
  String? _error;
  bool _done = false;
  static final _re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  // No backend yet: opens the visitor's email app. Swap for an API call later.
  Future<void> _join() async {
    final email = _email.text.trim();
    if (!_re.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address, like name@example.com.');
      return;
    }
    final uri = Uri.parse(
        'mailto:${Content.contactEmail}?subject=${Uri.encodeComponent('Join the Zuvoo journey')}&body=${Uri.encodeComponent('Please keep me updated at $email')}');
    final ok = await launchUrl(uri);
    if (!mounted) return;
    setState(() {
      _done = ok;
      _error = ok ? null : 'Your email app didn\'t open. Email us at ${Content.contactEmail} instead.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Text('Almost there. Press send in your email app and you\'re on the list.',
          style: AppText.body(17, AppColors.tealBright, weight: FontWeight.w600));
    }
    final mobile = context.isMobile;
    final field = TextField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      onSubmitted: (_) => _join(),
      style: AppText.body(15, AppColors.text),
      decoration: const InputDecoration(
        hintText: 'Enter your email address',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
    final button = AppButton(label: 'Join our journey', kind: ButtonStyleKind.teal, arrow: true, compact: true, onPressed: _join);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(mobile ? 20 : 999),
          border: Border.all(color: _error != null ? const Color(0xFFC94A3F) : AppColors.line),
          boxShadow: [BoxShadow(color: AppColors.tealBright.withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 12))],
        ),
        child: mobile
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [field, button])
            : Row(children: [Expanded(child: field), button]),
      ),
      if (_error != null) ...[
        const SizedBox(height: 10),
        Text(_error!, style: AppText.body(14, const Color(0xFFC94A3F))),
      ],
    ]);
  }
}
