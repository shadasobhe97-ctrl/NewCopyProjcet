import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/available_absence_dates_model.dart';

class AbsenceCalendarWidget extends StatefulWidget {
  final AvailableAbsenceDatesModel datesModel;
  final List<DateTime> selectedDates;
  final void Function(DateTime date) onDateTap;

  const AbsenceCalendarWidget({
    super.key,
    required this.datesModel,
    required this.selectedDates,
    required this.onDateTap,
  });

  @override
  State<AbsenceCalendarWidget> createState() => _AbsenceCalendarWidgetState();
}

class _AbsenceCalendarWidgetState extends State<AbsenceCalendarWidget> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    // ابدأ بأول شهر يحتوي على أيام متاحة أو الشهر الحالي
    final available = widget.datesModel.availableDates;
    _focusedMonth = available.isNotEmpty
        ? DateTime(available.first.year, available.first.month)
        : DateTime.now();
  }

  bool _isSelected(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return widget.selectedDates.any(
      (s) => DateTime(s.year, s.month, s.day) == d,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      children: [
        // ─── Header الشهر ─────────────────────────────────────────────
        _buildMonthHeader(context, isDark),
        const SizedBox(height: 8),
        // ─── أسماء الأيام ─────────────────────────────────────────────
        _buildWeekDaysRow(isDark),
        const SizedBox(height: 4),
        // ─── Grid الأيام ──────────────────────────────────────────────
        _buildDaysGrid(context, isDark),
        // ─── Legend ───────────────────────────────────────────────────
        const SizedBox(height: 12),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildMonthHeader(BuildContext context, bool isDark) {
    final monthNames = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => setState(() {
            _focusedMonth = DateTime(
              _focusedMonth.year,
              _focusedMonth.month - 1,
            );
          }),
          icon: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
        Text(
          '${monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
          style: AppTextStyles.style(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
        IconButton(
          onPressed: () => setState(() {
            _focusedMonth = DateTime(
              _focusedMonth.year,
              _focusedMonth.month + 1,
            );
          }),
          icon: Icon(
            Icons.chevron_left_rounded,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDaysRow(bool isDark) {
    const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: AppTextStyles.style(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.grey500 : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDaysGrid(BuildContext context, bool isDark) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    // حساب يوم الأسبوع (السبت = 0 في العرض العربي)
    // weekday: 1=Mon .. 7=Sun → نريد السبت=0
    int startOffset = (firstDay.weekday % 7); // Mon=1..Sat=6,Sun=0 → نحول
    // ترتيب: السبت، الأحد، الاثنين، الثلاثاء، الأربعاء، الخميس، الجمعة
    // firstDay.weekday: 1=Mon,2=Tue,3=Wed,4=Thu,5=Fri,6=Sat,7=Sun
    startOffset = (firstDay.weekday == 7) ? 1 : firstDay.weekday + 1;
    startOffset = startOffset % 7;

    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 4,
        crossAxisSpacing: 2,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        final dayNumber = index - startOffset + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
        return _buildDayCell(context, date, isDark);
      },
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date, bool isDark) {
    final isAvailable = widget.datesModel.isAvailable(date);
    final isAbsent = widget.datesModel.isAlreadyAbsent(date);
    final isSelected = _isSelected(date);

    Color bgColor = Colors.transparent;
    Color textColor = isDark ? AppColors.grey600 : AppColors.grey300;
    bool canTap = false;
    Widget? overlay;

    if (isAbsent) {
      // غياب مسجل مسبقاً
      bgColor = AppColors.warning.withValues(alpha: 0.15);
      textColor = AppColors.warning;
      overlay = Positioned(
        bottom: 2,
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.warning,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else if (isSelected) {
      // مختار من المستخدم
      bgColor = context.primaryColor;
      textColor = AppColors.white;
      canTap = true;
    } else if (isAvailable) {
      // متاح للاختيار
      bgColor = context.primaryColor.withValues(alpha: 0.08);
      textColor = isDark ? AppColors.white : AppColors.textDark;
      canTap = true;
    }

    return GestureDetector(
      onTap: canTap ? () => widget.onDateTap(date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: isAvailable && !isSelected && !isAbsent
              ? Border.all(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${date.day}',
              style: AppTextStyles.style(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
            ?overlay,
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(
          color: context.primaryColor.withValues(alpha: 0.08),
          borderColor: context.primaryColor.withValues(alpha: 0.3),
          label: 'متاح',
        ),
        _legendItem(color: context.primaryColor, label: 'مختار'),
        _legendItem(
          color: AppColors.warning.withValues(alpha: 0.15),
          label: 'غياب مسجل',
          dotColor: AppColors.warning,
        ),
        _legendItem(
          color: Colors.transparent,
          label: 'غير متاح',
          textColor: context.isDarkMode ? AppColors.grey600 : AppColors.grey300,
        ),
      ],
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    Color? borderColor,
    Color? dotColor,
    Color? textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
          ),
          child: dotColor != null
              ? Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.style(
            fontSize: 11,
            color: textColor ??
                (context.isDarkMode ? AppColors.grey400 : AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
