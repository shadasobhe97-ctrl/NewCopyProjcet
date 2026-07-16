import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/child_model.dart';

class ChildCardWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // === DEBUG: Child Card Build ===
    debugPrint('===== BUILD CARD =====');
    debugPrint(child.toJson().toString());

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
          // الجزء العلوي: بيانات الطفل
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // صورة الطفل
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: AppTheme.boxDecoration(
                    shape: BoxShape.circle,
                    color: child.gender == 'male'
                        ? context.maleBlueBg
                        : context.femalePinkBg,
                    border: AppTheme.border(
                      color: child.gender == 'male'
                          ? context.genderMaleColor
                          : context.genderFemaleColor,
                      width: 2.w,
                    ),
                  ),
                  child: child.photoUrl != null && child.photoUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: child.photoUrl!,
                            fit: BoxFit.cover,
                            width: 60.w,
                            height: 60.h,
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
                              size: 32.r,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          color: child.gender == 'male'
                              ? context.genderMaleColor
                              : context.genderFemaleColor,
                          size: 32.r,
                        ),
                ),
                SizedBox(width: 16.w),
                // تفاصيل الطفل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 14.r,
                            color: context.textMuted,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              '${child.gradeDisplay} - ${child.schoolName}',
                              style: AppTextStyles.style(
                                color: context.textMuted,
                                fontSize: 13.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  tooltip: 'حذف الطفل',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // الجزء السفلي: الأزرار الثلاثة
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              children: [
                _buildActionButton(
                  context: context,
                  label: 'بطاقة الطفل',
                  icon: Icons.qr_code_rounded,
                  color: context.primaryColor,
                  onTap: onPassTap,
                ),
                _buildActionButton(
                  context: context,
                  label: 'بيانات الطفل',
                  icon: Icons.person_search_rounded,
                  color: context.infoColor,
                  onTap: onDataTap,
                ),
                _buildActionButton(
                  context: context,
                  label: 'بيانات النقل',
                  icon: Icons.directions_bus_rounded,
                  color: context.successColor,
                  onTap: onTransportTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radius(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22.r),
              SizedBox(height: 4.h),
              Text(
                label,
                style: AppTextStyles.style(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
