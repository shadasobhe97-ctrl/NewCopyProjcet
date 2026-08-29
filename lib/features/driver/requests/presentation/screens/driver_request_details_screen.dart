import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/requests/logic/driver_requests_cubit.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/features/parent/subscriptions/data/models/subscription_location_model.dart';
import 'package:kids_transport/features/parent/subscriptions/presentation/screens/subscription_map_screen.dart';


/// شاشة تفاصيل طلب الاشتراك للسائق
/// تستدعي [DriverRequestsCubit.loadRequestDetails] لجلب التفاصيل من API
class DriverRequestDetailsScreen extends StatefulWidget {
  final int requestId;

  const DriverRequestDetailsScreen({super.key, required this.requestId});

  @override
  State<DriverRequestDetailsScreen> createState() =>
      _DriverRequestDetailsScreenState();
}

class _DriverRequestDetailsScreenState extends State<DriverRequestDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverRequestsCubit>().loadRequestDetails(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: _buildAppBar(context),
        body: BlocBuilder<DriverRequestsCubit, DriverRequestsState>(
          builder: (context, state) {
            if (state is DriverRequestDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DriverRequestDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 50, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: AppTextStyles.style(
                          fontSize: 14,
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<DriverRequestsCubit>()
                            .loadRequestDetails(widget.requestId),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is DriverRequestDetailsLoaded) {
              final request = state.request;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBanner(request: request),
                    const SizedBox(height: 16),
                    _SectionCard(
                      icon: Icons.person_rounded,
                      iconColor: AppColors.primaryLight,
                      title: 'ولي الأمر',
                      child: _ParentInfoWidget(request: request),
                    ),
                    const SizedBox(height: 12),
                    _TotalPriceCard(request: request),
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.child_care_rounded,
                      iconColor: AppColors.success,
                      title: 'اشتراكات الأطفال (${request.children.length})',
                      child: _ChildrenListWidget(children: request.children, request: request),
                    ),
                    if (request.notes != null && request.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _SectionCard(
                        icon: Icons.notes_rounded,
                        iconColor: AppColors.textMuted,
                        title: 'ملاحظات',
                        child: Text(
                          request.notes!,
                          style: AppTextStyles.style(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                    if (request.status.toLowerCase() == 'rejected' &&
                        request.rejectionReason != null) ...[
                      const SizedBox(height: 12),
                      _SectionCard(
                        icon: Icons.cancel_rounded,
                        iconColor: AppColors.error,
                        title: 'سبب الرفض',
                        child: Text(
                          request.rejectionReason!,
                          style: AppTextStyles.style(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (request.status.toLowerCase() == 'pending') ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _showRejectDialog(context, request),
                              style: AppTheme.outlinedButtonStyle(
                                side: const BorderSide(color: AppColors.error),
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'رفض الطلب',
                                style: AppTextStyles.style(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _acceptRequest(context, request),
                              style: AppTheme.elevatedButtonStyle(
                                backgroundColor: AppColors.success,
                                foregroundColor: AppColors.white,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'قبول الطلب',
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _acceptRequest(BuildContext context, DriverRequestModel request) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('قبول الطلب', textAlign: TextAlign.right),
        content: const Text(
          'هل أنت متأكد من قبول هذا الطلب؟ سيظهر الطفل تلقائياً في رحلاتك القادمة حسب مسارك.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cubit = context.read<DriverRequestsCubit>();
              final messenger = ScaffoldMessenger.of(context);

              Navigator.of(dCtx).pop();
              final result = await cubit.acceptRequest(request.id);

              if (!mounted) return;

              if (result != null && result.success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(result.message.isNotEmpty
                        ? result.message
                        : 'تم قبول الطلب وتفعيل الاشتراك بنجاح.'),
                    backgroundColor: AppColors.success,
                  ),
                );

                cubit.loadRequestDetails(request.id);
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تعذر قبول الطلب. الرجاء المحاولة مرة أخرى.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },

            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('قبول وإسناد'),
          ),
        ],
      ),
    );
  }


  void _showRejectDialog(BuildContext context, DriverRequestModel request) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('رفض طلب الاشتراك', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('هل تريد رفض هذا الطلب؟ الرجاء إدخال سبب الرفض:',
                textAlign: TextAlign.right),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: 'سبب الرفض (إلزامي)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(dCtx).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال سبب الرفض')),
                );
                return;
              }
              final cubit = context.read<DriverRequestsCubit>();
              Navigator.of(dCtx).pop();
              await cubit.rejectRequest(
                request.id,
                reason: controller.text.trim(),
              );
              if (mounted) {
                cubit.loadRequestDetails(request.id);
              }
            },

            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('رفض الطلب'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: AppTheme.boxDecoration(
          gradient: AppTheme.linearGradient(
            colors: context.primaryGradient,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppColors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Text(
                  'تفاصيل الطلب #${widget.requestId}',
                  style: AppTextStyles.style(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── شريط الحالة ──
class _StatusBanner extends StatelessWidget {
  final DriverRequestModel request;
  const _StatusBanner({required this.request});

  Color _getStatusColor() {
    switch (request.status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'accepted':
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.grey400;
      default:
        return AppColors.primaryLight;
    }
  }

  IconData _getStatusIcon() {
    switch (request.status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'accepted':
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'cancelled':
        return Icons.block_rounded;
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
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: AppTheme.boxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(), color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة الطلب',
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.statusDisplayLabel,
                  style: AppTextStyles.style(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: AppTheme.boxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppTheme.radius(20),
            ),
            child: Text(
              'طلب #${request.id}',
              style: AppTextStyles.style(
                fontSize: 12,
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
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(
          color: isDark
              ? AppColors.grey800
              : AppColors.grey.withValues(alpha: 0.12),
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 6,
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
                width: 34,
                height: 34,
                decoration: AppTheme.boxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppTheme.radius(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.style(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── معلومات ولي الأمر ──
class _ParentInfoWidget extends StatelessWidget {
  final DriverRequestModel request;
  const _ParentInfoWidget({required this.request});

  @override
  Widget build(BuildContext context) {
    final parent = request.parent;
    final hasParentData =
        parent.name.isNotEmpty || (parent.phone?.isNotEmpty ?? false);

    return Column(
      children: [
        _InfoRow(
          icon: Icons.person_outline_rounded,
          label: 'الاسم',
          value: parent.name.isNotEmpty ? parent.name : 'غير متوفر من الخادم',
        ),
        if (parent.phone != null && parent.phone!.isNotEmpty)
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'الهاتف',
            value: parent.phone!,
          ),
        if (!hasParentData)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'لم يُرجع الخادم بيانات ولي الأمر لهذا الطلب.',
              style: AppTextStyles.style(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
        _InfoRow(
          icon: Icons.child_care_rounded,
          label: 'عدد الأطفال',
          value: '${request.childrenCount} أطفال',
        ),
      ],
    );
  }
}


// ── بطاقة السعر الإجمالي ──
class _TotalPriceCard extends StatelessWidget {
  final DriverRequestModel request;
  const _TotalPriceCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: AppTheme.boxDecoration(
        color: AppColors.success.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(
          color: AppColors.success.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.payments_rounded,
                  color: AppColors.success, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'السعر الإجمالي (يدفعه ولي الأمر)',
                  style: AppTextStyles.style(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${request.totalPrice} د.ل',
                style: AppTextStyles.style(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (request.driverNetTotal != null) ...[
            const Divider(height: 18, thickness: 0.5),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: AppColors.success, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'صافي أرباحك الإجمالية',
                    style: AppTextStyles.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${request.driverNetTotal} د.ل',
                  style: AppTextStyles.style(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── قائمة الأطفال ──
class _ChildrenListWidget extends StatelessWidget {
  final List<DriverReqChild> children;
  final DriverRequestModel request;
  const _ChildrenListWidget({required this.children, required this.request});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Text(
        'لا يوجد أطفال',
        style: AppTextStyles.style(fontSize: 13, color: AppColors.textMuted),
      );
    }

    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return _ChildCard(child: child, request: request, index: index);
      }).toList(),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final DriverReqChild child;
  final DriverRequestModel request;
  final int index;
  const _ChildCard({
    required this.child,
    required this.request,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor = context.primaryColor;
    final details = child.details;

    // نقاط الانطلاق/الوصول الخاصة بهذا الطفل تحديداً
    final pickup = child.pickupLocation;
    final dropoff = child.dropoffLocation;
    // الاسم أولاً ("منزلي" / "مدرسة النور")، والعنوان التفصيلي يُعرض فقط إن كان حقيقياً
    final pickupName = pickup != null
        ? pickup.displayName
        : (child.pivot?.homeLabel ?? 'غير محدد');
    final schoolName = dropoff != null
        ? dropoff.displayName
        : (child.pivot?.schoolLabel ?? request.school.name);
    final pickupAddress = pickup?.displayAddress;
    final schoolAddress = dropoff?.displayAddress;

    return Container(
      margin: EdgeInsets.only(bottom: index < request.children.length - 1 ? 12.h : 0),
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
          // ── رأس البطاقة ──
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: primaryColor.withValues(alpha: 0.12),
                backgroundImage: (child.avatarUrl != null && child.avatarUrl!.isNotEmpty)
                    ? CachedNetworkImageProvider(
                        child.avatarUrl!.startsWith('http')
                            ? child.avatarUrl!
                            : '${ApiEndpoints.baseUrl.replaceAll('/api/', '')}/storage/${child.avatarUrl!}',
                      )
                    : null,
                child: (child.avatarUrl == null || child.avatarUrl!.isEmpty)
                    ? Text(
                        child.name.isNotEmpty ? child.name[0] : '؟',
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
                    if (schoolName.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        schoolName,
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        if (child.gender != null && child.gender!.isNotEmpty)
                          _buildChip(
                            child.gender == 'male' ? 'ذكر' : 'أنثى',
                            child.gender == 'male' ? Icons.male_rounded : Icons.female_rounded,
                            isDark,
                          ),
                        if (child.age != null)
                          _buildChip(
                            'العمر: ${child.age} سنوات',
                            Icons.cake_outlined,
                            isDark,
                          ),
                        if (child.grade != null && child.grade! > 0)
                          _buildChip(
                            'الصف: ${child.grade}',
                            Icons.school_outlined,
                            isDark,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // سعر الطفل
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  child.priceLabel,
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

          // ── تفاصيل الاشتراك الخاصة بالطفل ──
          _InfoRow(
            icon: Icons.repeat_rounded,
            label: 'نوع الاشتراك',
            value: details.typeLabel,
          ),
          const Divider(height: 12, thickness: 0.5),
          _InfoRow(
            icon: Icons.swap_horiz_rounded,
            label: 'الاتجاه',
            value: details.directionLabel,
          ),
          const Divider(height: 12, thickness: 0.5),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'الفترة',
            value: details.timingLabel,
          ),
          const Divider(height: 12, thickness: 0.5),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'تاريخ بداية الاشتراك',
            value: _fmt(details.startDate),
          ),
          const Divider(height: 12, thickness: 0.5),
          _InfoRow(
            icon: Icons.event_rounded,
            label: 'تاريخ نهاية الاشتراك',
            value: _fmt(details.endDate),
          ),
          if (details.workingDaysCount != null) ...[
            const Divider(height: 12, thickness: 0.5),
            _InfoRow(
              icon: Icons.date_range_rounded,
              label: 'عدد أيام العمل',
              value: '${details.workingDaysCount} يوم',
            ),
          ],
          const Divider(height: 12, thickness: 0.5),
          _InfoRow(
            icon: Icons.directions_bus_filled_rounded,
            label: 'سعر الرحلة',
            value: _money(details.tripPrice ?? 0),
          ),
          const Divider(height: 12, thickness: 0.5),
          _InfoRow(
            icon: Icons.person_pin_rounded,
            label: 'سعر اشتراك الطفل',
            value: child.priceLabel,
          ),
          if (child.platformCommissionLabel != null) ...[
            const Divider(height: 12, thickness: 0.5),
            _InfoRow(
              icon: Icons.percent_rounded,
              label: 'عمولة المنصة',
              value: child.platformCommissionLabel!,
            ),
          ],
          if (child.driverNetPriceLabel != null) ...[
            const Divider(height: 12, thickness: 0.5),
            _InfoRow(
              icon: Icons.account_balance_wallet_rounded,
              label: 'صافي ربحك',
              value: child.driverNetPriceLabel!,
              valueColor: AppColors.success,
            ),
          ],
          const Divider(height: 12, thickness: 0.5),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'نقطة الانطلاق',
            value: pickupName,
            valueColor: Colors.blue.shade700,
          ),
          if (pickupAddress != null) ...[
            const Divider(height: 12, thickness: 0.5),
            _InfoRow(
              icon: Icons.place_outlined,
              label: 'عنوان الانطلاق',
              value: pickupAddress,
            ),
          ],
          const Divider(height: 12, thickness: 0.5),
          _InfoRow(
            icon: Icons.school_rounded,
            label: 'المدرسة (نقطة الوصول)',
            value: schoolName.isNotEmpty ? schoolName : 'غير محدد',
            valueColor: Colors.teal.shade700,
          ),
          if (schoolAddress != null) ...[
            const Divider(height: 12, thickness: 0.5),
            _InfoRow(
              icon: Icons.map_outlined,
              label: 'عنوان المدرسة',
              value: schoolAddress,
            ),
          ],
          if (_notes(child) != null) ...[
            const Divider(height: 12, thickness: 0.5),
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'ملاحظات الطفل',
              value: _notes(child)!,
            ),
          ],
          if (child.medicalNotes != null && child.medicalNotes!.isNotEmpty) ...[
            const Divider(height: 12, thickness: 0.5),
            _InfoRow(
              icon: Icons.medical_services_rounded,
              label: 'ملاحظات طبية',
              value: child.medicalNotes!,
            ),
          ],
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final pickupPoint = SubscriptionLocationModel(
                  id: pickup?.id,
                  name: pickupName,
                  address: pickupAddress,
                  latitude: pickup?.latitude,
                  longitude: pickup?.longitude,
                );
                final dropoffPoint = SubscriptionLocationModel(
                  id: dropoff?.id,
                  name: schoolName,
                  address: schoolAddress,
                  latitude: dropoff?.latitude,
                  longitude: dropoff?.longitude,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubscriptionMapScreen(
                      title: 'موقع توصيل ${child.name}',
                      pickupLocation: pickupPoint,
                      dropoffLocation: dropoffPoint,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.map_rounded,
                size: 16.sp,
                color: primaryColor,
              ),
              label: Text(
                'عرض الموقع على الخريطة',
                style: AppTextStyles.style(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: primaryColor.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ملاحظات ولي الأمر عن الطفل: الحقل الجديد أولاً ثم pivot القديم
  static String? _notes(DriverReqChild c) {
    final v = c.childNotes ?? c.pivot?.childNotes;
    if (v == null) return null;
    final t = v.trim();
    return (t.isEmpty || t == 'null') ? null : t;
  }

  String _money(double v) => v == v.roundToDouble()
      ? '${v.toInt()} د.ل'
      : '${v.toStringAsFixed(2)} د.ل';

  String _fmt(String? raw) =>
      (raw != null && raw.isNotEmpty && raw != 'null') ? raw : 'غير متوفر';

  Widget _buildChip(String text, IconData icon, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: AppColors.textMuted),
          SizedBox(width: 3.w),
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

// ── صف معلومات ──
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isCompact;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isCompact = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 4 : 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: isCompact ? 13 : 15, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.style(
              fontSize: isCompact ? 12 : 13,
              color: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontSize: isCompact ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
