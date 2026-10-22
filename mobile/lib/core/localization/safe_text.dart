import 'package:flutter/material.dart';
import 'app_locale.dart';

/// Zero-Overflow, 100% Translated Safe Text Widget for Qareeb App.
/// 
/// Solves two critical bilingual challenges:
/// 1. Zero Untranslated Words: Automatically routes through [AppLocalizationsDomainExtension.auto]
///    so even dynamic backend strings or untranslated UI tokens are translated to the active language.
/// 2. Zero Overflow: Guarantees no RenderFlex overflow by supporting:
///    - [autoFit]: Uses FittedBox(fit: BoxFit.scaleDown) to scale text down gracefully in tight containers.
///    - [maxLines] + [overflow]: Automatically manages ellipsis and line breaks.
///    - Dynamic line-height tailored for Arabic Cairo ascenders/descenders vs English Inter.
class SafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? height;
  final double? letterSpacing;
  final TextDecoration? decoration;
  final int? maxLines;
  final bool autoFit;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final bool autoTranslate;
  final bool softWrap;

  const SafeText(
    this.text, {
    super.key,
    this.style,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.height,
    this.letterSpacing,
    this.decoration,
    this.maxLines,
    this.autoFit = false,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.autoTranslate = true,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final String displayText = autoTranslate ? tr.auto(text) : text;

    final TextStyle effectiveStyle = (style ??
            tr.font(
              fontSize: fontSize ?? 14.0,
              fontWeight: fontWeight ?? FontWeight.w400,
              color: color ?? const Color(0xFF1C2926),
              height: height ?? (tr.isArabic ? 1.18 : 1.15),
              letterSpacing: letterSpacing,
              decoration: decoration,
            ))
        .copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );

    final Widget textWidget = Text(
      displayText,
      textAlign: textAlign ?? (tr.isArabic ? TextAlign.right : TextAlign.left),
      maxLines: maxLines,
      overflow: maxLines != null ? overflow : null,
      softWrap: softWrap,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      style: effectiveStyle,
    );

    if (autoFit) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: tr.isArabic
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: textWidget,
      );
    }

    return textWidget;
  }
}

/// Handy extension on String for inline auto-translation
extension SafeStringExtension on String {
  String trAuto(BuildContext context) => context.tr.auto(this);
}