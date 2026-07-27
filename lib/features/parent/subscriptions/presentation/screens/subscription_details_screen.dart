import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../logic/subscriptions_cubit/subscriptions_cubit.dart';
import '../../data/models/subscription_detail_model.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  final int subscriptionId;

  const SubscriptionDetailsScreen({
    super.key,
    required this.subscriptionId,
  });

  @override
  State<SubscriptionDetailsScreen> createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState
    extends State<SubscriptionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<SubscriptionsCubit>()
        .fetchSubscriptionDetail(widget.subscriptionId);
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'غير محدد';
    try {
      final dt = DateTime.parse(raw.split('T').first);
      return intl.DateFormat('yyyy/MM/dd').format(dt);
    } catch (_) {
      return raw.split('T').first;
    }
  }

  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'غير محدد';
    try {
      final parts = raw.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final isPm = hour >= 12;
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final displayMinute = minute.toString().padLeft(2, '0');
        final period = isPm ? 'م' : 'ص';
        return '$displayHour:$displayMinute $period';
      }
      return raw;
    } catch (_) {
      return raw;
    }
  }

  String _shiftLabel(String? shift) {
    if (shift == null) return 'غير محدد';
    switch (shift.toLowerCase()) {
      case 'morning':
      case 'to_school':
        return 'ذهاب فقط (الفترة الصباحية)';
      case 'evening':
      case 'from_school':
        return 'عودة فقط (الفترة المسائية)';
      case 'both':
        return 'ذهاب وعودة';
      default:
        return shift;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'تفاصيل الاشتراك',
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
        body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
          builder: (context, state) {
            if (state is SubscriptionDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SubscriptionDetailError) {
              return _buildErrorState(context, state.message, isDark, theme);
            }

            if (state is SubscriptionDetailLoaded) {
              return RefreshIndicator(
                onRefresh: () => context
                    .read<SubscriptionsCubit>()
                    .fetchSubscriptionDetail(widget.subscriptionId),
                child: _buildContent(context, state.detail, isDark, theme),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SubscriptionDetailModel sub,
      bool isDark, ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChildCard(sub.child, theme, isDark),
          SizedBox(height: 16.h),
          _buildDriverCard(sub.driver, theme, isDark),
          SizedBox(height: 16.h),
          _buildScheduleCard(sub.schedule, theme, isDark),
          SizedBox(height: 16.h),
          _buildBillingCard(sub.billing, theme, isDark),
          SizedBox(height: 16.h),
          _buildAdditionalCard(sub, theme, isDark),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildChildCard(DetailChild child, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.child_care_outlined,
                  color: theme.colorScheme.primary, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'معلومات الطفل',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              if (child.avatar != null && child.avatar!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(25.r),
                  child: CachedNetworkImage(
                    imageUrl: child.avatar!,
                    width: 50.r,
                    height: 50.r,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 50.r,
                      height: 50.r,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.person_outline,
                          color: theme.colorScheme.primary),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildInitialsAvatar(child, theme),
                  ),
                )
              else
                _buildInitialsAvatar(child, theme),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name ?? 'بدون اسم',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      child.schoolName.isNotEmpty ? child.schoolName : 'مدرسة غير محددة',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(DetailChild child, ThemeData theme) {
    return CircleAvatar(
      radius: 25.r,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Text(
        child.avatarInitials ??
            (child.name != null && child.name!.isNotEmpty ? child.name![0] : '?'),
        style: AppTextStyles.style(
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDriverCard(DetailDriver driver, ThemeData theme, bool isDark) {
    final vehicle = driver.vehicle;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car_outlined,
                  color: theme.colorScheme.primary, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'معلومات السائق',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: driver.avatarUrl != null && driver.avatarUrl!.isNotEmpty
                    ? NetworkImage(driver.avatarUrl!)
                    : null,
                child: driver.avatarUrl == null || driver.avatarUrl!.isEmpty
                    ? Icon(Icons.person_rounded,
                        color: theme.colorScheme.primary, size: 24.r)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    if (driver.phone != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        driver.phone!,
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          color:
                              isDark ? AppColors.grey400 : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                'التقييم:',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < driver.rating
                        ? Colors.amber
                        : (isDark ? AppColors.grey700 : AppColors.grey200),
                    size: 18.r,
                  );
                }),
              ),
            ],
          ),
          if (vehicle != null) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: isDark ? AppColors.grey800 : AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(
                      'السيارة',
                      vehicle.displayName.isNotEmpty
                          ? vehicle.displayName
                          : 'غير محدد',
                      isDark),
                  _divider(isDark),
                  _detailRow(
                      'رقم اللوحة',
                      vehicle.plateNumber?.isNotEmpty == true
                          ? vehicle.plateNumber!
                          : 'غير محدد',
                      isDark),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
      DetailSchedule schedule, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  color: theme.colorScheme.primary, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'جدول الرحلة',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _detailRow('الفترة', _shiftLabel(schedule.shiftLabel), isDark),
          _divider(isDark),
          _detailRow(
              'منطقة الالتقاط', schedule.pickupZoneName ?? 'غير محدد', isDark),
          _divider(isDark),
          _detailRow(
              'وقت الالتقاط المتوقع', _formatTime(schedule.pickupTime), isDark),
          _divider(isDark),
          _detailRow(
              'وقت التوصيل المتوقع', _formatTime(schedule.dropoffTime), isDark),
        ],
      ),
    );
  }

  Widget _buildBillingCard(
      DetailBilling billing, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on_outlined,
                  color: theme.colorScheme.primary, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل الاشتراك والمالية',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _detailRow('سعر اشتراك الطفل', billing.formattedChildPrice, isDark,
              valueColor: theme.colorScheme.primary, isBoldValue: true),
          _divider(isDark),
          _detailRow('السعر الإجمالي للطلب', billing.formattedTotalPrice, isDark,
              valueColor: theme.colorScheme.primary, isBoldValue: true),
          _divider(isDark),
          _detailRow('تاريخ البداية', _formatDate(billing.startsAt), isDark),
          _divider(isDark),
          _detailRow('تاريخ النهاية', _formatDate(billing.endsAt), isDark),
          if (billing.remainingDays != null) ...[
            _divider(isDark),
            _detailRow(
                'الأيام المتبقية', '${billing.remainingDays} يوم', isDark,
                valueColor:
                    (billing.remainingDays! <= 3) ? AppColors.error : null),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalCard(
      SubscriptionDetailModel sub, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: theme.colorScheme.primary, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'معلومات إضافية',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _detailRow('رقم الطلب', '#${sub.requestId}', isDark),
          _divider(isDark),
          _detailRow(
              'تاريخ إنشاء الاشتراك', _formatDate(sub.createdAt), isDark),
          if (sub.cancelReason != null && sub.cancelReason!.isNotEmpty) ...[
            _divider(isDark),
            _detailRow('سبب الإلغاء', sub.cancelReason!, isDark,
                valueColor: AppColors.error),
          ],
          if (sub.cancelledAt != null && sub.cancelledAt!.isNotEmpty) ...[
            _divider(isDark),
            _detailRow('تاريخ الإلغاء', _formatDate(sub.cancelledAt), isDark,
                valueColor: AppColors.error),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark,
      {Color? valueColor, bool isBoldValue = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.style(
              fontSize: 12.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.style(
                fontSize: 13.sp,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
                color: valueColor ??
                    (isDark ? AppColors.white : AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
        color: isDark ? AppColors.grey800 : AppColors.grey100, height: 16);
  }

  Widget _buildErrorState(
      BuildContext context, String error, bool isDark, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64.r, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              error,
              style: AppTextStyles.style(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<SubscriptionsCubit>()
                  .fetchSubscriptionDetail(widget.subscriptionId),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'إعادة المحاولة',
                style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: AppColors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
