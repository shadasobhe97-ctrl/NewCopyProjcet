import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/features/driver/subscriptions/logic/driver_subscriptions_cubit.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';

/// شاشة تفاصيل الاشتراك الموحد للسائق
class DriverSubscriptionDetailsScreen extends StatefulWidget {
  final int subscriptionId;

  const DriverSubscriptionDetailsScreen({
    super.key,
    required this.subscriptionId,
  });

  @override
  State<DriverSubscriptionDetailsScreen> createState() =>
      _DriverSubscriptionDetailsScreenState();
}

class _DriverSubscriptionDetailsScreenState
    extends State<DriverSubscriptionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<DriverSubscriptionsCubit>()
        .loadSubscriptionDetail(widget.subscriptionId);
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إجراء الاتصال الهاتفي.')),
        );
      }
    }
  }

  Future<void> _openMap(double lat, double lng) async {
    final googleMapsUrl = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    final appleMapsUrl = Uri.parse("https://maps.apple.com/?q=$lat,$lng");
    final webUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      } else {
        throw 'No map app available';
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح تطبيق الخرائط.')),
        );
      }
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'غير محدد';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  void _confirmCancel(
      BuildContext context, DriverSubscriptionModel subscription) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text(
            'إلغاء الاشتراك',
            style: AppTextStyles.style(
                fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          content: Text(
            'هل أنت متأكد من إلغاء هذا الاشتراك؟ سيتم إشعار ولي الأمر فوراً ولا يمكن التراجع عن هذا الإجراء.',
            style: AppTextStyles.style(
                fontSize: 13.sp, color: AppColors.textMuted, height: 1.5),
          ),
          actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          actions: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text('تراجع',
                    style:
                        AppTextStyles.style(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context
                      .read<DriverSubscriptionsCubit>()
                      .cancelSubscription(subscription);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'تأكيد الإلغاء',
                  style: AppTextStyles.style(
                      fontWeight: FontWeight.bold, color: AppColors.white),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: _buildAppBar(context),
        body: BlocConsumer<DriverSubscriptionsCubit, DriverSubscriptionsState>(
          listener: (context, state) {
            if (state is DriverSubscriptionCancelSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(state.message),
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop(true);
            } else if (state is DriverSubscriptionCancelError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(state.message),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DriverSubscriptionDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DriverSubscriptionDetailError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 60.sp, color: AppColors.error),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: AppTextStyles.style(
                            fontSize: 15.sp, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () => context
                            .read<DriverSubscriptionsCubit>()
                            .loadSubscriptionDetail(widget.subscriptionId),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            DriverSubscriptionModel? subscription;
            var isCancelling = false;
            if (state is DriverSubscriptionDetailLoaded) {
              subscription = state.subscription;
            } else if (state is DriverSubscriptionCancelLoading) {
              subscription = state.subscription;
              isCancelling = true;
            } else if (state is DriverSubscriptionCancelError) {
              subscription = state.subscription;
            }

            if (subscription != null) {
              final isAllowCancel =
                  subscription.status.toLowerCase() == 'accepted' ||
                      subscription.status.toLowerCase() == 'active';

              return RefreshIndicator(
                onRefresh: () => context
                    .read<DriverSubscriptionsCubit>()
                    .loadSubscriptionDetail(widget.subscriptionId),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. شريط الحالة
                      _StatusBanner(subscription: subscription),
                      SizedBox(height: 14.h),

                      // 2. بيانات ولي الأمر
                      _SectionCard(
                        icon: Icons.person_rounded,
                        iconColor: AppColors.primaryLight,
                        title: 'بيانات ولي الأمر',
                        child: _ParentInfoWidget(
                          parent: subscription.parent,
                          onCallPhone: _makeCall,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // 3. بيانات الاشتراك الموحد
                      _SectionCard(
                        icon: Icons.assignment_rounded,
                        iconColor: context.primaryColor,
                        title: 'بيانات الاشتراك الموحد',
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'نوع الاشتراك',
                              value: subscription.typeDisplayLabel,
                            ),
                            _InfoRow(
                              icon: Icons.alt_route_rounded,
                              label: 'اتجاه الرحلة',
                              value: subscription.directionDisplayLabel,
                            ),
                            _InfoRow(
                              icon: Icons.date_range_rounded,
                              label: 'تاريخ البداية',
                              value: _formatDate(
                                  subscription.subscription.startDate),
                            ),
                            _InfoRow(
                              icon: Icons.event_available_rounded,
                              label: 'تاريخ النهاية',
                              value: _formatDate(
                                  subscription.subscription.endDate),
                            ),
                            if (subscription.subscription.workingDaysCount !=
                                null)
                              _InfoRow(
                                icon: Icons.calendar_month_rounded,
                                label: 'عدد أيام العمل',
                                value:
                                    '${subscription.subscription.workingDaysCount} يوم',
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // 4. عنوان الانطلاق
                      if (subscription.homeAddress != null) ...[
                        _SectionCard(
                          icon: Icons.home_rounded,
                          iconColor: AppColors.warning,
                          title: 'عنوان الانطلاق',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(
                                icon: Icons.location_on_rounded,
                                label: 'العنوان',
                                value: subscription.homeAddress!.displayName,
                              ),
                              if (subscription.homeAddress!.hasCoordinates) ...[
                                SizedBox(height: 8.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _openMap(
                                      subscription.homeAddress!.lat!,
                                      subscription.homeAddress!.lng!,
                                    ),
                                    icon: Icon(Icons.navigation_rounded,
                                        size: 16.sp,
                                        color: context.primaryColor),
                                    label: Text(
                                      'عرض موقع الانطلاق على الخريطة',
                                      style: AppTextStyles.style(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // 5. الأطفال المشمولين
                      _SectionCard(
                        icon: Icons.child_care_rounded,
                        iconColor: AppColors.success,
                        title:
                            'الأطفال المشمولين (${subscription.children.length})',
                        child: _ChildrenListWidget(
                          children: subscription.children,
                          onOpenMap: _openMap,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // 6. الملخص المالي الموحد للاشتراك
                      if (subscription.pricing != null) ...[
                        _SectionCard(
                          icon: Icons.payments_rounded,
                          iconColor: AppColors.success,
                          title: 'الملخص المالي للاشتراك',
                          child: _OverallPricingWidget(
                              pricing: subscription.pricing!),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // 7. الملاحظات العامة
                      if (subscription.notes != null &&
                          subscription.notes!.trim().isNotEmpty) ...[
                        _SectionCard(
                          icon: Icons.notes_rounded,
                          iconColor: AppColors.textMuted,
                          title: 'الملاحظات',
                          child: Text(
                            subscription.notes!,
                            style: AppTextStyles.style(
                              fontSize: 13.sp,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // 8. زر إلغاء الاشتراك المفعل
                      if (isAllowCancel) ...[
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isCancelling
                                ? null
                                : () => _confirmCancel(context, subscription!),
                            icon: isCancelling
                                ? SizedBox(
                                    width: 16.r,
                                    height: 16.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.error,
                                    ),
                                  )
                                : Icon(Icons.cancel_outlined,
                                    size: 18.sp, color: AppColors.error),
                            label: Text(
                              isCancelling ? 'جارٍ الإلغاء...' : 'إلغاء الاشتراك',
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'تفاصيل الاشتراك',
        style: AppTextStyles.style(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17.sp,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded,
            color: AppColors.white, size: 20.sp),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.linearGradient(
            colors: context.primaryGradient,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
    );
  }
}

// ── شريط الحالة ──
class _StatusBanner extends StatelessWidget {
  final DriverSubscriptionModel subscription;
  const _StatusBanner({required this.subscription});

  Color _getStatusColor() {
    switch (subscription.status.toLowerCase()) {
      case 'active':
      case 'accepted':
        return AppColors.success;
      case 'pending':
      case 'pending_start':
        return AppColors.pending;
      case 'completed':
        return AppColors.primaryLight;
      case 'cancelled':
        return AppColors.grey400;
      default:
        return AppColors.primaryLight;
    }
  }

  IconData _getStatusIcon() {
    switch (subscription.status.toLowerCase()) {
      case 'active':
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'pending':
      case 'pending_start':
        return Icons.hourglass_empty_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color = _getStatusColor();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: AppTheme.boxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: AppTheme.radius(16.r),
        border: AppTheme.border(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: AppTheme.boxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(), color: color, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة الاشتراك',
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subscription.statusDisplayLabel,
                  style: AppTextStyles.style(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: AppTheme.boxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppTheme.radius(20.r),
            ),
            child: Text(
              'اشتراك #${subscription.id}',
              style: AppTextStyles.style(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── بطاقة قسم عامة ──
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(16.r),
        border: AppTheme.border(
          color: isDark
              ? AppColors.grey800
              : AppColors.grey.withValues(alpha: 0.12),
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.h,
                decoration: AppTheme.boxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppTheme.radius(8.r),
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: AppTextStyles.style(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

// ── معلومات ولي الأمر ──
class _ParentInfoWidget extends StatelessWidget {
  final DriverParentModel parent;
  final Function(String) onCallPhone;

  const _ParentInfoWidget({
    required this.parent,
    required this.onCallPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: Icons.person_outline_rounded,
          label: 'الاسم',
          value: parent.name.isNotEmpty ? parent.name : 'غير محدد',
        ),
        if (parent.phone != null && parent.phone!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Icon(Icons.phone_outlined,
                    size: 16.sp, color: AppColors.textMuted),
                SizedBox(width: 8.w),
                Text(
                  'الهاتف: ',
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onCallPhone(parent.phone!),
                    child: Text(
                      parent.phone!,
                      style: AppTextStyles.style(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.phone_in_talk_rounded,
                      size: 18.sp, color: AppColors.success),
                  onPressed: () => onCallPhone(parent.phone!),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        if (parent.alternativePhone != null &&
            parent.alternativePhone!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Icon(Icons.phone_android_rounded,
                    size: 16.sp, color: AppColors.textMuted),
                SizedBox(width: 8.w),
                Text(
                  'هاتف بديل: ',
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onCallPhone(parent.alternativePhone!),
                    child: Text(
                      parent.alternativePhone!,
                      style: AppTextStyles.style(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── قائمة الأطفال ──
class _ChildrenListWidget extends StatelessWidget {
  final List<DriverChildModel> children;
  final Function(double, double) onOpenMap;

  const _ChildrenListWidget({
    required this.children,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Text(
        'لا يوجد أطفال',
        style: AppTextStyles.style(fontSize: 13.sp, color: AppColors.textMuted),
      );
    }

    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return _ChildCard(
          child: child,
          index: index,
          totalCount: children.length,
          onOpenMap: onOpenMap,
        );
      }).toList(),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final DriverChildModel child;
  final int index;
  final int totalCount;
  final Function(double, double) onOpenMap;

  const _ChildCard({
    required this.child,
    required this.index,
    required this.totalCount,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor = context.primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: index < totalCount - 1 ? 12.h : 0),
      padding: EdgeInsets.all(14.w),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.backgroundLight,
        borderRadius: AppTheme.radius(14.r),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس البطاقة: الصورة والاسم ──
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: primaryColor.withValues(alpha: 0.12),
                backgroundImage: (child.photoUrl != null &&
                        child.photoUrl!.isNotEmpty)
                    ? CachedNetworkImageProvider(
                        child.photoUrl!.startsWith('http')
                            ? child.photoUrl!
                            : '${ApiEndpoints.baseUrl.replaceAll('/api/', '')}/storage/${child.photoUrl!}',
                      )
                    : null,
                child: (child.photoUrl == null || child.photoUrl!.isEmpty)
                    ? Text(
                        child.avatarInitials,
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name.isNotEmpty ? child.name : 'غير محدد',
                      style: AppTextStyles.style(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (child.school != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        child.school!.name,
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (child.pricing?.priceAfterDiscount != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    child.pricing!.formattedPrice,
                    style: AppTextStyles.style(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, thickness: 0.5),
          SizedBox(height: 10.h),

          // ── بيانات الطفل ──
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              if (child.gender != null)
                _buildBadge(
                  child.genderDisplay,
                  Icons.wc_rounded,
                  isDark,
                ),
              if (child.age != null)
                _buildBadge(
                  '${child.age} سنوات',
                  Icons.cake_outlined,
                  isDark,
                ),
              if (child.displayGrade.isNotEmpty)
                _buildBadge(
                  child.displayGrade,
                  Icons.school_outlined,
                  isDark,
                ),
              if (child.distanceKm != null)
                _buildBadge(
                  '${child.distanceKm} كم',
                  Icons.straighten_rounded,
                  isDark,
                ),
            ],
          ),

          // ── مدرسة الطفل مع زر الخريطة ──
          if (child.school != null) ...[
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'المدرسة: ${child.school!.name}',
                    style: AppTextStyles.style(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (child.school!.hasCoordinates)
                  TextButton.icon(
                    onPressed: () =>
                        onOpenMap(child.school!.lat!, child.school!.lng!),
                    icon: Icon(Icons.map_rounded, size: 14.sp),
                    label: Text('خريطة',
                        style: AppTextStyles.style(fontSize: 11.sp)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
              ],
            ),
          ],

          // ── الملاحظات الطبية ──
          if (child.medicalNotes != null &&
              child.medicalNotes!.trim().isNotEmpty) ...[
            SizedBox(height: 6.h),
            _InfoRow(
              icon: Icons.medical_information_outlined,
              label: 'ملاحظات طبية',
              value: child.medicalNotes!,
            ),
          ],

          // ── تفاصيل سعر الطفل ──
          if (child.pricing != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'صافي السائق من الطفل:',
                    style: AppTextStyles.style(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    child.pricing!.formattedDriverNet,
                    style: AppTextStyles.style(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── بيانات الاشتراك المفعل للطفل إن وجدت ──
          if (child.activeSubscription != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 13.sp, color: AppColors.primaryLight),
                      SizedBox(width: 4.w),
                      Text(
                        'اشتراك الطفل المفعل: ${child.activeSubscription!.displayStatus}',
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  if (child.activeSubscription!.pickupTime != null ||
                      child.activeSubscription!.dropoffTime != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'الصعود: ${child.activeSubscription!.pickupTime ?? "غير محدد"} | النزول: ${child.activeSubscription!.dropoffTime ?? "غير محدد"}',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.textMuted),
          SizedBox(width: 4.w),
          Text(
            text,
            style: AppTextStyles.style(
              fontSize: 11.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── الملخص المالي الموحد ──
class _OverallPricingWidget extends StatelessWidget {
  final DriverSubscriptionPricingModel pricing;

  const _OverallPricingWidget({required this.pricing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (pricing.totalPrice != null)
          _InfoRow(
            icon: Icons.receipt_long_rounded,
            label: 'السعر الإجمالي قبل الخصم',
            value: '${pricing.totalPrice} د.ل',
          ),
        if (pricing.discountAmount != null && pricing.discountAmount! > 0)
          _InfoRow(
            icon: Icons.discount_outlined,
            label: 'قيمة الخصم',
            value: '- ${pricing.discountAmount} د.ل',
          ),
        if (pricing.totalAmountAfterDiscount != null)
          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'الإجمالي بعد الخصم (يدفعه ولي الأمر)',
            value: pricing.formattedTotal,
          ),
        if (pricing.platformCommissionTotal != null)
          _InfoRow(
            icon: Icons.percent_rounded,
            label: 'عمولة المنصة',
            value: '${pricing.platformCommissionTotal} د.ل',
          ),
        const Divider(height: 16, thickness: 0.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'صافي أرباح السائق:',
              style: AppTextStyles.style(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              pricing.formattedDriverNet,
              style: AppTextStyles.style(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: AppColors.textMuted),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              color: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
