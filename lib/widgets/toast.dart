import 'package:flutter/material.dart';
import 'package:muse/theme/app_theme.dart';

/// A transient toast notification shown at the bottom of the screen.
class Toast extends StatelessWidget {
  final String message;

  const Toast({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 95,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: context.mc.toast,
          child: Text(
            message,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
