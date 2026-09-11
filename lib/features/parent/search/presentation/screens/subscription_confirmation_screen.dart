import 'package:flutter/material.dart';
import 'package:kids_transport/core/utils/subscription_enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/search/logic/search_cubit.dart';
import 'package:kids_transport/features/parent/search/logic/search_state.dart';
import 'package:kids_transport/features/parent/search/data/models/subscription_request.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_cubit.dart';

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
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
            workingDays: 22,
            subtotal: widget.driver.price,
            finalTotal: widget.driver.price,
            childPriceRaw: widget.driver.price,
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

  BreakdownModelInfo? _breakdownForKid(ChildModel kid) {
    try {
      return widget.driver.breakdown.firstWhere((b) => b.childId == kid.id);
    } catch (_) {
      return null;
    }
  }

  double _priceForKid(ChildModel kid) {
    try {
      final breakdownItem = widget.driver.breakdown.firstWhere(
        (b) => b.childId == kid.id,
      );
      return breakdownItem.childPrice;
    } catch (_) {}
    return widget.driver.price;
  }

  /// تسمية نوع الاشتراك
  String _labelForKid(ChildModel kid) {
    try {
      final breakdownItem = widget.driver.breakdown.firstWhere(
        (b) => b.childId == kid.id,
      );
      if (breakdownItem.subscriptionTypeLabel.isNotEmpty) {
        return breakdownItem.subscriptionTypeLabel;
      }
    } catch (_) {}
    final ctx = context.read<SearchCubit>().lastSearchContext;
    if (ctx != null) {
      return SubscriptionEnums.typeLabel(ctx.subscriptionType);
    }
    return SubscriptionEnums.typeLabel(kid.transportPref.subscriptionType);
  }

  double get _totalPrice =>
      widget.selectedKids.fold(0.0, (sum, k) => sum + _priceForKid(k));

  void _confirmAndSend() {
    if (widget.selectedKids.isEmpty) return;

    debugPrint('\n================= SUBMIT SUBSCRIPTION =================');

    final ctx = context.read<SearchCubit>().lastSearchContext;

    final subType = ctx?.subscriptionType ?? 'multi_day';
    final direction = ctx?.tripDirection ?? 'go';
    final start = (ctx?.startDate != null && ctx!.startDate.isNotEmpty)
        ? ctx.startDate
        : DateTime.now().toIso8601String().split('T').first;
    final end = (ctx?.endDate != null && ctx!.endDate.isNotEmpty)
        ? ctx.endDate
        : start;

    int? homeAddrId;
    if (widget.selectedKids.isNotEmpty) {
      homeAddrId = int.tryParse(widget.selectedKids.first.addressId);
    }

    final List<SubscriptionChildRequest> childrenRequestList = widget
        .selectedKids
        .where((k) => k.id != null)
        .map((k) => SubscriptionChildRequest(childId: k.id!))
        .toList();

    final request = SubscriptionRequest(
      driverId: widget.driver.driverId,
      subscriptionType: subType,
      tripDirection: direction,
      startDate: start,
      endDate: end,
      homeAddressId: homeAddrId,
      children: childrenRequestList,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    debugPrint('>>> Final JSON being sent:');
    debugPrint(request.toJson().toString());
    debugPrint('========================================================');

    context.read<SearchCubit>().submitSubscription(request);
  }

  void _showInsufficientBalanceDialog(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.error),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'رصيد المحفظة غير كافٍ',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              color: isDark ? AppColors.grey300 : AppColors.grey700,
              height: 1.5,
            ),
          ),
          actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          actions: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? AppColors.grey700 : AppColors.grey300),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'إلغاء',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.grey300 : AppColors.textMuted,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.parentRecharge,
                    arguments: getIt<WalletCubit>(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'اشحن محفظتك',
                  style: AppTextStyles.style(fontWeight: FontWeight.bold, color: AppColors.white),
                ),
              ),
            ),
          ],
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
            if (state.errorMessage.contains('رصيد المحفظة')) {
              _showInsufficientBalanceDialog(context, state.errorMessage);
            } else {
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

                          // 3. حقل الملاحظات
                          _buildNotesField(theme, isDark),
                          SizedBox(height: 16.h),

                          // 4. تنبيه إرشادي
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
                            final breakdownItem = _breakdownForKid(kid);
                            // خصم الإخوة له معنى فقط لو الطلب شامل أكثر من طفل
                            final hasDiscount =
                                (breakdownItem?.hasSiblingDiscount ?? false) &&
                                    widget.selectedKids.length > 1;

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                      hasDiscount
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${breakdownItem!.subtotal.toStringAsFixed(2)} د.ل',
                                                  style: AppTextStyles.style(
                                                    fontSize: 11.sp,
                                                    color: AppColors.grey500,
                                                    decoration: TextDecoration.lineThrough,
                                                    decorationColor: AppColors.grey500,
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Icon(
                                                  Icons.arrow_back_rounded,
                                                  size: 12.r,
                                                  color: AppColors.grey500,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  '${price.toStringAsFixed(2)} د.ل',
                                                  style: AppTextStyles.style(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13.sp,
                                                    color: AppColors.success,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              '${price.toStringAsFixed(2)} د.ل',
                                              style: AppTextStyles.style(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.sp,
                                                color: isDark ? AppColors.white : AppColors.textDark,
                                              ),
                                            ),
                                    ],
                                  ),
                                  if (hasDiscount)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h, right: 24.w),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          'خصم الإخوة ${breakdownItem!.discountPercent.toStringAsFixed(0)}%',
                                          style: AppTextStyles.style(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.success,
                                          ),
                                        ),
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

  Widget _buildNotesField(ThemeData theme, bool isDark) {
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
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.note_alt_rounded, color: theme.colorScheme.primary, size: 18.r),
                ),
                SizedBox(width: 10.w),
                Text(
                  'ملاحظات للسائق (اختياري)',
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
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 300,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.style(
                fontSize: 13.sp,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'مثال: يرجى الانتظار عند الباب الخارجي لمدة دقيقتين...',
                hintStyle: AppTextStyles.style(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.grey500 : AppColors.textMuted,
                ),
                filled: true,
                fillColor: isDark ? AppColors.grey900 : AppColors.grey50,
                contentPadding: EdgeInsets.all(14.w),
                counterStyle: AppTextStyles.style(
                  fontSize: 11.sp,
                  color: isDark ? AppColors.grey500 : AppColors.grey400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.grey700 : AppColors.grey200,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.grey700 : AppColors.grey200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(
                    color: AppColors.secondaryDark,
                    width: 1.5,
                  ),
                ),
              ),
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
