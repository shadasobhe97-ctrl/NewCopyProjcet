import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

class ChildSelectionCardWidget extends StatefulWidget {
  final ChildModel kid;
  final bool isSelected;
  final Function(int, bool) onKidToggle;
  final Function(ChildModel)? onEditChoice;
  final Function(ChildModel)? onEditPersonalData;
  final Function(ChildModel)? onEditTransportData;

  const ChildSelectionCardWidget({
    super.key,
    required this.kid,
    required this.isSelected,
    required this.onKidToggle,
    this.onEditChoice,
    this.onEditPersonalData,
    this.onEditTransportData,
  });

  @override
  State<ChildSelectionCardWidget> createState() =>
      _ChildSelectionCardWidgetState();
}

class _ChildSelectionCardWidgetState extends State<ChildSelectionCardWidget> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final kid = widget.kid;
    final isMale = kid.gender.toLowerCase() == 'male';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.04)
            : (isDark ? AppColors.surfaceDark : AppColors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isSelected
              ? theme.colorScheme.primary
              : (isDark ? AppColors.grey800 : AppColors.grey200),
          width: widget.isSelected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── الصف العلوي (مربع الاختيار، صورة، اسم، صف فقط، وزر تعديل) ──
            Row(
              children: [
                Checkbox(
                  value: widget.isSelected,
                  activeColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (val) =>
                      widget.onKidToggle(kid.id ?? 0, val ?? false),
                ),
                const SizedBox(width: 6),

                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      (isMale
                              ? theme.colorScheme.primary
                              : AppColors.femalePink)
                          .withValues(alpha: 0.1),
                  child: Icon(
                    isMale ? Icons.face_rounded : Icons.face_4_rounded,
                    color: isMale
                        ? theme.colorScheme.primary
                        : AppColors.femalePink,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kid.name,
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // الصف فقط دون عرض اسم المدرسة
                      Text(
                        kid.gradeDisplay,
                        style: AppTextStyles.style(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.grey400
                              : AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // زر خيارات تعديل البيانات الأساسية
                IconButton(
                  onPressed: () =>
                      (widget.onEditPersonalData ?? widget.onEditChoice)?.call(kid),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                    size: 20,
                  ),
                  tooltip: 'تعديل البيانات الأساسية',
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── زر تعديل بيانات النقل البارز (لون رمادي أنيق) ──
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: () =>
                    (widget.onEditTransportData ?? widget.onEditChoice)?.call(kid),
                icon: const Icon(Icons.edit_road_rounded, size: 18),
                label: Text(
                  "تعديل بيانات النقل",
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.grey300 : AppColors.grey800,
                  side: BorderSide(
                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── بيانات النقل الأساسية (مرتبة رأسياً في عمود) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.grey900.withValues(alpha: 0.5)
                    : AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    context,
                    "• الاتجاه:",
                    kid.transportPref.serviceTypeDisplay,
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    context,
                    "• الفترة:",
                    kid.transportPref.periodDisplay,
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    context,
                    "• عنوان المنزل:",
                    kid.addressName,
                  ),

                  // التفاصيل الإضافية عند التوسيع
                  if (_showMore) ...[
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      context,
                      "• المدرسة (التنزيل):",
                      kid.schoolName,
                    ),
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      context,
                      "• نوع الاشتراك:",
                      kid.transportPref.subscriptionTypeDisplay,
                    ),
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      context,
                      "• توقيت الدوام:",
                      kid.transportPref.schoolHoursDisplay,
                    ),
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      context,
                      "• فترة الاشتراك:",
                      kid.transportPref.subscriptionDatePeriodDisplay,
                    ),
                  ],

                  const SizedBox(height: 6),
                  // زر عرض المزيد
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showMore = !_showMore;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _showMore
                                ? "إخفاء التفاصيل"
                                : "عرض المزيد من تفاصيل النقل",
                            style: AppTextStyles.style(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _showMore
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.style(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.grey300 : AppColors.textDark,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.style(
              fontSize: 12.5,
              color: isDark ? AppColors.grey400 : AppColors.grey700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
