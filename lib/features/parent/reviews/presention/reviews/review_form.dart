import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'rating_stars.dart';

class ReviewForm extends StatefulWidget {
  final int? initialRating;
  final String? initialComment;
  final bool isSubmitting;
  final void Function(int rating, String comment) onSubmit;
  final String submitButtonText;

  const ReviewForm({
    super.key,
    this.initialRating,
    this.initialComment,
    required this.isSubmitting,
    required this.onSubmit,
    this.submitButtonText = 'إرسال التقييم',
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _commentController;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تحديد التقييم بالنجوم أولاً.',
            style: AppTextStyles.style(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_rating, _commentController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ما هو تقييمك للكابتن؟',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: RatingStars(
              rating: _rating.toDouble(),
              isInteractive: true,
              itemSize: 32.r,
              onRatingChanged: (val) {
                setState(() {
                  _rating = val.toInt();
                });
              },
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'اكتب مراجعتك هنا',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _commentController,
            maxLines: 3,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب تفاصيل تجربتك مع السائق لمساعدة أولياء الأمور الآخرين...',
              hintStyle: AppTextStyles.style(
                fontSize: 11.5.sp,
                color: isDark ? AppColors.grey500 : AppColors.textMuted,
              ),
              contentPadding: EdgeInsets.all(12.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: isDark ? AppColors.grey800 : AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'حقل التعليق مطلوب';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: widget.isSubmitting ? null : _submit,
              child: widget.isSubmitting
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                    )
                  : Text(
                      widget.submitButtonText,
                      style: AppTextStyles.style(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
