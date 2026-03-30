import 'package:flutter/material.dart';

/// A simple "Ad" badge widget used to indicate that a widget is an advertisement.
class PreloadAdBadge extends StatelessWidget {
  /// The background color of the badge.
  final Color? backgroundColor;

  /// The text color of the badge.
  final Color? textColor;

  /// The corner radius of the badge.
  final double borderRadius;

  /// Constructor for [PreloadAdBadge].
  const PreloadAdBadge({
    super.key,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF19938),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        "Ad",
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
