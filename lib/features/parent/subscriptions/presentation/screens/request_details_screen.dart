import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import '../../logic/requests_cubit/requests_cubit.dart';
import '../../data/models/request_model.dart';

class RequestDetailsScreen extends StatefulWidget {
  final RequestModel request;

  const RequestDetailsScreen({super.key, required this.request});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RequestsCubit>().fetchRequestDetail(widget.request.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFF4F6FA),
        appBar: _buildAppBar(context, isDark),
        body: BlocConsumer<RequestsCubit, RequestsState>(
          listener: (context, state) {
            if (state is RequestsActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(_snackBar(state.message, AppColors.success));
              Navigator.of(context).pop(true);
            } else if (state is RequestsActionError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(_snackBar(state.message, AppColors.error));
            }
          },
          builder: (context, state) {
            if (state is RequestDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RequestDetailError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64.r,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
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
                            .read<RequestsCubit>()
                            .fetchRequestDetail(widget.request.id),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          'إعادة المحاولة',
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
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

            // Fallback to widget.request if not loaded
            final req = state is RequestDetailLoaded
                ? state.request
                : widget.request;

            final isPending = req.status.toLowerCase() == 'pending';
            final isCancelling =
                state is RequestsActionLoading && state.actionId == req.id;

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                          child: Column(
                            children: [
                              // ── الحالة ──
                              _StatusBanner(request: req, isDark: isDark),
                              SizedBox(height: 16.h),
                              // ── معلومات عامة ──
                              _GeneralInfoCard(
                                request: req,
                                theme: theme,
                                isDark: isDark,
                              ),
                              SizedBox(height: 16.h),
                              // ── ترويسة قسم الأطفال ──
                              _SectionHeader(
                                icon: Icons.people_alt_outlined,
                                title: 'اشتراكات الأطفال',
                                count: req.children.length,
                                theme: theme,
                                isDark: isDark,
                              ),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),

                      // ── بطاقات الأطفال ──
                      SliverList(
                        delegate: SliverChildBuilderDelegate((ctx, i) {
                          final child = req.children[i];
                          return Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                            child: _ChildSubscriptionCard(
                              child: child,
                              theme: theme,
                              isDark: isDark,
                            ),
                          );
                        }, childCount: req.children.length),
                      ),

                      // ── سبب الرفض ──
                      if (req.rejectionReason != null &&
                          req.rejectionReason!.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                            child: _RejectionCard(
                              reason: req.rejectionReason!,
                              isDark: isDark,
                            ),
                          ),
                        ),

                      SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                    ],
                  ),
                ),

                // ── زر الإلغاء ──
                if (isPending)
                  _CancelButton(
                    isCancelling: isCancelling,
                    onCancel: () => _showCancelDialog(context, req),
                    isDark: isDark,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      title: Text(
        'طلب #${widget.request.id}',
        style: AppTextStyles.style(
          fontWeight: FontWeight.bold,
          fontSize: 17.sp,
          color: isDark ? AppColors.white : AppColors.textDark,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      foregroundColor: isDark ? AppColors.white : AppColors.textDark,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  SnackBar _snackBar(String msg, Color color) {
    return SnackBar(
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          msg,
          style: AppTextStyles.style(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(16.w),
    );
  }

  void _showCancelDialog(BuildContext context, RequestModel req) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Text(
            'تأكيد إلغاء الطلب',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          content: Text(
            'هل أنت متأكد من إلغاء طلب الاشتراك هذا؟',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              color: isDark ? AppColors.grey300 : AppColors.textMuted,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'تراجع',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<RequestsCubit>().cancelRequest(req.id);
              },
              child: Text(
                'نعم، إلغاء',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  بانر الحالة                                            ║
// ╚══════════════════════════════════════════════════════════╝
class _StatusBanner extends StatelessWidget {
  final RequestModel request;
  final bool isDark;
  const _StatusBanner({required this.request, required this.isDark});

  Color get _color {
    switch (request.status.toLowerCase()) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.grey500;
      default:
        return AppColors.pending;
    }
  }

  IconData get _icon {
    switch (request.status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'cancelled':
        return Icons.block_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _color.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 26.r),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.statusAr ?? request.statusDisplayLabel,
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: _color,
                ),
              ),
              Text(
                'تاريخ الطلب: ${_fmtDate(request.createdAt)}',
                style: AppTextStyles.style(
                  fontSize: 11.sp,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  بطاقة المعلومات العامة                                 ║
// ╚══════════════════════════════════════════════════════════╝
class _GeneralInfoCard extends StatelessWidget {
  final RequestModel request;
  final ThemeData theme;
  final bool isDark;
  const _GeneralInfoCard({
    required this.request,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── السائق ──
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.primary,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.driver.name,
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    if (request.driver.phone != null)
                      Text(
                        request.driver.phone!,
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
              if (request.driver.phone != null)
                _IconChip(
                  icon: Icons.phone_in_talk_rounded,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
          _Divider(isDark: isDark),

          // ── تاريخ إرسال الطلب ──
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'تاريخ إرسال الطلب',
            value: _fmtDate(request.createdAt),
            isDark: isDark,
          ),
          _Divider(isDark: isDark),

          // ── عدد الأطفال ──
          _InfoRow(
            icon: Icons.child_care_rounded,
            label: 'عدد الأطفال',
            value: '${request.childrenCount} أطفال',
            isDark: isDark,
          ),

          // ── ملاحظات الطلب ──
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            _Divider(isDark: isDark),
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'ملاحظات',
              value: request.notes!,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  بطاقة اشتراك طفل واحد                                 ║
// ╚══════════════════════════════════════════════════════════╝
class _ChildSubscriptionCard extends StatelessWidget {
  final RequestChild child;
  final ThemeData theme;
  final bool isDark;
  const _ChildSubscriptionCard({
    required this.child,
    required this.theme,
    required this.isDark,
  });

  String _typeLabel(String t) {
    switch (t.toLowerCase()) {
      case 'monthly':
        return 'شهري';
      case 'weekly':
        return 'أسبوعي';
      case 'daily':
        return 'يومي';
      default:
        return t.isNotEmpty ? t : 'غير متوفر';
    }
  }

  String _dirLabel(String d) {
    switch (d.toLowerCase()) {
      case 'both':
        return 'ذهاب وعودة';
      case 'go':
        return 'ذهاب فقط';
      case 'return':
        return 'عودة فقط';
      default:
        return d.isNotEmpty ? d : 'غير متوفر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = child.subscription;

    return _Card(
      isDark: isDark,
      borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس البطاقة ──
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                backgroundImage:
                    (child.photoUrl != null && child.photoUrl!.isNotEmpty)
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
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
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
                      child.name.isNotEmpty ? child.name : 'غير متوفر',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    Text(
                      child.school.name.isNotEmpty
                          ? child.school.name
                          : 'غير متوفر',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        _buildInfoChip(
                          child.age != null
                              ? 'العمر: ${child.age} سنوات'
                              : 'العمر: غير متوفر',
                          Icons.cake_outlined,
                          isDark,
                        ),
                        _buildInfoChip(
                          child.gender != null
                              ? (child.gender == 'male' ? 'ذكر' : 'أنثى')
                              : 'جنس الطفل: غير متوفر',
                          child.gender == 'male'
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // السعر الخاص بالطفل
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _formatAmount(child.price),
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          _Divider(isDark: isDark),

          // ── تفاصيل الاشتراك ──
          _InfoRow(
            icon: Icons.repeat_rounded,
            label: 'نوع الاشتراك',
            value: _typeLabel(sub.type),
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.swap_horiz_rounded,
            label: 'الاتجاه',
            value: _dirLabel(sub.tripType),
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'تاريخ بداية الاشتراك',
            value: sub.startDate.isNotEmpty ? sub.startDate : 'غير متوفر',
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.event_rounded,
            label: 'تاريخ نهاية الاشتراك',
            value:
                (sub.endDate != null &&
                    sub.endDate!.isNotEmpty &&
                    sub.endDate != 'null')
                ? sub.endDate!
                : 'غير متوفر',
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.date_range_rounded,
            label: 'عدد أيام العمل',
            value: '${sub.workingDaysCount} يوم',
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'عنوان المنزل',
            value: child.home.address.isNotEmpty
                ? child.home.address
                : 'غير متوفر',
            isDark: isDark,
            valueColor: Colors.blue.shade700,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.school_rounded,
            label: 'اسم المدرسة',
            value: child.school.name.isNotEmpty
                ? child.school.name
                : 'غير متوفر',
            isDark: isDark,
            valueColor: Colors.teal.shade700,
          ),
          _Divider(isDark: isDark),
          _InfoRow(
            icon: Icons.map_outlined,
            label: 'عنوان المدرسة',
            value:
                (child.school.address != null &&
                    child.school.address!.isNotEmpty)
                ? child.school.address!
                : 'غير متوفر',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.grey800
            : AppColors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10.sp,
            color: isDark ? AppColors.grey400 : AppColors.textMuted,
          ),
          SizedBox(width: 3.w),
          Text(
            text,
            style: AppTextStyles.style(
              fontSize: 10.sp,
              color: isDark ? AppColors.grey300 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  ترويسة قسم                                            ║
// ╚══════════════════════════════════════════════════════════╝
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final ThemeData theme;
  final bool isDark;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 18.r),
        SizedBox(width: 8.w),
        Text(
          title,
          style: AppTextStyles.style(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  بطاقة سبب الرفض                                       ║
// ╚══════════════════════════════════════════════════════════╝
class _RejectionCard extends StatelessWidget {
  final String reason;
  final bool isDark;
  const _RejectionCard({required this.reason, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سبب الرفض:',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  reason,
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  زر الإلغاء                                            ║
// ╚══════════════════════════════════════════════════════════╝
class _CancelButton extends StatelessWidget {
  final bool isCancelling;
  final VoidCallback onCancel;
  final bool isDark;

  const _CancelButton({
    required this.isCancelling,
    required this.onCancel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton.icon(
            onPressed: isCancelling ? null : onCancel,
            icon: isCancelling
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : Icon(
                    Icons.delete_outline_rounded,
                    size: 18.r,
                    color: AppColors.white,
                  ),
            label: Text(
              'إلغاء الطلب',
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
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  Shared Widgets                                         ║
// ╚══════════════════════════════════════════════════════════╝
class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color? borderColor;
  const _Card({required this.child, required this.isDark, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color:
              borderColor ?? (isDark ? AppColors.grey800 : AppColors.grey200),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15.r,
            color: isDark ? AppColors.grey500 : AppColors.grey400,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: AppTextStyles.style(
              fontSize: 12.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.style(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color:
                    valueColor ??
                    (isDark ? AppColors.white : AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: isDark ? AppColors.grey800 : AppColors.grey100,
      height: 12,
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconChip({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18.r,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 16.r),
    );
  }
}

// ─────────────────────────────────────────────
// Private helper function for formatting date
// ─────────────────────────────────────────────

String _fmtDate(String raw) {
  try {
    final dt = DateTime.parse(raw.split('T').first);
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return raw.split('T').first;
  }
}

// ─────────────────────────────────────────────
// Private helper function for formatting amount
// ─────────────────────────────────────────────

String _formatAmount(double amount) {
  return '${amount.toStringAsFixed(2)} د.ل';
}
