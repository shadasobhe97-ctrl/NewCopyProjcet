import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

class ChildTripProgressStepperWidget extends StatelessWidget {
  final String childName;
  final String childStatus;
  final String tripDirection;
  final String? pickupTime;
  final int? estimatedMinutes;

  const ChildTripProgressStepperWidget({
    super.key,
    required this.childName,
    required this.childStatus,
    required this.tripDirection,
    this.pickupTime,
    this.estimatedMinutes = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isToSchool = tripDirection.toLowerCase() != 'to_home';
    final firstName = childName.isNotEmpty ? childName.split(' ')[0] : 'الطفل';

    final s = childStatus.toLowerCase();
    int currentStep = 1; // Default: في الطريق
    String headerTitle = 'في الطريق لاستلام $firstName';
    String headerSubtitle = estimatedMinutes != null
        ? 'الوصول المتوقع خلال $estimatedMinutes دقائق'
        : 'الحافلة في الطريق إلى نقطة الاستلام';

    if (s.contains('boarded') || s.contains('onboard') || s.contains('in_bus') || s.contains('picked_up')) {
      currentStep = 2; // الاستلام
      headerTitle = 'تم استلام $firstName - الحافلة في الطريق';
      headerSubtitle = isToSchool
          ? 'في الطريق نحو مدرسة $firstName'
          : 'في الطريق نحو المنزل';
    } else if (s.contains('arrived') || s.contains('dropped_off') || s.contains('completed')) {
      currentStep = 3; // الوصول
      headerTitle = 'وصل $firstName بنجاح';
      headerSubtitle = isToSchool ? 'تم تسليم الطفل إلى المدرسة' : 'تم توصيل الطفل للمنزل';
    } else if (s.contains('pending') || s.contains('scheduled')) {
      currentStep = 0; // انطلق
      headerTitle = 'في انتظار انطلاق رحلة $firstName';
      headerSubtitle = 'سيتم بدء التتبع عند تحرك الحافلة';
    }

    final steps = [
      'انطلق',
      'في الطريق',
      'الاستلام',
      isToSchool ? 'وصل المدرسة' : 'وصل المنزل',
    ];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.grey50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          // Header Title & Subtitle
          Text(
            headerTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            headerSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 11.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 16.h),

          // Stepper Line & Nodes (RTL Layout)
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index < currentStep;
              final isActive = index == currentStep;
              final isLast = index == steps.length - 1;

              return Expanded(
                flex: isLast ? 0 : 1,
                child: Row(
                  children: [
                    // Node Circle
                    _buildStepNode(context, index, isCompleted, isActive),

                    // Connecting Line (if not last node)
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 3.h,
                          color: index < currentStep
                              ? context.primaryColor
                              : (isDark ? AppColors.grey800 : AppColors.grey300),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 8.h),

          // Step Labels Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final isCompleted = index <= currentStep;
              final isActive = index == currentStep;

              return SizedBox(
                width: 60.w,
                child: Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style(
                    fontSize: 9.5.sp,
                    fontWeight: (isActive || isCompleted)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isActive
                        ? context.primaryColor
                        : (isCompleted ? context.textPrimary : AppColors.textMuted),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(
    BuildContext context,
    int index,
    bool isCompleted,
    bool isActive,
  ) {
    if (isCompleted) {
      return Container(
        width: 22.r,
        height: 22.r,
        decoration: BoxDecoration(
          color: context.primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          size: 14.r,
          color: AppColors.white,
        ),
      );
    }

    if (isActive) {
      return Container(
        width: 22.r,
        height: 22.r,
        decoration: BoxDecoration(
          color: context.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withValues(alpha: 0.35),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    }

    // Pending Node (Empty Circle)
    return Container(
      width: 20.r,
      height: 20.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.isDarkMode ? AppColors.grey700 : AppColors.grey400,
          width: 2.0,
        ),
      ),
    );
  }
}
