import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A text widget that automatically chooses LTR or RTL direction based on the
/// content. Helpful when the app shell is RTL (Hebrew device) but the string is
/// English, so punctuation stays in the correct order.
class AutoDirectionText extends StatelessWidget {
  const AutoDirectionText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final isRtl = _looksLikeRtl(data);
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Text(
        data,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign ?? (isRtl ? TextAlign.right : TextAlign.left),
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      ),
    );
  }
}

bool _looksLikeRtl(String value) {
  // Hebrew or Arabic ranges are enough for this use case.
  final rtlRegex = RegExp(r'[\u0590-\u05FF\u0600-\u06FF]');
  return rtlRegex.hasMatch(value);
}
