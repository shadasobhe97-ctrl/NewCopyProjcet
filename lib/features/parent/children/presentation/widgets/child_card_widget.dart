import 'package:flutter/material.dart';
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

  String _getGradeLevel(int level) {
    switch (level) {
      case 1: return 'روضة';
      case 2: return 'ابتدائي';
      case 3: return 'إعدادي';
      case 4: return 'ثانوي';
      default: return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(20),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // الجزء العلوي: بيانات الطفل
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // صورة الطفل
                Container(
                  width: 60,
                  height: 60,
                  decoration: AppTheme.boxDecoration(
                    shape: BoxShape.circle,
                    color: child.gender == 'male' ? context.maleBlueBg : context.femalePinkBg,
                    border: AppTheme.border(
                      color: child.gender == 'male' ? context.genderMaleColor : context.genderFemaleColor,
                      width: 2,
                    ),
                  ),
                  child: child.image != null
                      ? ClipOval(
                          child: Image.network(
                            child.image!,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person_rounded,
                              color: child.gender == 'male'
                                  ? context.genderMaleColor
                                  : context.genderFemaleColor,
                              size: 32,
                            ),
                            loadingBuilder: (_, w, p) => p == null
                                ? w
                                : Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: child.gender == 'male'
                                          ? context.genderMaleColor
                                          : context.genderFemaleColor,
                                    ),
                                  ),
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          color: child.gender == 'male' ? context.genderMaleColor : context.genderFemaleColor,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                // تفاصيل الطفل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.school_rounded, size: 14, color: context.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${_getGradeLevel(child.gradeLevel)} - ${child.schoolName}',
                              style: AppTextStyles.style(
                                color: context.textMuted,
                                fontSize: 13,
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
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  tooltip: 'حذف الطفل',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // الجزء السفلي: الأزرار الثلاثة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        borderRadius: AppTheme.radius(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.style(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}