import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class ComplaintForm extends StatefulWidget {
  final String? initialDescription;
  final bool isSubmitting;
  final void Function(String description) onSubmit;
  final String submitButtonText;

  const ComplaintForm({
    super.key,
    this.initialDescription,
    required this.isSubmitting,
    required this.onSubmit,
    this.submitButtonText = 'حفظ التعديلات',
  });

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_controller.text.trim());
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
            'تفاصيل الشكوى',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _controller,
            maxLines: 4,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب الشكوى بالتفصيل هنا لمتابعتها مع الإدارة...',
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
                return 'يرجى كتابة نص الشكوى';
              }
              if (val.trim().length < 10) {
                return 'يرجى إدخال 10 حروف على الأقل لوصف الشكوى بشكل كامل';
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
