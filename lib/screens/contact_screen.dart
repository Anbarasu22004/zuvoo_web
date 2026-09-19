import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/content.dart';
import '../constants/layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/buttons.dart';
import '../widgets/reveal.dart';
import '../widgets/section.dart';
import '../widgets/site_scaffold.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteScaffold(
      title: Content.titles['/contact']!,
      children: [
        const PageHeader(
          eyebrow: 'Contact',
          title: 'Get in touch',
          intro: 'Questions, ideas, or partnership enquiries. We read every message.',
        ),
        Section(
          top: context.responsive(mobile: 24.0, desktop: 40.0),
          child: ResponsiveRow(
            breakAt: Breakpoints.tablet,
            flex: const [7, 4],
            gap: context.responsive(mobile: 48.0, desktop: 96.0),
            children: [
              const Reveal(child: _ContactForm()),
              Reveal(
                delay: const Duration(milliseconds: 120),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Email us directly', style: AppText.label(AppColors.text)),
                    const SizedBox(height: 10),
                    TextLink(
                      label: Content.contactEmail,
                      color: AppColors.tealBright,
                      hoverColor: Colors.white,
                      size: 17,
                      onTap: () => launchUrl(Uri(scheme: 'mailto', path: Content.contactEmail)),
                    ),
                    if (Content.socials.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text('Elsewhere', style: AppText.label(AppColors.text)),
                      const SizedBox(height: 10),
                      for (final s in Content.socials.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextLink(label: s.key, onTap: () => launchUrl(Uri.parse(s.value))),
                        ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  bool _sent = false;
  String? _launchError;
  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  // No backend yet: hands the message to the visitor's email app.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final subject = Uri.encodeComponent('Message from ${_name.text.trim()}');
    final body = Uri.encodeComponent('${_message.text.trim()}\n\n${_name.text.trim()}\n${_email.text.trim()}');
    final ok = await launchUrl(Uri.parse('mailto:${Content.contactEmail}?subject=$subject&body=$body'));
    if (!mounted) return;
    setState(() {
      _sent = ok;
      _launchError = ok ? null : 'Your email app didn\'t open. Email us at ${Content.contactEmail} instead.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final rounded = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.line),
    );

    Widget field(String label, TextEditingController c,
            {String? Function(String?)? validator, int lines = 1, TextInputType? type}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppText.label(AppColors.text)),
            const SizedBox(height: 8),
            TextFormField(
              controller: c,
              minLines: lines,
              maxLines: lines == 1 ? 1 : 10,
              keyboardType: type,
              validator: validator,
              style: AppText.body(16, AppColors.text, height: 1.4),
              decoration: lines == 1
                  ? const InputDecoration()
                  : InputDecoration(
                      border: rounded,
                      enabledBorder: rounded,
                      focusedBorder: rounded.copyWith(borderSide: const BorderSide(color: AppColors.tealBright, width: 1.5)),
                      errorBorder: rounded.copyWith(borderSide: const BorderSide(color: Color(0xFFC94A3F))),
                      focusedErrorBorder: rounded.copyWith(borderSide: const BorderSide(color: Color(0xFFC94A3F), width: 1.5)),
                    ),
            ),
          ]),
        );

    if (_sent) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your message is ready to send', style: AppText.heading(22, AppColors.text)),
          const SizedBox(height: 10),
          Text('We opened it in your email app. Press send there and it will reach us.', style: AppText.body(16, AppColors.textMuted)),
          const SizedBox(height: 20),
          TextLink(label: 'Write another message', color: AppColors.tealBright, onTap: () => setState(() => _sent = false)),
        ]),
      );
    }

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        field('Name', _name, validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name.' : null),
        field('Email', _email,
            type: TextInputType.emailAddress,
            validator: (v) => (v == null || !_emailRe.hasMatch(v.trim())) ? 'Enter a valid email address, like name@example.com.' : null),
        field('Message', _message,
            lines: 6, validator: (v) => (v == null || v.trim().length < 10) ? 'Write at least 10 characters.' : null),
        if (_launchError != null) ...[
          Text(_launchError!, style: AppText.body(14, const Color(0xFFC94A3F))),
          const SizedBox(height: 16),
        ],
        AppButton(label: 'Send message', arrow: true, onPressed: _submit),
      ]),
    );
  }
}
