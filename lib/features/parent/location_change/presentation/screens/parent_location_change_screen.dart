import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/di/dependency_injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/location_change_available_trips_model.dart';
import '../../data/models/location_change_options_model.dart';
import '../../logic/cubit/location_change_cubit.dart';
import 'location_change_history_screen.dart';
import 'package:kids_transport/features/parent/addresses/presentation/widgets/add_address_sheet.dart';

class ParentLocationChangeScreen extends StatefulWidget {
  const ParentLocationChangeScreen({super.key});

  @override
  State<ParentLocationChangeScreen> createState() =>
      _ParentLocationChangeScreenState();
}

class _ParentLocationChangeScreenState
    extends State<ParentLocationChangeScreen> {
  late LocationChangeCubit _cubit;
  int _locationTab = 0; // 0: Saved Addresses, 1: Map Picker

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LocationChangeCubit>()..fetchOptions();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () {
                final state = _cubit.state;
                if (state is LocationChangeOptionsLoaded && state.currentStep > 1) {
                  _cubit.backStep();
                } else {
                  Navigator.maybePop(context);
                }
              },
            ),
            title: Text(
              'طلب تغيير موقع مؤقت',
              style: AppTextStyles.style(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'سجل الطلبات',
                icon: Icon(
                  Icons.history_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 24.sp,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationChangeHistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: BlocConsumer<LocationChangeCubit, LocationChangeState>(
            listener: (context, state) {
              if (state is LocationChangeOptionsLoaded) {
                if (state.submitSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              state.submitMessage ?? 'تم إرسال الطلب بنجاح',
                              style: AppTextStyles.style(fontSize: 13.sp, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationChangeHistoryScreen(),
                    ),
                  );
                } else if (state.error != null && state.error!.isNotEmpty) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.white),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: AppTextStyles.style(fontSize: 13.sp, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: context.errorColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  );
                  _cubit.clearError();
                }
              }
            },
            builder: (context, state) {
              if (state is LocationChangeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LocationChangeError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 54.sp, color: context.errorColor),
                        SizedBox(height: 14.h),
                        Text(
                          state.message,
                          style: AppTextStyles.style(
                              fontSize: 14.sp, color: context.textMuted),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton.icon(
                          onPressed: () => _cubit.fetchOptions(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('إعادة المحاولة'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is LocationChangeOptionsLoaded) {
                return Column(
                  children: [
                    // ── Wizard Step Indicator ──
                    _buildStepIndicator(context, state.currentStep, isDark),

                    // ── Active Step Body ──
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: _buildCurrentStepView(context, state, isDark),
                      ),
                    ),

                    // ── Bottom Navigation Action Bar ──
                    _buildBottomActionBar(context, state, isDark),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // ── Step Indicator Bar ──
  Widget _buildStepIndicator(BuildContext context, int currentStep, bool isDark) {
    final steps = [
      {'number': 1, 'title': 'من ومتى؟'},
      {'number': 2, 'title': 'الرحلة والموقع'},
      {'number': 3, 'title': 'المعاينة والتأكيد'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final prevStepNum = (index ~/ 2) + 1;
            final isCompleted = currentStep > prevStepNum;
            return Expanded(
              child: Container(
                height: 3.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Theme.of(context).primaryColor
                      : (isDark ? AppColors.grey800 : AppColors.grey300),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final stepNum = steps[stepIndex]['number'] as int;
          final stepTitle = steps[stepIndex]['title'] as String;
          final isActive = currentStep == stepNum;
          final isDone = currentStep > stepNum;

          return InkWell(
            onTap: () {
              if (stepNum < currentStep) {
                _cubit.goToStep(stepNum);
              }
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Row(
              children: [
                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? Colors.green
                        : (isActive
                            ? Theme.of(context).primaryColor
                            : (isDark ? AppColors.grey800 : AppColors.grey200)),
                  ),
                  child: Center(
                    child: isDone
                        ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
                        : Text(
                            '$stepNum',
                            style: AppTextStyles.style(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : context.textMuted,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  stepTitle,
                  style: AppTextStyles.style(
                    fontSize: 11.5.sp,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? Theme.of(context).primaryColor : context.textMuted,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Render Active Step Content ──
  Widget _buildCurrentStepView(
    BuildContext context,
    LocationChangeOptionsLoaded state,
    bool isDark,
  ) {
    switch (state.currentStep) {
      case 1:
        return _buildStep1ChildrenAndDate(context, state, isDark);
      case 2:
        return _buildStep2TripsAndLocation(context, state, isDark);
      case 3:
        return _buildStep3PreviewAndFinancials(context, state, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ── STEP 1: من ومتى؟ (اختيار الأطفال والتاريخ) ──────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildStep1ChildrenAndDate(
    BuildContext context,
    LocationChangeOptionsLoaded state,
    bool isDark,
  ) {
    final children = state.options.children;
    final selectedIds = state.selectedChildIds;

    // Detect if multiple selected children share the same driver
    final selectedChildren = children.where((c) => selectedIds.contains(c.id)).toList();
    final driverMap = <String, List<String>>{};
    for (final c in selectedChildren) {
      final dName = c.driverName ?? (c.driverId != null ? 'السائق #${c.driverId}' : null);
      if (dName != null && dName.isNotEmpty) {
        driverMap.putIfAbsent(dName, () => []).add(c.name);
      }
    }
    final sharedDrivers = driverMap.entries.where((e) => e.value.length > 1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card: Instructions Banner
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).primaryColor,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'طلب التغيير مؤقت ليوم محدد فقط، ولن يؤثر على عنوان الاشتراك الدائم الأصلي. يتم تجميع الأطفال الذين يشتركون في نفس السائق تلقائياً برسم انحراف واحد.',
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    color: context.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Shared Driver Friendly Badge
        if (sharedDrivers.isNotEmpty) ...[
          ...sharedDrivers.map((entry) {
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars_rounded, color: Colors.green.shade700, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'نفس السائق (${entry.key}) — سيتم دمج (${entry.value.join('، ')}) في طلب واحد برسم انحراف واحد 🎯',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // ── Children Selection Card ──
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? context.cardSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.grey800 : AppColors.grey200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.escalator_warning_rounded,
                          color: Theme.of(context).primaryColor, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'اختيار الأطفال',
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      final activeCount = children.where((c) => c.hasActiveSubscription).length;
                      final allSelected = activeCount > 0 && selectedIds.length == activeCount;
                      _cubit.selectAllChildren(!allSelected);
                    },
                    child: Text(
                      selectedIds.length == children.where((c) => c.hasActiveSubscription).length
                          ? 'إلغاء التحديد'
                          : 'تحديد المشتركين',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              if (children.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'لا يوجد أطفال مسجلون في حسابك حالياً',
                      style: AppTextStyles.style(
                        fontSize: 13.sp,
                        color: context.textMuted,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 148.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: children.length,
                    separatorBuilder: (_, _) => SizedBox(width: 14.w),
                    itemBuilder: (context, index) {
                      final child = children[index];
                      final isSelected = selectedIds.contains(child.id);
                      final hasSub = child.hasActiveSubscription;

                      return InkWell(
                        onTap: () {
                          if (!hasSub) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'لا يمكن تعديل الموقع للطفل (${child.name}) لعدم وجود اشتراك نشط له.',
                                ),
                                backgroundColor: Colors.orange.shade800,
                              ),
                            );
                            return;
                          }
                          _cubit.toggleChildSelection(child.id);
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: hasSub ? 1.0 : 0.45,
                          child: Container(
                            width: 105.w,
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                                  : (isDark ? AppColors.grey900 : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : (isDark ? AppColors.grey800 : AppColors.grey300),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 26.r,
                                      backgroundColor: isSelected
                                          ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                                          : (isDark ? AppColors.grey800 : AppColors.grey200),
                                      backgroundImage: (child.photoUrl != null &&
                                              child.photoUrl!.isNotEmpty &&
                                              AppUserAvatar.resolveUrl(child.photoUrl) != null)
                                          ? CachedNetworkImageProvider(
                                              AppUserAvatar.resolveUrl(child.photoUrl)!,
                                              headers: AppUserAvatar.imageHeaders,
                                            )
                                          : null,
                                      child: (child.photoUrl == null || child.photoUrl!.isEmpty)
                                          ? Text(
                                              child.name.isNotEmpty
                                                  ? child.name.characters.first
                                                  : 'ط',
                                              style: AppTextStyles.style(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Theme.of(context).primaryColor
                                                    : context.textPrimary,
                                              ),
                                            )
                                          : null,
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        bottom: -2,
                                        left: -2,
                                        child: Container(
                                          padding: EdgeInsets.all(3.r),
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 13.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    if (!hasSub)
                                      Positioned(
                                        bottom: -2,
                                        left: -2,
                                        child: Container(
                                          padding: EdgeInsets.all(3.r),
                                          decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.lock_rounded,
                                            size: 13.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  child.name,
                                  style: AppTextStyles.style(
                                    fontSize: 12.sp,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.h),
                                if (!hasSub)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'غير مشترك',
                                      style: AppTextStyles.style(
                                        fontSize: 9.sp,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  )
                                else if (child.driverName != null)
                                  Text(
                                    '🚗 ${child.driverName}',
                                    style: AppTextStyles.style(
                                      fontSize: 10.sp,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Date Picker Card ──
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? context.cardSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.grey800 : AppColors.grey200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      color: Theme.of(context).primaryColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'تاريخ التغيير المطلوب',
                    style: AppTextStyles.style(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Quick Date Chips
              Wrap(
                spacing: 10.w,
                runSpacing: 8.h,
                children: [
                  _buildQuickDateChip(
                    context: context,
                    label: 'اليوم',
                    targetDate: DateTime.now(),
                    currentDate: state.changeDate,
                  ),
                  _buildQuickDateChip(
                    context: context,
                    label: 'غداً',
                    targetDate: DateTime.now().add(const Duration(days: 1)),
                    currentDate: state.changeDate,
                  ),
                  ActionChip(
                    avatar: Icon(Icons.edit_calendar_rounded,
                        size: 16.sp, color: Theme.of(context).primaryColor),
                    label: Text(
                      'تاريخ آخر...',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    onPressed: () async {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      DateTime initial = state.changeDate;
                      if (initial.isBefore(today)) {
                        initial = today;
                      }

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: today,
                        lastDate: today.add(const Duration(days: 30)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Theme.of(context).primaryColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        _cubit.setChangeDate(picked);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey900 : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_available_rounded,
                        color: Theme.of(context).primaryColor, size: 20.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'التاريخ المحدد: ${_cubit.state is LocationChangeOptionsLoaded ? "${state.changeDate.year}-${state.changeDate.month.toString().padLeft(2, '0')}-${state.changeDate.day.toString().padLeft(2, '0')}" : ""}',
                      style: AppTextStyles.style(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickDateChip({
    required BuildContext context,
    required String label,
    required DateTime targetDate,
    required DateTime currentDate,
  }) {
    final isSelected = targetDate.year == currentDate.year &&
        targetDate.month == currentDate.month &&
        targetDate.day == currentDate.day;

    return ChoiceChip(
      label: Text(
        '$label (${targetDate.day}/${targetDate.month})',
        style: AppTextStyles.style(
          fontSize: 12.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : context.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor,
      onSelected: (selected) {
        if (selected) {
          _cubit.setChangeDate(targetDate);
        }
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ── STEP 2: أي رحلة وأي موقع؟ (تحديد الاتجاه والموقع الجديد) ─────────────────
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildStep2TripsAndLocation(
    BuildContext context,
    LocationChangeOptionsLoaded state,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Point Type Toggle ──
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? context.cardSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.grey800 : AppColors.grey200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نوع النقطة والاتجاه المراد تعديله',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildPointTypeOption(
                      context,
                      icon: Icons.home_rounded,
                      title: 'موقع الاستلام (الصباح)',
                      subtitle: 'pickup (الانطلاق للمدرسة)',
                      type: 'pickup',
                      isSelected: state.pointType == 'pickup',
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildPointTypeOption(
                      context,
                      icon: Icons.location_on_rounded,
                      title: 'موقع التسليم (العودة)',
                      subtitle: 'dropoff (الرجوع للمنزل)',
                      type: 'dropoff',
                      isSelected: state.pointType == 'dropoff',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Trips Checkboxes Card ──
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? context.cardSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.grey800 : AppColors.grey200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الرحلات المشمولة بالتغيير',
                    style: AppTextStyles.style(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  if (state.isAvailableTripsLoading)
                    SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              SizedBox(height: 12.h),

              if (state.availableTrips.isEmpty && !state.isAvailableTripsLoading)
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'لا توجد رحلات مجدولة لهؤلاء الأطفال في هذا التاريخ.',
                          style: AppTextStyles.style(
                            fontSize: 12.sp,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...state.selectedChildIds.map((childId) {
                  final childTrips = state.availableTrips.firstWhere(
                    (t) => t.childId == childId,
                    orElse: () {
                      final c = state.options.children.firstWhere(
                        (ch) => ch.id == childId,
                        orElse: () => ChildOptionModel(id: childId, name: 'طفل'),
                      );
                      return ChildAvailableTripsModel(childId: childId, childName: c.name, availableTrips: []);
                    },
                  );

                  final selectedTripsForChild = state.selectedTripIdsForChild[childId] ?? {};

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey900 : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark ? AppColors.grey800 : AppColors.grey200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12.r,
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                              child: Icon(Icons.person, size: 14.r, color: Theme.of(context).primaryColor),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              childTrips.childName,
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),

                        if (childTrips.availableTrips.isEmpty)
                          Text(
                            'لا توجد رحلات لهذا الطفل في التاريخ المحدد',
                            style: AppTextStyles.style(fontSize: 11.5.sp, color: AppColors.textMuted),
                          )
                        else
                          ...childTrips.availableTrips.map((trip) {
                            final tripId = trip.activeSubscriptionId > 0 ? trip.activeSubscriptionId : trip.tripId;
                            final isChecked = selectedTripsForChild.contains(tripId);
                            final isEditable = trip.isEditable;
                            final dirLabel = trip.direction == 'to_school'
                                ? 'رحلة الذهاب (إلى المدرسة)'
                                : 'رحلة العودة (إلى المنزل)';

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4.h),
                              decoration: BoxDecoration(
                                color: isEditable
                                    ? (isChecked
                                        ? Theme.of(context).primaryColor.withValues(alpha: 0.06)
                                        : Colors.transparent)
                                    : Colors.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isEditable
                                      ? (isChecked ? Theme.of(context).primaryColor : AppColors.grey300)
                                      : Colors.grey.shade400,
                                ),
                              ),
                              child: CheckboxListTile(
                                value: isEditable ? isChecked : false,
                                enabled: isEditable,
                                dense: true,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (val) {
                                  _cubit.toggleTripSelectionForChild(childId, tripId);
                                },
                                title: Text(
                                  dirLabel,
                                  style: AppTextStyles.style(
                                    fontSize: 12.sp,
                                    fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                    color: isEditable ? context.textPrimary : Colors.grey,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'السائق: ${trip.driverName}',
                                      style: AppTextStyles.style(
                                        fontSize: 10.5.sp,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    if (!isEditable)
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.h),
                                        child: Text(
                                          trip.blockReason ?? 'الرحلة نُفّذت بالفعل ولا يمكن تعديل موقعها',
                                          style: AppTextStyles.style(
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── New Location Selection (Saved Addresses vs Map Picker) ──
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? context.cardSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.grey800 : AppColors.grey200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختيار الموقع الجديد',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              // Segmented Tabs: Saved Addresses vs Map Picker
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey900 : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() => _locationTab = 0);
                          final state = _cubit.state;
                          if (state is LocationChangeOptionsLoaded) {
                            if (state.selectedAddress == null && state.options.addresses.isNotEmpty) {
                              _cubit.selectAddress(state.options.addresses.first);
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _locationTab == 0
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'عناويني المحفوظة',
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: _locationTab == 0 ? Colors.white : context.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _locationTab = 1),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _locationTab == 1
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'تحديد على الخريطة',
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: _locationTab == 1 ? Colors.white : context.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              if (_locationTab == 0) ...[
                // Saved Addresses Tab
                if (state.options.addresses.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        'لا توجد عناوين محفوظة في حسابك',
                        style: AppTextStyles.style(fontSize: 12.sp, color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  ...state.options.addresses.map((addr) {
                    final isSelected = state.selectedAddress?.id == addr.id;
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : AppColors.grey300,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _cubit.selectAddress(addr),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? Theme.of(context).primaryColor : AppColors.grey400,
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  addr.label,
                                  style: AppTextStyles.style(
                                    fontSize: 12.5.sp,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.location_on_rounded,
                                color: isSelected ? Theme.of(context).primaryColor : AppColors.grey400,
                                size: 20.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => AddAddressSheet(
                        onSave: (newAddr) async {
                          final messenger = ScaffoldMessenger.of(context);
                          final error = await _cubit.saveNewAddressAndSelect(newAddr);
                          if (error == null && mounted) {
                            setState(() {
                              _locationTab = 0;
                            });
                            messenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        'تم حفظ العنوان واختياره بنجاح (${newAddr.title})',
                                        style: AppTextStyles.style(fontSize: 12.5.sp, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                            );
                          }
                          return error;
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: const Text('إضافة عنوان جديد'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ] else ...[
                // Custom Map Location Tab
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: state.customLat != null
                        ? Colors.green.withValues(alpha: isDark ? 0.12 : 0.05)
                        : (isDark ? AppColors.grey900 : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: state.customLat != null
                          ? Colors.green.shade600
                          : (isDark ? AppColors.grey800 : AppColors.grey300),
                      width: state.customLat != null ? 1.8 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: state.customLat != null
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              state.customLat != null
                                  ? Icons.check_circle_rounded
                                  : Icons.map_rounded,
                              color: state.customLat != null
                                  ? Colors.green.shade700
                                  : Theme.of(context).primaryColor,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.customLat != null
                                            ? (state.customLabel ?? 'موقع مخصص على الخريطة')
                                            : 'لم يتم تحديد موقع على الخريطة بعد',
                                        style: AppTextStyles.style(
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (state.customLat != null)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          'الموقع المختار ✓',
                                          style: AppTextStyles.style(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  state.customLat != null
                                      ? 'الإحداثيات: ${state.customLat!.toStringAsFixed(4)}, ${state.customLng!.toStringAsFixed(4)}'
                                      : 'اضغط على الزر أدناه لاختيار الموقع المطلوب من الخريطة',
                                  style: AppTextStyles.style(
                                    fontSize: 11.sp,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => AddAddressSheet(
                                onSave: (newAddr) async {
                                  _cubit.setCustomLocation(
                                    newAddr.latitude,
                                    newAddr.longitude,
                                    newAddr.title,
                                  );
                                  if (mounted) {
                                    setState(() {
                                      _locationTab = 1;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                'تم تحديد الموقع على الخريطة بنجاح (${newAddr.title})',
                                                style: AppTextStyles.style(fontSize: 12.5.sp, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.green.shade700,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            );
                          },
                          icon: Icon(
                            state.customLat != null ? Icons.edit_location_alt_rounded : Icons.pin_drop_rounded,
                            size: 18.sp,
                          ),
                          label: Text(
                            state.customLat != null ? 'تغيير الموقع من الخريطة' : 'تحديد الموقع على الخريطة',
                            style: AppTextStyles.style(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.customLat != null
                                ? Colors.green.shade700
                                : Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPointTypeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String type,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _cubit.setPointType(type),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : AppColors.grey400,
              size: 26.sp,
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              style: AppTextStyles.style(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).primaryColor : context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: AppTextStyles.style(
                fontSize: 9.5.sp,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ── STEP 3: شاشة المعاينة والشفافية المالية (POST /preview ثم POST /) ────────
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildStep3PreviewAndFinancials(
    BuildContext context,
    LocationChangeOptionsLoaded state,
    bool isDark,
  ) {
    final preview = state.previewData;

    if (preview == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text(
                'جاري حساب التكلفة والمسافات...',
                style: AppTextStyles.style(fontSize: 13.sp, color: context.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final isWalletDeficit = (preview.walletAfter ?? 0.0) < 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reassurance Note
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.blue.shade700, size: 22.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  '💡 لن يتم خصم أي مبالغ من محفظتك إلا بعد موافقة السائق على طلب التغيير.',
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Grouped Requests By Driver Cards
        Text(
          'الطلبات المقسمة حسب السائقين:',
          style: AppTextStyles.style(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),

        ...preview.groupedRequests.map((group) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isDark ? context.cardSurface : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                        CircleAvatar(
                          radius: 16.r,
                          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                          child: Icon(Icons.directions_bus_rounded,
                              size: 18.r, color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'الكابتن: ${group.driverName}',
                          style: AppTextStyles.style(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${group.feeAmount} ${preview.currency}',
                      style: AppTextStyles.style(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                const Divider(height: 1),
                SizedBox(height: 10.h),

                // Children Chips
                Row(
                  children: [
                    Text(
                      'الأطفال المشمولون: ',
                      style: AppTextStyles.style(fontSize: 11.sp, color: AppColors.textMuted),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 6.w,
                        children: group.children.map((ch) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.grey800 : AppColors.grey100,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              ch.name,
                              style: AppTextStyles.style(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Distance & Tier Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.straighten_rounded, size: 16.sp, color: AppColors.textMuted),
                        SizedBox(width: 4.w),
                        Text(
                          'المسافة المقدرة: ${group.extraDistanceKm.toStringAsFixed(1)} كم',
                          style: AppTextStyles.style(fontSize: 11.5.sp, color: context.textPrimary),
                        ),
                      ],
                    ),
                    if (group.feeTierLabel != null && group.feeTierLabel!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          group.feeTierLabel!,
                          style: AppTextStyles.style(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 16.h),

        // ── Wallet Summary Card ──
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? context.cardSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.grey800 : AppColors.grey200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: Theme.of(context).primaryColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'ملخص المحفظة والتكلفة',
                    style: AppTextStyles.style(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              _buildSummaryRow(
                context,
                label: 'إجمالي الرسوم المطلوبة:',
                value: '${preview.totalFee} ${preview.currency}',
                isBold: true,
                valueColor: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 8.h),
              _buildSummaryRow(
                context,
                label: 'رصيد محفظتك الحالي:',
                value: '${preview.walletBalance?.toStringAsFixed(2) ?? "0.00"} ${preview.currency}',
              ),
              SizedBox(height: 8.h),
              _buildSummaryRow(
                context,
                label: 'الرصيد المتبقي بعد الموافقة:',
                value: '${preview.walletAfter?.toStringAsFixed(2) ?? "0.00"} ${preview.currency}',
                valueColor: isWalletDeficit ? Colors.red : Colors.green.shade700,
                isBold: true,
              ),

              if (isWalletDeficit) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'تنبيه: رصيد المحفظة غير كافٍ. سيتم تسجيل الرسوم كمستحق على حسابك عند موافقة السائق، يُرجى شحن محفظتك لتجنب تأثر الخدمة.',
                          style: AppTextStyles.style(
                            fontSize: 11.sp,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.style(
            fontSize: 12.5.sp,
            color: isBold ? context.textPrimary : AppColors.textMuted,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.style(
            fontSize: 13.5.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? context.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ── Bottom Action Navigation Bar ─────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBottomActionBar(
    BuildContext context,
    LocationChangeOptionsLoaded state,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (state.currentStep > 1) ...[
              OutlinedButton.icon(
                onPressed: state.isSubmitting || state.isPreviewLoading
                    ? null
                    : () => _cubit.backStep(),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                label: const Text('السابق'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(width: 10.w),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: _getBottomActionCallback(state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _getBottomActionButtonContent(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? _getBottomActionCallback(LocationChangeOptionsLoaded state) {
    if (state.isSubmitting || state.isPreviewLoading) return null;

    if (state.currentStep == 1) {
      return state.selectedChildIds.isEmpty ? null : () => _cubit.proceedToStep2();
    } else if (state.currentStep == 2) {
      final hasAddress = _locationTab == 0
          ? state.selectedAddress != null
          : (state.customLat != null && state.customLng != null);
      return !hasAddress ? null : () => _cubit.proceedToStep3();
    } else {
      return () => _cubit.submitRequests();
    }
  }

  Widget _getBottomActionButtonContent(LocationChangeOptionsLoaded state) {
    if (state.isSubmitting) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    if (state.isPreviewLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
          SizedBox(width: 8.w),
          Text(
            'جاري المعاينة...',
            style: AppTextStyles.style(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    if (state.currentStep == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'متابعة للرحلات والموقع',
            style: AppTextStyles.style(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6.w),
          const Icon(Icons.arrow_back_ios_rounded, size: 14, color: Colors.white),
        ],
      );
    } else if (state.currentStep == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'معاينة التكلفة المالية',
            style: AppTextStyles.style(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6.w),
          const Icon(Icons.arrow_back_ios_rounded, size: 14, color: Colors.white),
        ],
      );
    } else {
      return Text(
        'تأكيد وإرسال الطلب للسائقين 🚀',
        style: AppTextStyles.style(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }
  }
}
