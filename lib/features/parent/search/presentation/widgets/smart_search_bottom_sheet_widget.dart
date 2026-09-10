import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/child_data_details_screen.dart';

class SmartSearchBottomSheetWidget extends StatefulWidget {
  final List<ChildModel> kids;
  final List<int> initialSelectedKidsIds;
  final String initialTripDirection;
  final String initialSubscriptionType;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function({
    required List<int> selectedKidsIds,
    required String tripDirection,
    required String subscriptionType,
    required DateTime? startDate,
    required DateTime? endDate,
  }) onApply;

  const SmartSearchBottomSheetWidget({
    super.key,
    required this.kids,
    required this.initialSelectedKidsIds,
    this.initialTripDirection = 'both',
    this.initialSubscriptionType = 'single_day',
    this.initialStartDate,
    this.initialEndDate,
    required this.onApply,
  });

  @override
  State<SmartSearchBottomSheetWidget> createState() =>
      _SmartSearchBottomSheetWidgetState();
}

class _SmartSearchBottomSheetWidgetState
    extends State<SmartSearchBottomSheetWidget> {
  late List<int> _selectedKidsIds;
  late String _tripDirection;
  late String _subscriptionType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedKidsIds = List.from(widget.initialSelectedKidsIds);
    _tripDirection = widget.initialTripDirection;
    _subscriptionType = widget.initialSubscriptionType;
    _startDate = widget.initialStartDate ?? DateTime.now();
    _endDate = widget.initialEndDate ?? DateTime.now();
  }

  void _toggleKid(int id) {
    setState(() {
      if (_selectedKidsIds.contains(id)) {
        _selectedKidsIds.remove(id);
      } else {
        _selectedKidsIds.add(id);
      }
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? (_startDate ?? now));
    final firstDate = now.subtract(const Duration(days: 1));
    final lastDate = now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: Theme.of(ctx).primaryColor,
              ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_subscriptionType == 'single_day') {
            _endDate = picked;
          } else if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _openAddChild() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddChildScreen(),
      ),
    );
    if (mounted) {
      context.read<ChildrenCubit>().fetchChildren();
    }
  }

  void _openChildDetails(ChildModel kid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChildrenCubit>(),
          child: ChildDataDetailsScreen(child: kid),
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.grey950 : AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (بدون خط اسود فاصل)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_bus_rounded,
                    color: theme.primaryColor,
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "بحث عن سائق مناسب",
                    style: AppTextStyles.style(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20.r),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 1. اختيار الأطفال ──
                    Text(
                      "1. اختر الأطفال",
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 152.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.kids.length + 1,
                        itemBuilder: (ctx, index) {
                          if (index == 0) {
                            // زر إضافة طفل (+)
                            return InkWell(
                              onTap: _openAddChild,
                              borderRadius: BorderRadius.circular(20.r),
                              child: Container(
                                width: 90.w,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: AppTheme.boxDecoration(
                                  color: isDark
                                      ? AppColors.grey900
                                      : AppColors.grey100,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: theme.primaryColor
                                        .withValues(alpha: 0.3),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add_rounded,
                                        color: theme.primaryColor,
                                        size: 24.r,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      "إضافة طفل",
                                      style: AppTextStyles.style(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final kid = widget.kids[index - 1];
                          final isSelected = _selectedKidsIds.contains(kid.id);

                          return Container(
                            width: 95.w,
                            margin: EdgeInsets.only(left: 10.w),
                            child: InkWell(
                              onTap: () {
                                if (kid.id != null) _toggleKid(kid.id!);
                              },
                              borderRadius: BorderRadius.circular(20.r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.all(8.r),
                                decoration: AppTheme.boxDecoration(
                                  color: isSelected
                                      ? AppColors.secondary.withValues(
                                          alpha: isDark ? 0.25 : 0.15)
                                      : (isDark
                                          ? AppColors.grey900
                                          : AppColors.grey50),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.secondaryDark
                                        : (isDark
                                            ? AppColors.grey800
                                            : AppColors.grey300),
                                    width: isSelected ? 2.w : 1.w,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        CircleAvatar(
                                          radius: 22.r,
                                          backgroundColor: kid.gender == 'male'
                                              ? context.maleBlueBg
                                              : context.femalePinkBg,
                                          backgroundImage: kid.hasRealPhoto
                                              ? CachedNetworkImageProvider(
                                                  kid.photoUrl!)
                                              : null,
                                          child: !kid.hasRealPhoto
                                              ? Icon(
                                                  Icons.person_rounded,
                                                  color: kid.gender == 'male'
                                                      ? context.genderMaleColor
                                                      : context.genderFemaleColor,
                                                  size: 24.r,
                                                )
                                              : null,
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: EdgeInsets.all(2.r),
                                            decoration: const BoxDecoration(
                                              color: AppColors.secondaryDark,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check_rounded,
                                              size: 12.r,
                                              color: AppColors.onSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      kid.name.split(' ')[0],
                                      style: AppTextStyles.style(
                                        fontSize: 12.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4.h),
                                    InkWell(
                                      onTap: () => _openChildDetails(kid),
                                      child: Text(
                                        "التفاصيل",
                                        style: AppTextStyles.style(
                                          fontSize: 10.sp,
                                          color: theme.primaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── 2. اتجاه الرحلة ──
                    Text(
                      "2. اتجاه الرحلة",
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildOptionChip(
                            label: "ذهاب وعودة",
                            isSelected: _tripDirection == 'both',
                            onTap: () => setState(() => _tripDirection = 'both'),
                            theme: theme,
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: _buildOptionChip(
                            label: "ذهاب فقط",
                            isSelected: _tripDirection == 'go',
                            onTap: () => setState(() => _tripDirection = 'go'),
                            theme: theme,
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: _buildOptionChip(
                            label: "عودة فقط",
                            isSelected: _tripDirection == 'return',
                            onTap: () => setState(() => _tripDirection = 'return'),
                            theme: theme,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // ── 3. نوع الاشتراك ──
                    Text(
                      "3. نوع الاشتراك",
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildOptionChip(
                            label: "يومي (يوم واحد)",
                            isSelected: _subscriptionType == 'single_day',
                            onTap: () {
                              setState(() {
                                _subscriptionType = 'single_day';
                                if (_startDate != null) {
                                  _endDate = _startDate;
                                }
                              });
                            },
                            theme: theme,
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildOptionChip(
                            label: "أكثر من يوم",
                            isSelected: _subscriptionType == 'multi_day',
                            onTap: () =>
                                setState(() => _subscriptionType = 'multi_day'),
                            theme: theme,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // ── 4. تاريخ الرحلة / الاشتراك ──
                    Text(
                      "4. تاريخ الرحلة",
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    if (_subscriptionType == 'single_day')
                      // حقل واحد تاريخ اليوم (Pill Shape)
                      InkWell(
                        onTap: () => _pickDate(true),
                        borderRadius: BorderRadius.circular(30.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.grey900 : AppColors.grey100,
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(
                              color: _startDate != null
                                  ? AppColors.secondaryDark
                                  : (isDark
                                      ? AppColors.grey800
                                      : AppColors.grey300),
                              width: _startDate != null ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  color: theme.primaryColor, size: 18.r),
                              SizedBox(width: 12.w),
                              Text(
                                _startDate != null
                                    ? DateFormat('yyyy/MM/dd')
                                        .format(_startDate!)
                                    : "اختر تاريخ اليوم المطلوب...",
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // حقلين: تاريخ البداية والنهاية (Pill Shape)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(true),
                              borderRadius: BorderRadius.circular(30.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.grey900 : AppColors.grey100,
                                  borderRadius: BorderRadius.circular(30.r),
                                  border: Border.all(
                                    color: _startDate != null
                                        ? AppColors.secondaryDark
                                        : (isDark
                                            ? AppColors.grey800
                                            : AppColors.grey300),
                                    width: _startDate != null ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "تاريخ البداية",
                                      style: AppTextStyles.style(
                                          fontSize: 10.sp,
                                          color: AppColors.grey),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      _startDate != null
                                          ? DateFormat('yyyy/MM/dd')
                                              .format(_startDate!)
                                          : "البداية",
                                      style: AppTextStyles.style(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(false),
                              borderRadius: BorderRadius.circular(30.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.grey900 : AppColors.grey100,
                                  borderRadius: BorderRadius.circular(30.r),
                                  border: Border.all(
                                    color: _endDate != null
                                        ? AppColors.secondaryDark
                                        : (isDark
                                            ? AppColors.grey800
                                            : AppColors.grey300),
                                    width: _endDate != null ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "تاريخ النهاية",
                                      style: AppTextStyles.style(
                                          fontSize: 10.sp,
                                          color: AppColors.grey),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      _endDate != null
                                          ? DateFormat('yyyy/MM/dd')
                                              .format(_endDate!)
                                          : "النهاية",
                                      style: AppTextStyles.style(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 20.h),

                    // ── زر الاعتماد النهائي (Pill Shape) ──
                    ElevatedButton(
                      style: AppTheme.elevatedButtonStyle(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      onPressed: () {
                        if (_selectedKidsIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "يرجى اختيار طفل واحد على الأقل قبل البحث.",
                                style: AppTextStyles.style(fontSize: 12.sp),
                              ),
                              backgroundColor: AppColors.orange,
                            ),
                          );
                          return;
                        }

                        widget.onApply(
                          selectedKidsIds: _selectedKidsIds,
                          tripDirection: _tripDirection,
                          subscriptionType: _subscriptionType,
                          startDate: _startDate,
                          endDate: _endDate,
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        "عرض السائقين المناسبين",
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey900 : AppColors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected
                ? AppColors.secondaryDark
                : (isDark ? AppColors.grey800 : AppColors.grey300),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondaryDark.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.style(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.secondaryDark
                      : (isDark ? AppColors.white : AppColors.textDark),
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 4.w),
                Icon(
                  Icons.check_rounded,
                  size: 13.r,
                  color: AppColors.secondaryDark,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
