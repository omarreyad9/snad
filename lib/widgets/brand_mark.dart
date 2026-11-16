import 'package:flutter/material.dart';
import 'package:muse/theme/app_theme.dart';

/// The "muse" brand mark — a sparkle icon in a rounded badge + wordmark.
class BrandMark extends StatelessWidget {
  final bool light;
  final double scale;

  const BrandMark({super.key, this.light = false, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    final iconBg = light ? Colors.white : context.mc.brand;
    final iconFg = light ? context.mc.brand : Colors.white;
    final textColor = light ? Colors.white : context.mc.textStrong;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 23 * scale,
          height: 23 * scale,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8 * scale),
              topRight: Radius.circular(8 * scale),
              bottomRight: Radius.circular(8 * scale),
              bottomLeft: Radius.circular(2 * scale),
            ),
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 13 * scale,
            color: iconFg,
          ),
        ),
        SizedBox(width: 8 * scale),
        Text(
          'muse',
          style: TextStyle(
            fontFamily: MuseTheme.sans,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.72,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
