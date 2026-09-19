import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

enum ButtonStyleKind { accent, teal, outline, ghostLight, white, whiteOutline }

/// Pill button with a magnetic pull toward the cursor, lift and shadow on hover.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = ButtonStyleKind.accent,
    this.arrow = false,
    this.compact = false,
    this.caps = false,
  });

  final bool caps;
  final String label;
  final VoidCallback? onPressed;
  final ButtonStyleKind kind;
  final bool arrow, compact;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  Offset _pull = Offset.zero;
  bool _hover = false, _focus = false;

  void _onHover(PointerHoverEvent e) {
    final size = context.size;
    if (size == null) return;
    final d = e.localPosition - size.center(Offset.zero);
    setState(() => _pull = Offset(d.dx / size.width * 10, d.dy / size.height * 6));
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (widget.kind) {
      ButtonStyleKind.accent => (AppColors.accent, AppColors.onAccent, Colors.transparent),
      ButtonStyleKind.teal => (AppColors.teal, Colors.white, Colors.transparent),
      ButtonStyleKind.outline => (Colors.transparent, AppColors.tealBright, AppColors.tealBright.withValues(alpha: 0.45)),
      ButtonStyleKind.ghostLight => (Colors.white.withValues(alpha: 0.08), Colors.white, Colors.white.withValues(alpha: 0.35)),
      ButtonStyleKind.white => (Colors.white, Colors.black, Colors.transparent),
      ButtonStyleKind.whiteOutline => (Colors.transparent, Colors.white, Colors.white.withValues(alpha: 0.6)),
    };
    final hoverBg = switch (widget.kind) {
      ButtonStyleKind.accent => const Color(0xFFF5B271),
      ButtonStyleKind.teal => AppColors.tealLight,
      ButtonStyleKind.outline => AppColors.tealBright.withValues(alpha: 0.08),
      ButtonStyleKind.ghostLight => Colors.white.withValues(alpha: 0.16),
      ButtonStyleKind.white => const Color(0xFFE9EEEE),
      ButtonStyleKind.whiteOutline => Colors.white.withValues(alpha: 0.1),
    };
    final shadow = switch (widget.kind) {
      ButtonStyleKind.accent => AppColors.accent.withValues(alpha: 0.45),
      ButtonStyleKind.white => Colors.white.withValues(alpha: 0.18),
      _ => AppColors.tealBright.withValues(alpha: 0.18),
    };
    final square = widget.kind == ButtonStyleKind.white || widget.kind == ButtonStyleKind.whiteOutline;
    final enabled = widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onHover: _onHover,
        onExit: (_) => setState(() {
          _hover = false;
          _pull = Offset.zero;
        }),
        child: FocusableActionDetector(
          enabled: enabled,
          onShowFocusHighlight: (v) => setState(() => _focus = v),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            }),
          },
          child: GestureDetector(
            onTap: widget.onPressed,
            // Spring pull on position only; colours and shadow ease without
            // overshoot (an overshooting curve made the shadow blur negative).
            child: TweenAnimationBuilder<Offset>(
              tween: Tween(end: Offset(_pull.dx, _pull.dy - (_hover ? 2 : 0))),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (context, o, child) => Transform.translate(offset: o, child: child),
              child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: widget.compact ? 20 : (square ? 44 : 26), vertical: widget.compact ? 12 : (square ? 22 : 15)),
              decoration: BoxDecoration(
                color: _hover ? hoverBg : bg,
                borderRadius: BorderRadius.circular(square ? 2 : 999),
                border: Border.all(color: _focus ? AppColors.tealBright : border, width: _focus ? 2 : 1),
                boxShadow: [
                  BoxShadow(
                    color: _hover && widget.kind != ButtonStyleKind.ghostLight && widget.kind != ButtonStyleKind.whiteOutline
                        ? shadow
                        : shadow.withValues(alpha: 0),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(widget.caps ? widget.label.toUpperCase() : widget.label,
                    style: widget.caps ? AppText.caps(fg, size: widget.compact ? 14 : 17) : AppText.label(fg, size: widget.compact ? 13.5 : 15)),
                if (widget.arrow) ...[
                  const SizedBox(width: 8),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 240),
                    offset: Offset(_hover ? 0.25 : 0, 0),
                    child: Icon(Icons.arrow_forward_rounded, size: 17, color: fg),
                  ),
                ],
              ]),
            ),
            ),
          ),
        ),
      ),
    );
  }
}

class TextLink extends StatefulWidget {
  const TextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.textMuted,
    this.hoverColor = AppColors.text,
    this.size = 15,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final Color color, hoverColor;
  final double size;
  final bool active;

  @override
  State<TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<TextLink> {
  bool _hover = false, _focus = false;

  @override
  Widget build(BuildContext context) {
    final c = (_hover || widget.active) ? widget.hoverColor : widget.color;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: FocusableActionDetector(
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onTap();
            return null;
          }),
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Semantics(
            link: true,
            child: Text(
              widget.label,
              style: AppText.body(widget.size, c, weight: widget.active ? FontWeight.w600 : FontWeight.w500, height: 1.4)
                  .copyWith(decoration: _focus ? TextDecoration.underline : TextDecoration.none, decorationColor: c),
            ),
          ),
        ),
      ),
    );
  }
}
