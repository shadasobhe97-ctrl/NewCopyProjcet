import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class WorkAreasCard extends StatefulWidget {
  const WorkAreasCard({super.key});

  @override
  State<WorkAreasCard> createState() => _WorkAreasCardState();
}

class _WorkAreasCardState extends State<WorkAreasCard> {
  // TODO: يجب سحب القائمة وتحديد المناطق المحفوظة مسبقاً من الـ API
  final List<String> _availableAreas = [
    'حي الأندلس',
    'سوق الجمعة',
    'عين زارة',
    'تاجوراء',
    'حدائق بن غشير',
    'أبو سليم',
    'طرابلس المركز',
  ];

  final Set<String> _selectedAreas = {'حي الأندلس'};

  void _showAreaSelector(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: AppTheme.roundedRectangleBorder(
        borderRadius: AppTheme.verticalRadius(top: AppTheme.cornerRadius(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: 400,
              decoration: AppTheme.boxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                borderRadius: AppTheme.verticalRadius(
                  top: AppTheme.cornerRadius(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختر مناطق التغطية',
                    style: AppTextStyles.style(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يمكنك اختيار أكثر من منطقة للعمل داخلها.',
                    style: AppTextStyles.style(color: AppColors.grey500, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _availableAreas.map((area) {
                          final isSelected = _selectedAreas.contains(area);
                          return FilterChip(
                            label: Text(area),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedAreas.add(area);
                                } else {
                                  _selectedAreas.remove(area);
                                }
                              });
                              setState(() {}); // تحديث الواجهة الرئيسية
                            },
                            selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primaryLight,
                            labelStyle: AppTextStyles.style(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : (isDark
                                        ? AppColors.white70
                                        : AppColors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: isDark
                                ? AppColors.grey800
                                : AppColors.grey200,
                            shape: AppTheme.roundedRectangleBorder(
                              borderRadius: AppTheme.radius(10),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // TODO: [ربط API] - إرسال المناطق المحددة للباكند للحفظ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تحديث مناطق التغطية بنجاح'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: AppTheme.elevatedButtonStyle(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: AppTheme.roundedRectangleBorder(
                          borderRadius: AppTheme.radius(12),
                        ),
                      ),
                      child: Text(
                        'حفظ المناطق',
                        style: AppTextStyles.style(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(20),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.map_outlined,
                    color: AppColors.primaryLight,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'مناطق العمل الحالية',
                    style: AppTextStyles.style(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showAreaSelector(context, isDark),
                icon: const Icon(
                  Icons.edit_location_alt_rounded,
                  color: AppColors.primaryLight,
                ),
                tooltip: 'تعديل المناطق',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedAreas.isEmpty)
            Text(
              'لم يتم تحديد مناطق عمل بعد.',
              style: AppTextStyles.style(color: AppColors.grey500),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedAreas.map((area) {
                return Chip(
                  label: Text(
                    area,
                    style: AppTextStyles.style(
                      fontSize: 13,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  shape: AppTheme.roundedRectangleBorder(
                    borderRadius: AppTheme.radius(8),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
