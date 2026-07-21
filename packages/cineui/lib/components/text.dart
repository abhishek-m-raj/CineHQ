import 'package:flutter/material.dart';
import 'package:cineui/constants/scale.dart';
import 'package:cineui/constants/theme/color_scheme.dart';
import 'package:cineui/typography/textstyles.dart';
import 'package:readmore/readmore.dart';

class CineText extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color? color;
  final int? maxLines;
  final bool readMore;

  const CineText(this.text, {super.key, this.style, this.textAlign, this.color, this.maxLines, this.readMore = false});

  @override
  Widget build(BuildContext context) {
    if (text == null) return SizedBox.shrink();
    if (readMore) {
      return ReadMoreText(
        text ?? "",
        trimMode: TrimMode.Line,
        trimLines: maxLines ?? 3,
        preDataTextStyle: style,
        postDataTextStyle: style,
        textAlign: textAlign,
        colorClickableText: CineColorScheme.surfaceTint,
        trimCollapsedText: ' read more',
        trimExpandedText: ' read less',
      );
    }
    return Text(
      text ?? "",
      softWrap: false,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.linear(CineScaler.textScale),
      style: (style ?? CineTextStyles.b1).copyWith(color: color),
    );
  }
}
