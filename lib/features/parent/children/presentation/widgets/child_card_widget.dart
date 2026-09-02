import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/child_model.dart';

class ChildCardWidget extends StatefulWidget {
  final ChildModel child;
  final VoidCallback onPassTap;
  final VoidCallback onDataTap;
  final VoidCallback onTransportTap;
  final VoidCallback onDelete;

  const ChildCardWidget({
    super.key,
    required this.child,
    required this.onPassTap,
    required this.onDataTap,
    required this.onTransportTap,
    required this.onDelete,
  });

  @override
  State<ChildCardWidget> createState() => _ChildCardWidgetState();
}

class _ChildCardWidgetState extends State<ChildCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final child = widget.child;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16.r),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── الصف العلوي (صورة الطفل يميناً، الاسم والصف بالوسط، السهم يساراً) ──
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: AppTheme.radius(16.r),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  // صورة الطفل (على اليمين في RTL)
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: AppTheme.boxDecoration(
                      shape: BoxShape.circle,
                      color: child.gender == 'male'
                          ? context.maleBlueBg
                          : context.femalePinkBg,
                      border: AppTheme.border(
                        color: child.gender == 'male'
                            ? context.genderMaleColor
                            : context.genderFemaleColor,
                        width: 1.5.w,
                      ),
                    ),
                    child: child.hasRealPhoto
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: child.photoUrl!,
                              fit: BoxFit.cover,
                              width: 48.w,
                              height: 48.h,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  color: child.gender == 'male'
                                      ? context.genderMaleColor
                                      : context.genderFemaleColor,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person_rounded,
                                color: child.gender == 'male'
                                    ? context.genderMaleColor
                                    : context.genderFemaleColor,
                                size: 26.r,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            color: child.gender == 'male'
                                ? context.genderMaleColor
                                : context.genderFemaleColor,
                            size: 26.r,
                          ),
                  ),
                  SizedBox(width: 12.w),

                  // اسم الطفل والصف فقط (في الوسط)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: isDark ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          child.gradeDisplay,
                          style: AppTextStyles.style(
                            color: context.textMuted,
                            fontSize: 12.5.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // سهم التوسيع/الطي (على اليسار)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    icon: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                      size: 24.r,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── صف الإجراءات الثلاثة (يظهر فقط عند التوسيع) ──
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. تفاصيل الطفل
                  TextButton.icon(
                    onPressed: widget.onDataTap,
                    icon: Icon(
                      Icons.person_outline_rounded,
                      color: context.primaryColor,
                      size: 18.r,
                    ),
                    label: Text(
                      'تفاصيل الطفل',
                      style: AppTextStyles.style(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),

                  // 2. رمز QR
                  TextButton.icon(
                    onPressed: widget.onPassTap,
                    icon: Icon(
                      Icons.qr_code_rounded,
                      color: context.primaryColor,
                      size: 18.r,
                    ),
                    label: Text(
                      'رمز QR',
                      style: AppTextStyles.style(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),

                  // 3. حذف
                  TextButton.icon(
                    onPressed: widget.onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 18.r,
                    ),
                    label: Text(
                      'حذف',
                      style: AppTextStyles.style(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
