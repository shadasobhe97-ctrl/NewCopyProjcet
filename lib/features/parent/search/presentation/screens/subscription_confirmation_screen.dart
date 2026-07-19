import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/search/logic/search_cubit.dart';
import 'package:kids_transport/features/parent/search/logic/search_state.dart';
import 'package:kids_transport/features/parent/search/data/models/subscription_request.dart';

class SubscriptionConfirmationScreen extends StatefulWidget {
  final DriverSearchModel driver;
  final List<ChildModel> selectedKids;

  const SubscriptionConfirmationScreen({
    super.key,
    required this.driver,
    required this.selectedKids,
  });

  @override
  State<SubscriptionConfirmationScreen> createState() => _SubscriptionConfirmationScreenState();
}

class _SubscriptionConfirmationScreenState extends State<SubscriptionConfirmationScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPricing();
  }

  void _fetchPricing() {
    setState(() {
      _isLoading = false;
      _hasError = false;
      _errorMessage = null;

      // Check if any of the selected kids has an error in the driver's breakdown
      for (final kid in widget.selectedKids) {
        final breakdownItem = widget.driver.breakdown.firstWhere(
          (b) => b.childId == kid.id,
          orElse: () => BreakdownModelInfo(
            childId: kid.id ?? 0,
            childName: kid.name,
            schoolName: kid.schoolName,
            distanceKm: 0.0,
            pricePerKm: 0.0,
            subscriptionType: kid.transportPref.subscriptionType,
            workingDays: 22,
            childPrice: widget.driver.price,
            childPriceRaw: widget.driver.price.toInt(),
          ),
        );
        if (breakdownItem.error != null && breakdownItem.error!.isNotEmpty) {
          _hasError = true;
          _errorMessage = breakdownItem.error;
          break;
        }
      }
    });
  }

  double _priceForKid(ChildModel kid) {
    try {
      final breakdownItem = widget.driver.breakdown.firstWhere(
        (b) => b.childId == kid.id,
      );
      return breakdownItem.childPrice;
    } catch (_) {}
    try {
      final t = kid.transportPref.subscriptionType.toLowerCase();
      if (t == 'weekly') return widget.driver.price * 0.3;
      if (t == 'days') return widget.driver.price * 0.1;
    } catch (_) {}
    return widget.driver.price;
  }

  String _labelForKid(ChildModel kid) {
    try {
      final breakdownItem = widget.driver.breakdown.firstWhere(
        (b) => b.childId == kid.id,
      );
      final t = breakdownItem.subscriptionType.toLowerCase();
      if (t == 'weekly') return 'أسبوعي';
      if (t == 'days') return 'يومي';
    } catch (_) {}
    try {
      final t = kid.transportPref.subscriptionType.toLowerCase();
      if (t == 'weekly') return 'أسبوعي';
      if (t == 'days') return 'يومي';
    } catch (_) {}
    return 'شهري';
  }

  double get _totalPrice =>
      widget.selectedKids.fold(0.0, (sum, k) => sum + _priceForKid(k));

  void _confirmAndSend() {
    if (widget.selectedKids.isEmpty) return;

    debugPrint('\n================= SUBMIT SUBSCRIPTION =================');
    final primaryKid = widget.selectedKids.first;

    debugPrint('>>> Raw values before building JSON:');
    debugPrint('driver_id          = ${widget.driver.driverId}');
    debugPrint('school_id          = ${primaryKid.schoolId}');
    debugPrint('subscription_type  = ${primaryKid.transportPref.subscriptionType}');
    debugPrint('start_date         = ${primaryKid.transportPref.startDate.toIso8601String().split('T').first}');
    debugPrint('end_date           = ${primaryKid.transportPref.endDate?.toIso8601String().split('T').first}');

    // Get timing format
    String timingVal = 'BOTH';
    final p = primaryKid.transportPref.period.toLowerCase();
    if (p == 'morning') timingVal = 'MORNING';
    if (p == 'evening' || p == 'afternoon') timingVal = 'EVENING';
    debugPrint('timing (raw period) = ${primaryKid.transportPref.period} → $timingVal');

    // Get direction format — serviceType already stores go/return/both
    String directionVal = primaryKid.transportPref.serviceType.toLowerCase();
    debugPrint('direction (raw svc) = ${primaryKid.transportPref.serviceType} → $directionVal');

    final List<SubscriptionChildRequest> childrenRequestList = [];
    debugPrint('\n>>> Children breakdown:');
    for (final kid in widget.selectedKids) {
      final breakdownItem = widget.driver.breakdown.firstWhere(
        (b) => b.childId == kid.id,
        orElse: () => BreakdownModelInfo(
          childId: kid.id ?? 0,
          childName: kid.name,
          schoolName: kid.schoolName,
          distanceKm: 0.0,
          pricePerKm: 0.0,
          subscriptionType: kid.transportPref.subscriptionType,
          workingDays: 22,
          childPrice: widget.driver.price,
          childPriceRaw: widget.driver.price.toInt(),
        ),
      );

      debugPrint('  child_id            = ${kid.id}');
      debugPrint('  pickup_address_id   = ${kid.addressId} (type: ${kid.addressId.runtimeType})');
      debugPrint('  dropoff_address_id  = ${kid.addressId} (type: ${kid.addressId.runtimeType})');
      debugPrint('  price_per_child     = ${breakdownItem.childPrice} (type: ${breakdownItem.childPrice.runtimeType})');
      debugPrint('  child_notes         = ${kid.medicalNotes ?? ''}');
      debugPrint('  ---');

      childrenRequestList.add(
        SubscriptionChildRequest(
          childId: kid.id ?? 0,
          pickupAddressId: kid.addressId,
          dropoffAddressId: kid.addressId,
          pricePerChild: breakdownItem.childPrice,
          childNotes: kid.medicalNotes ?? '',
        ),
      );
    }

    final daysCount = widget.driver.breakdown.isNotEmpty 
        ? widget.driver.breakdown.first.workingDays 
        : 22;
    debugPrint('days_count          = $daysCount');
    debugPrint('notes               = ""');

    // Map subscription_type to backend contract: monthly|daily
    String mappedSubscriptionType = primaryKid.transportPref.subscriptionType.toLowerCase();
    if (mappedSubscriptionType == 'days') mappedSubscriptionType = 'daily';
    if (mappedSubscriptionType == 'weekly') mappedSubscriptionType = 'monthly';

    final request = SubscriptionRequest(
      driverId: widget.driver.driverId,
      schoolId: primaryKid.schoolId,
      subscriptionType: mappedSubscriptionType,
      direction: directionVal,
      timing: timingVal,
      startDate: primaryKid.transportPref.startDate.toIso8601String().split('T').first,
      endDate: primaryKid.transportPref.endDate?.toIso8601String().split('T').first,
      daysCount: daysCount,
      notes: '',
      children: childrenRequestList,
    );

    debugPrint('\n>>> Final JSON being sent:');
    debugPrint(request.toJson().toString());
    debugPrint('========================================================\n');

    context.read<SearchCubit>().submitSubscription(request);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<SearchCubit, SearchState>(
        listener: (context, state) {
          if (state is SubscriptionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    state.message,
                    style: AppTextStyles.style(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                duration: const Duration(seconds: 4),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    state.errorMessage,
                    style: AppTextStyles.style(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is SubscriptionLoading;

          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: Text(
                'تأكيد الاشتراك والسعر',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
              foregroundColor: isDark ? AppColors.white : AppColors.textDark,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          // 1. بيانات الكابتن
                          _buildDriverCard(theme, isDark),
                          SizedBox(height: 16.h),

                          // 2. تفاصيل التسعير
                          _buildPricingCard(theme, isDark),
                          SizedBox(height: 16.h),

                          // 3. تنبيه إرشادي
                          _buildInfoCard(theme, isDark),
                        ],
                      ),
                    ),
                  ),
                  
                  // 4. أزرار التحكم السفلية (تأكيد أو إلغاء)
                  _buildActionsBar(theme, isDark, isSubmitting),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDriverCard(ThemeData theme, bool isDark) {
    final isFemale = widget.driver.gender == 'FEMALE';
    final avatarColor = isFemale ? AppColors.femalePink : theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor.withValues(alpha: 0.12),
              border: Border.all(color: avatarColor.withValues(alpha: 0.3), width: 1.5.w),
            ),
            child: Icon(
              isFemale ? Icons.face_4_rounded : Icons.person_rounded,
              size: 32.r,
              color: avatarColor,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.driver.fullName,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      widget.driver.vehicleType,
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(width: 4.w, height: 4.h, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppColors.grey700 : AppColors.grey300)),
                    SizedBox(width: 8.w),
                    Icon(Icons.star_rounded, color: AppColors.amber, size: 14.r),
                    SizedBox(width: 2.w),
                    Text(
                      widget.driver.rating.toStringAsFixed(1),
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.grey200 : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary, size: 18.r),
                ),
                SizedBox(width: 10.w),
                Text(
                  'تفاصيل التسعير',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? AppColors.grey800 : AppColors.grey100, height: 1.h),
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: _isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3.w,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'جاري الاتصال بالسيرفر وجلب التسعير الحقيقي...',
                            style: AppTextStyles.style(
                              fontSize: 12.sp,
                              color: isDark ? AppColors.grey400 : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _hasError
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18.r),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    _errorMessage ?? 'حدث خطأ أثناء جلب التسعير.',
                                    style: AppTextStyles.style(
                                      fontSize: 13.sp,
                                      color: AppColors.error,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            TextButton.icon(
                              onPressed: _fetchPricing,
                              icon: Icon(Icons.refresh_rounded, size: 16.r),
                              label: Text(
                                'إعادة المحاولة',
                                style: AppTextStyles.style(fontSize: 12.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'السعر الإجمالي',
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                '${_totalPrice.toStringAsFixed(2)} د.ل',
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Divider(color: isDark ? AppColors.grey800 : AppColors.grey100, height: 1.h),
                          SizedBox(height: 12.h),
                          Text(
                            'تفصيل السعر لكل طفل:',
                            style: AppTextStyles.style(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.grey400 : AppColors.grey600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ...widget.selectedKids.map((kid) {
                            final price = _priceForKid(kid);
                            final label = _labelForKid(kid);
                            final isMale = kid.gender.toLowerCase() == 'male';

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isMale ? Icons.face_rounded : Icons.face_4_rounded,
                                        size: 16.r,
                                        color: isMale ? theme.colorScheme.primary : AppColors.femalePink,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '${kid.name} ($label)',
                                        style: AppTextStyles.style(
                                          fontSize: 13.sp,
                                          color: isDark ? AppColors.grey200 : AppColors.grey800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${price.toStringAsFixed(2)} د.ل',
                                    style: AppTextStyles.style(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp,
                                      color: isDark ? AppColors.white : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'يمكنك إرسال طلب اشتراك لأكثر من سائق في نفس الوقت. بمجرد قبول أحد السائقين لطلبك، سيتم إلغاء بقية الطلبات تلقائيًا تفاديًا للازدواجية.',
              style: AppTextStyles.style(
                fontSize: 12.sp,
                color: isDark ? AppColors.grey300 : AppColors.grey800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsBar(ThemeData theme, bool isDark, bool isSubmitting) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.grey800 : AppColors.grey200, width: 0.5.w)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: OutlinedButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? AppColors.grey700 : AppColors.grey300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'إلغاء',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: isDark ? AppColors.grey300 : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed: (isSubmitting || _isLoading || _hasError) ? null : _confirmAndSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor: isDark ? AppColors.grey800 : AppColors.grey200,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        'تأكيد وإرسال الطلب',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
