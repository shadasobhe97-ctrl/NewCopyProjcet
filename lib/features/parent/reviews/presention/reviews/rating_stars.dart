import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final bool isInteractive;
  final ValueChanged<double>? onRatingChanged;
  final double itemSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.isInteractive = false,
    this.onRatingChanged,
    this.itemSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isInteractive) {
      return RatingBar.builder(
        initialRating: rating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: itemSize,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => const Icon(
          Icons.star_rounded,
          color: AppColors.amber,
        ),
        onRatingUpdate: onRatingChanged ?? (_) {},
      );
    } else {
      return RatingBarIndicator(
        rating: rating,
        itemBuilder: (context, index) => const Icon(
          Icons.star_rounded,
          color: AppColors.amber,
        ),
        itemCount: 5,
        itemSize: itemSize,
        direction: Axis.horizontal,
      );
    }
  }
}
