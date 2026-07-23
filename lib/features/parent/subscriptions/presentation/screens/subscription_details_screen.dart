import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../logic/subscriptions_cubit/subscriptions_cubit.dart';
import '../../data/models/active_subscription_model.dart';

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

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  String _getStatusArabic(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'pending_start':
        return 'بانتظار البدء';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
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
        body: BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
          listener: (context, state) {
            if (state is SubscriptionsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      state.message,
                      style: AppTextStyles.style(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  duration: const Duration(seconds: 3),
                ),
              );
              Navigator.of(context).pop();
            } else if (state is SubscriptionsActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      state.message,
                      style: AppTextStyles.style(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SubscriptionDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SubscriptionDetailError) {
              return _buildErrorState(
                  context, state.message, isDark, theme);
            }

            if (state is SubscriptionDetailLoaded) {
              return _buildContent(
                  context, state.detail, isDark, theme, false);
            }

            if (state is SubscriptionsActionLoading ||
                state is SubscriptionsActionSuccess ||
                state is SubscriptionsActionError) {
              return const Center(child: CircularProgressIndicator());
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ActiveSubscriptionModel sub,
      bool isDark, ThemeData theme, bool isCancelling) {
    final isActive = sub.status.toLowerCase() == 'active' ||
        sub.status.toLowerCase() == 'pending_start';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDriverCard(sub.driver, theme, isDark),
                SizedBox(height: 16.h),
                _buildContractCard(sub, theme, isDark),
                SizedBox(height: 16.h),
                _buildChildCard(sub.child, theme, isDark),
              ],
            ),
          ),
        ),
        if (isActive)
          _buildCancelActionBar(
              context, sub.id, theme, isDark, isCancelling),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error, bool isDark,
      ThemeData theme) {
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

  Widget _buildDriverCard(
      ActiveDriver driver, ThemeData theme, bool isDark) {
    final isFemale = driver.name.contains('ة') ||
        driver.name.contains('فاطمة') ||
        driver.name.contains('مريم');
    final avatarColor =
        isFemale ? AppColors.femalePink : theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: avatarColor.withValues(alpha: 0.1),
                child: Text(
                  _getInitials(driver.name),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    color: avatarColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
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
                    if (driver.vehicle?.displayName != null &&
                        driver.vehicle!.displayName.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        driver.vehicle!.displayName,
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.grey400
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                    if (driver.vehicle?.plateNumber != null &&
                        driver.vehicle!.plateNumber.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'لوحة: ${driver.vehicle!.plateNumber}',
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          color: isDark
                              ? AppColors.grey500
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (driver.phone != null)
                IconButton(
                  icon: Icon(Icons.phone_in_talk_rounded,
                      color: theme.colorScheme.primary),
                  onPressed: () {},
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContractCard(
      ActiveSubscriptionModel sub, ThemeData theme, bool isDark) {
    final contract = sub.contract;
    final isCancelled = sub.status.toLowerCase() == 'cancelled';
    final isCompleted = sub.status.toLowerCase() == 'completed';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined,
                  color: theme.colorScheme.primary, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل العقد والاشتراك',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _detailRow(
              'رقم العقد', contract.contractNumber, isDark),
          _divider(isDark),
          _detailRow('القيمة الإجمالية', sub.formattedPrice, isDark,
              valueColor: theme.colorScheme.primary, isBoldValue: true),
          _divider(isDark),
          _detailRow('تاريخ البدء',
              contract.startDate.split('T').first, isDark),
          _divider(isDark),
          _detailRow(
              'تاريخ الانتهاء', contract.endDate.split('T').first, isDark),
          _divider(isDark),
          _detailRow('حالة العقد', _getStatusArabic(contract.status), isDark,
              valueColor: _getStatusColor(contract.status),
              isBoldValue: true),
          if (!isCancelled && !isCompleted) ...[
            _divider(isDark),
            _detailRow('حالة الاشتراك', sub.statusDisplayLabel, isDark,
                valueColor: _getStatusColor(sub.status), isBoldValue: true),
          ],
          if (sub.pickupTime != null) ...[
            _divider(isDark),
            _detailRow('وقت الاستلام', sub.pickupTime!, isDark),
          ],
          if (sub.dropoffTime != null) ...[
            _divider(isDark),
            _detailRow('وقت التوصيل', sub.dropoffTime!, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildChildCard(ActiveChild child, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.child_care_outlined,
                  color: theme.colorScheme.primary, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                'الطفل المشمول بالاشتراك',
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
                radius: 20.r,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person_outline,
                    color: theme.colorScheme.primary, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name ?? child.schoolName,
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      child.schoolName,
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.grey400
                            : AppColors.textMuted,
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

  Widget _buildCancelActionBar(BuildContext context, int id,
      ThemeData theme, bool isDark, bool isCancelling) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
            top: BorderSide(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
                width: 0.5.w)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton.icon(
          onPressed: isCancelling
              ? null
              : () => _showCancelDialog(context, id),
          icon: isCancelling
              ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5.w, color: AppColors.white),
                )
              : Icon(Icons.delete_outline_rounded,
                  size: 18.r, color: AppColors.white),
          label: Text(
            'إلغاء الاشتراك',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r)),
          ),
        ),
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
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight:
                  isBoldValue ? FontWeight.bold : FontWeight.w600,
              color: valueColor ??
                  (isDark ? AppColors.white : AppColors.textDark),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending_start':
        return AppColors.pending;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.grey500;
      default:
        return AppColors.grey500;
    }
  }

  void _showCancelDialog(BuildContext context, int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Text(
            'تأكيد إلغاء الاشتراك',
            style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: isDark ? AppColors.white : AppColors.textDark),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في إلغاء هذا الاشتراك؟',
            style: AppTextStyles.style(
                fontSize: 13.sp,
                color: isDark ? AppColors.grey300 : AppColors.textMuted,
                height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'تراجع',
                style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? AppColors.grey400 : AppColors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context
                    .read<SubscriptionsCubit>()
                    .cancelSubscription(id);
              },
              child: Text(
                'نعم، إلغاء',
                style: AppTextStyles.style(
                    fontWeight: FontWeight.bold, color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
