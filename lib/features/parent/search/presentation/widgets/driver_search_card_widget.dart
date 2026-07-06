import 'package:flutter/material.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class DriverSearchCardWidget extends StatelessWidget {
  final DriverSearchModel driver;
  final bool isSelected;

  /// يُستدعى عند تغيير حالة الاختيار (الـ checkbox).
  /// يكون null عند وضع البحث بالاسم لمنع التحديد المباشر.
  final ValueChanged<bool?>? onSelectedChanged;

  /// يُستدعى عند الضغط على الكرت كاملاً أو زر "عرض الملف".
  final VoidCallback onTap;

  const DriverSearchCardWidget({
    super.key,
    required this.driver,
    required this.isSelected,
    required this.onTap,
    this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.surfaceDark : AppColors.white;
    final borderColor = isSelected
        ? cs.primary
        : (isDark ? AppColors.grey800 : AppColors.grey200);
    final subTextColor = isDark ? AppColors.grey400 : AppColors.textMuted;
    final bodyTextColor = isDark ? AppColors.grey200 : AppColors.textDark;
    final badgeBg = isDark ? AppColors.grey800 : AppColors.grey100;

    return GestureDetector(
      onTap: () {
        if (onSelectedChanged != null) {
          onSelectedChanged!(!isSelected);
        } else {
          onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withValues(alpha: isDark ? 0.12 : 0.04)
              : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── صورة السائق ──
                CircleAvatar(
                  radius: 26,
                  backgroundColor: isDark ? AppColors.grey800 : AppColors.grey100,
                  child: Icon(
                    driver.gender == 'FEMALE' ? Icons.face_4_rounded : Icons.person_rounded,
                    size: 30,
                    color: isDark ? AppColors.grey500 : AppColors.grey400,
                  ),
                ),
                const SizedBox(width: 12),

                // ── تفاصيل السائق ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم + شارة متاح
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              driver.fullName,
                              style: AppTextStyles.style(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: bodyTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'متاح',
                              style: AppTextStyles.style(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // التقييم
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.amber, size: 15),
                          const SizedBox(width: 3),
                          Text(
                            '${driver.rating} (${driver.reviewsCount})',
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: isDark ? AppColors.grey300 : AppColors.grey800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // مناطق الخدمة
                      Text(
                        'يغطي: ${driver.serviceZones.take(2).join('، ')}${driver.serviceZones.length > 2 ? '...' : ''}',
                        style: AppTextStyles.style(fontSize: 11, color: subTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // الشارات
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _badge(
                            context,
                            icon: Icons.airline_seat_recline_normal_rounded,
                            label: '${driver.availableSeats} مقاعد',
                            bg: badgeBg,
                            fg: isDark ? AppColors.grey300 : AppColors.grey700,
                          ),
                          _coloredBadge(context, 'صباحية', AppColors.accentAmber),
                          _coloredBadge(context, 'ذهاب وعودة', AppColors.accentBlue),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── الجهة اليسرى: السعر ثم مربع الاختيار فوقه ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (onSelectedChanged != null)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: isSelected,
                          activeColor: cs.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: onSelectedChanged,
                        ),
                      )
                    else
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.favorite_border_rounded,
                          color: isDark ? AppColors.grey600 : AppColors.grey400,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'ابتداءً من',
                      style: AppTextStyles.style(fontSize: 10, color: subTextColor),
                    ),
                    Text(
                      '${driver.price.toInt()} د.ل',
                      style: AppTextStyles.style(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── زر عرض الملف ──
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'عرض الملف',
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 3),
          Text(label, style: AppTextStyles.style(fontSize: 10, color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _coloredBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.style(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
