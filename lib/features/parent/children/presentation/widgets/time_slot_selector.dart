import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

/// محدد الفترة الزمنية: صباحية / مسائية / كلاهما.
class TimeSlotSelector extends StatelessWidget {
  final PreferredTimeSlot selected;
  final ValueChanged<PreferredTimeSlot> onChanged;

  const TimeSlotSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _slots = [
    _SlotConfig(
      slot: PreferredTimeSlot.MORNING,
      label: 'فترة صباحية',
      emoji: '☀️',
      color: AppColors.accentAmber,
    ),
    _SlotConfig(
      slot: PreferredTimeSlot.EVENING,
      label: 'فترة مسائية',
      emoji: '🌙',
      color: AppColors.accentBlue,
    ),
    _SlotConfig(
      slot: PreferredTimeSlot.BOTH,
      label: 'الفترتين',
      emoji: '🔄',
      color: AppColors.accentGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _slots.map((s) {
        final isSelected = selected == s.slot;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(s.slot),
            borderRadius: AppTheme.radius(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: AppTheme.boxDecoration(
                color:
                    isSelected
                        ? s.color.withValues(alpha: 0.12)
                        : AppColors.transparent,
                borderRadius: AppTheme.radius(12),
                border: AppTheme.border(
                  color:
                      isSelected
                          ? s.color
                          : AppColors.grey.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    s.emoji,
                    style: AppTextStyles.style(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.label,
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? s.color : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: s.color, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SlotConfig {
  final PreferredTimeSlot slot;
  final String label;
  final String emoji;
  final Color color;

  const _SlotConfig({
    required this.slot,
    required this.label,
    required this.emoji,
    required this.color,
  });
}
