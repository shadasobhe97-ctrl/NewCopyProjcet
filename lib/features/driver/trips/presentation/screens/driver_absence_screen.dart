import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_absence_cubit/driver_absence_cubit.dart';

const List<String> _arabicMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

const List<String> _arabicWeekdays = ['اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];

/// شاشة تسجيل غياب السائق — اختيار عدة تواريخ ثم إرسالها للـ Backend
class DriverAbsenceScreen extends StatefulWidget {
  const DriverAbsenceScreen({super.key});

  @override
  State<DriverAbsenceScreen> createState() => _DriverAbsenceScreenState();
}

class _DriverAbsenceScreenState extends State<DriverAbsenceScreen> {
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _changeMonth(int delta) {
    setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(title: const Text('تسجيل غياب')),
        body: BlocConsumer<DriverAbsenceCubit, DriverAbsenceState>(
          listenWhen: (previous, current) =>
              current.submitStatus != previous.submitStatus &&
              (current.submitStatus == DriverAbsenceSubmitStatus.success ||
                  current.submitStatus == DriverAbsenceSubmitStatus.error),
          listener: (context, state) {
            if (state.submitStatus == DriverAbsenceSubmitStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تسجيل الغياب بنجاح.'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.of(context).pop();
            } else if (state.submitStatus == DriverAbsenceSubmitStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'فشل تسجيل الغياب.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختر تاريخاً واحداً أو أكثر ستكون فيها غائباً، ولن يقوم النظام بتوليد رحلات لمساراتك في تلك الأيام.',
                          style: AppTextStyles.style(fontSize: 13, color: context.textMuted, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        _buildCalendar(context, state),
                        if (state.selectedDates.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            'التواريخ المختارة (${state.selectedDates.length})',
                            style: AppTextStyles.style(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.selectedDates.map((date) {
                              return Chip(
                                label: Text(_formatDisplay(date)),
                                onDeleted: () =>
                                    context.read<DriverAbsenceCubit>().toggleDate(date),
                                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PrimaryButton(
                    label: 'تسجيل الغياب',
                    icon: Icons.event_busy_rounded,
                    width: double.infinity,
                    isLoading: state.submitStatus == DriverAbsenceSubmitStatus.submitting,
                    onPressed: state.selectedDates.isEmpty
                        ? null
                        : () => context.read<DriverAbsenceCubit>().submit(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDisplay(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Widget _buildCalendar(BuildContext context, DriverAbsenceState state) {
    final isDark = context.isDarkMode;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = (firstDayOfMonth.weekday - DateTime.monday) % 7;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(
          color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                '${_arabicMonths[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                style: AppTextStyles.style(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _arabicWeekdays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: AppTextStyles.style(fontSize: 11, color: context.textMuted),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
              final isPast = date.isBefore(today);
              final isSelected = state.selectedDates.contains(date);

              return Padding(
                padding: const EdgeInsets.all(3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: isPast ? null : () => context.read<DriverAbsenceCubit>().toggleDate(date),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : (isPast ? AppColors.grey.withValues(alpha: 0.05) : null),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$day',
                      style: AppTextStyles.style(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColors.white
                            : (isPast ? AppColors.grey400 : null),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
