import 'package:flutter/material.dart';

/// A simple star rating widget.
class PreloadStarRating extends StatelessWidget {
  /// The rating value (0–5).
  final double rating;

  /// The size of each star.
  final double size;

  /// The color of the stars.
  final Color color;

  /// Constructor for [PreloadStarRating].
  const PreloadStarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        if (index < rating.floor()) {
          icon = Icons.star;
        } else if (index < rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, size: size, color: color);
      }),
    );
  }
}
