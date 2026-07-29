import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late DateTime _minMonth;
  late DateTime _maxMonth;

  @override
  void initState() {
    super.initState();
    _initMonthBounds();
  }

  @override
  void didUpdateWidget(covariant AbsenceCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datesModel != widget.datesModel) {
      _initMonthBounds();
    }
  }

  void _initMonthBounds() {
    final allDates = [
      ...widget.datesModel.availableDates,
      ...widget.datesModel.alreadyAbsentDates,
    ];

    if (allDates.isNotEmpty) {
      allDates.sort((a, b) => a.compareTo(b));
      final firstDate = allDates.first;
      final lastDate = allDates.last;

      _minMonth = DateTime(firstDate.year, firstDate.month);
      _maxMonth = DateTime(lastDate.year, lastDate.month);
    } else {
      final now = DateTime.now();
      _minMonth = DateTime(now.year, now.month);
      _maxMonth = DateTime(now.year, now.month);
    }

    _focusedMonth = _minMonth;
  }

  bool _isSameMonth(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month;
  }

  bool get _canGoPrev =>
      !_isSameMonth(_focusedMonth, _minMonth) &&
      _focusedMonth.isAfter(_minMonth);

  bool get _canGoNext =>
      !_isSameMonth(_focusedMonth, _maxMonth) &&
      _focusedMonth.isBefore(_maxMonth);

  bool _isSelected(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return widget.selectedDates.any(
      (s) => DateTime(s.year, s.month, s.day) == d,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.black.withValues(alpha: 0.2)
                : AppColors.darkGradientEnd.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── Header الشهر (الأسهم الدائرية وشريحة الشهر) ─────────────
          _buildMonthHeader(context, isDark),
          SizedBox(height: 18.h),
          // ─── أسماء أيام الأسبوع ────────────────────────────────────
          _buildWeekDaysRow(isDark),
          SizedBox(height: 10.h),
          // ─── Grid الأيام ──────────────────────────────────────────────
          _buildDaysGrid(context, isDark),
          SizedBox(height: 20.h),
          // ─── Legend الحالات (شريط سفلي بإطار خفيف) ────────────────────
          _buildLegend(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context, bool isDark) {
    final monthNames = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final primaryColor = context.primaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // زر السهم الأيمن (في RTL يرجع للشهر السابق)
        _buildNavButton(
          icon: Icons.chevron_right_rounded,
          enabled: _canGoPrev,
          isDark: isDark,
          onTap: () => setState(() {
            _focusedMonth = DateTime(
              _focusedMonth.year,
              _focusedMonth.month - 1,
            );
          }),
        ),

        // شريحة الشهر والسنة (Pill shape)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark
                ? primaryColor.withValues(alpha: 0.15)
                : AppColors.maleBlueBg,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Text(
            '${monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
            style: AppTextStyles.style(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),

        // زر السهم الأيسر (في RTL ينتقل للشهر التالي)
        _buildNavButton(
          icon: Icons.chevron_left_rounded,
          enabled: _canGoNext,
          isDark: isDark,
          onTap: () => setState(() {
            _focusedMonth = DateTime(
              _focusedMonth.year,
              _focusedMonth.month + 1,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool enabled,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(50.r),
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.grey700 : AppColors.grey100,
            width: 1,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20.r,
            color: enabled
                ? (isDark ? AppColors.white : AppColors.textDark)
                : (isDark ? AppColors.grey700 : AppColors.grey300),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDaysRow(bool isDark) {
    const days = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.grey400 : AppColors.textMuted,
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

    // حساب بداية يوم الأسبوع (السبت = 0 في الترتيب العربي)
    final startOffset = (firstDay.weekday + 1) % 7;

    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        final dayNumber = index - startOffset + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date =
            DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
        return _buildDayCell(context, date, isDark);
      },
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date, bool isDark) {
    final isAvailable = widget.datesModel.isAvailable(date);
    final isAbsent = widget.datesModel.isAlreadyAbsent(date);
    final isSelected = _isSelected(date);

    final primaryColor = context.primaryColor;

    Color bgColor;
    Color textColor;
    Border? border;
    Widget? iconOverlay;
    bool canTap = false;
    List<BoxShadow>? shadows;

    if (isSelected) {
      // 1. مختار (أزرق غامق صلب + علامة صح زرقاء دائرية)
      bgColor = primaryColor;
      textColor = AppColors.white;
      canTap = true;
      shadows = [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.35),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
      iconOverlay = Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: 14.r,
          height: 14.r,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 1.5),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 8.r,
            color: AppColors.white,
          ),
        ),
      );
    } else if (isAbsent) {
      // 2. غياب مسجل (دائرة بيضاء + إطار برتقالي + نقطة برتقالية سفلياً)
      bgColor = isDark ? AppColors.darkSurface : AppColors.white;
      textColor = AppColors.orange;
      border = Border.all(color: AppColors.orange, width: 1.5);
      iconOverlay = Positioned(
        bottom: 5.r,
        child: Container(
          width: 4.r,
          height: 4.r,
          decoration: const BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else if (isAvailable) {
      // 3. متاح (دائرة باللون السمائي الفاتح كاملاً AppColors.primarySoft + إطار سمائي)
      bgColor = isDark
          ? primaryColor.withValues(alpha: 0.2)
          : AppColors.primarySoft;
      textColor = isDark ? AppColors.primarySoft : AppColors.primaryLight;
      border = Border.all(
        color: isDark
            ? AppColors.primaryLight.withValues(alpha: 0.6)
            : AppColors.primaryLight.withValues(alpha: 0.4),
        width: 1.2,
      );
      canTap = true;
    } else {
      // 4. غير متاح (دائرة رمادية صلبة + أيقونة قفل رمادية في الزاوية العلوية اليمنى)
      bgColor = isDark ? AppColors.darkSurface : AppColors.grey100;
      textColor = isDark ? AppColors.grey400 : AppColors.grey700;
      border = null;
      iconOverlay = Positioned(
        top: 3.r,
        right: 3.r,
        child: Icon(
          Icons.lock_rounded,
          size: 9.r,
          color: isDark ? AppColors.grey600 : AppColors.grey400,
        ),
      );
    }

    return GestureDetector(
      onTap: canTap ? () => widget.onDateTap(date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: border,
          boxShadow: shadows,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${date.day}',
              style: AppTextStyles.style(
                fontSize: 14.sp,
                fontWeight: (isSelected || isAbsent)
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: textColor,
              ),
            ),
            ?iconOverlay,
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, bool isDark) {
    final primaryColor = context.primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.grey700 : AppColors.grey200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(
            label: 'متاح',
            symbol: Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: isDark
                    ? primaryColor.withValues(alpha: 0.2)
                    : AppColors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryLight,
                  width: 1.2,
                ),
              ),
            ),
            isDark: isDark,
          ),
          _legendItem(
            label: 'مختار',
            symbol: Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            isDark: isDark,
          ),
          _legendItem(
            label: 'غياب مسجل',
            symbol: Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.orange, width: 1.5),
              ),
              child: Center(
                child: Container(
                  width: 3.r,
                  height: 3.r,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            isDark: isDark,
          ),
          _legendItem(
            label: 'غير متاح',
            symbol: Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey600 : AppColors.grey300,
                shape: BoxShape.circle,
              ),
            ),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _legendItem({
    required String label,
    required Widget symbol,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.style(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.grey300 : AppColors.textDark,
          ),
        ),
        SizedBox(width: 6.w),
        symbol,
      ],
    );
  }
}
