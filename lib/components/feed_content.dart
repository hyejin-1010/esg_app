import 'package:flutter/material.dart';

class FeedContent extends StatelessWidget {
  const FeedContent({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> textSpans = [];
    final RegExp hashtagRegExp = RegExp(r'#\S+');
    final defaultStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800);

    int lastIndex = 0;
    for (final match in hashtagRegExp.allMatches(content)) {
      if (match.start > lastIndex) {
        textSpans.add(
          TextSpan(
            text: content.substring(lastIndex, match.start),
            style: defaultStyle,
          ),
        );
      }

      textSpans.add(
        TextSpan(
          text: match.group(0),
          style: defaultStyle?.copyWith(color: Colors.blue),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < content.length) {
      textSpans.add(
        TextSpan(text: content.substring(lastIndex), style: defaultStyle),
      );
    }

    return RichText(text: TextSpan(children: textSpans));
  }
}
