import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class FilterSheet extends StatefulWidget {
  final String selectedGender;
  final bool hasAcOnly;
  final Function(String gender, bool hasAc) onApply;
  final VoidCallback onReset;

  const FilterSheet({
    super.key,
    required this.selectedGender,
    required this.hasAcOnly,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String _tempGender;
  late bool _tempHasAc;

  @override
  void initState() {
    super.initState();
    _tempGender = widget.selectedGender;
    _tempHasAc = widget.hasAcOnly;
  }

  Widget _buildGenderOption({
    required String label,
    required String value,
    required bool isDark,
    required ThemeData theme,
  }) {
    final isSelected = _tempGender == value;
    return GestureDetector(
      onTap: () => setState(() => _tempGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.06)
              : (isDark ? AppColors.grey900 : AppColors.grey50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? AppColors.grey800 : AppColors.grey200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.style(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? AppColors.grey300 : AppColors.textDark),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مقبض السحب
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey700 : AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // العنوان
            Text(
              'تصفية السائقين',
              style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),

            // جنس السائق
            Text(
              'جنس السائق',
              style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? AppColors.grey300 : AppColors.grey700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption(
                    label: 'الكل',
                    value: 'ALL',
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildGenderOption(
                    label: 'ذكر',
                    value: 'MALE',
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildGenderOption(
                    label: 'أنثى',
                    value: 'FEMALE',
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // التكييف
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مركبة مكيفة فقط',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'عرض السائقين الذين يمتلكون تكييف هواء فقط',
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _tempHasAc,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (val) => setState(() => _tempHasAc = val),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onApply(_tempGender, _tempHasAc);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'تطبيق',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onReset();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? AppColors.grey800 : AppColors.grey300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'إعادة تعيين',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? AppColors.grey300 : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
