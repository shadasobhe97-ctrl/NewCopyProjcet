import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

/// أفاتار الطفل مع مؤشر الحضور.
class ChildAvatar extends StatelessWidget {
  final ChildModel child;
  final double radius;

  const ChildAvatar({super.key, required this.child, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    final isMale = child.gender == 'MALE';
    final isPresent = child.dailyStatus == DailyStatus.present;
    final avatarColor = isMale ? AppColors.maleBlue : AppColors.femalePink;
    final avatarBg = isMale ? AppColors.maleBlueBg : AppColors.femalePinkBg;

    return Stack(
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: AppTheme.boxDecoration(
            color: avatarBg,
            shape: BoxShape.circle,
            border: AppTheme.border(
              color: avatarColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: child.photoUrl != null
              ? ClipOval(
                  child: Image.network(child.photoUrl!, fit: BoxFit.cover),
                )
              : Icon(
                  isMale ? Icons.boy_rounded : Icons.girl_rounded,
                  color: avatarColor,
                  size: radius * 1.1,
                ),
        ),
        // مؤشر الحضور
        Positioned(
          bottom: 2,
          left: 2,
          child: Container(
            width: 14,
            height: 14,
            decoration: AppTheme.boxDecoration(
              color: isPresent ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
              border: AppTheme.border(color: AppColors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// بطاقة الطفل في قائمة "أطفالي".
class ChildCard extends StatelessWidget {
  final ChildModel child;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChildCard({
    super.key,
    required this.child,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان الفترة الزمنية
    final slotColors = {
      PreferredTimeSlot.MORNING: [AppColors.accentAmber, 'صباحي ☀️'],
      PreferredTimeSlot.EVENING: [AppColors.accentBlue, 'مسائي 🌙'],
      PreferredTimeSlot.BOTH: [AppColors.accentGreen, 'صباحي ومسائي 🔄'],
    };
    final slotInfo = slotColors[child.preferredTimeSlot]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(20),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── رأس الكرت ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                ChildAvatar(child: child),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.fullName,
                        style: AppTextStyles.style(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              child.schoolName,
                              style: AppTextStyles.style(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // بيدج الفترة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: AppTheme.boxDecoration(
                    color: (slotInfo[0] as Color).withValues(alpha: 0.12),
                    borderRadius: AppTheme.radius(20),
                  ),
                  child: Text(
                    slotInfo[1] as String,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      color: slotInfo[0] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── فاصل ───────────────────────────────────────────────
          Divider(
            height: 1,
            color: isDark
                ? AppColors.white.withValues(alpha: 0.07)
                : AppColors.black.withValues(alpha: 0.06),
          ),

          // ─── أزرار الإجراءات ─────────────────────────────────────
          Row(
            children: [
              _ActionButton(
                icon: Icons.visibility_outlined,
                label: 'التفاصيل',
                color: AppColors.primaryLight,
                onTap: onViewDetails,
              ),
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'تعديل',
                color: AppColors.accentPurple,
                onTap: onEdit,
              ),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'حذف',
                color: AppColors.error,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radius(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.style(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
