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

class DriverSubscriptionDetailsScreen extends StatefulWidget {
  final int subscriptionId;

  const DriverSubscriptionDetailsScreen({super.key, required this.subscriptionId});

  @override
  State<DriverSubscriptionDetailsScreen> createState() => _DriverSubscriptionDetailsScreenState();
}

class _DriverSubscriptionDetailsScreenState extends State<DriverSubscriptionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverSubscriptionsCubit>().loadSubscriptionDetail(widget.subscriptionId);
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
    final webUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

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
    if (raw == null || raw.isEmpty) return 'غير متوفر';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  String _formatTimeArabic(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 'غير محدد';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final amPm = hour >= 12 ? 'م' : 'ص';
        final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '${formattedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
      }
    } catch (_) {}
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: _buildAppBar(context),
        body: BlocBuilder<DriverSubscriptionsCubit, DriverSubscriptionsState>(
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
                      Icon(Icons.error_outline_rounded, size: 60.sp, color: AppColors.error),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: AppTextStyles.style(fontSize: 15.sp, fontWeight: FontWeight.w600),
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

            if (state is DriverSubscriptionDetailLoaded) {
              final subscription = state.subscription;
              final child = subscription.child;
              final parent = subscription.parent;
              final contract = subscription.contract;
              final coords = subscription.coordinates;

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
                      // CARD 1: ملف الطفل (Child Profile)
                      _SectionCard(
                        icon: Icons.face_rounded,
                        iconColor: AppColors.success,
                        title: 'ملف الطالب',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 35.r,
                                  backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                                  backgroundImage: (child.photoUrl != null && child.photoUrl!.isNotEmpty)
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
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.bold,
                                            color: context.primaryColor,
                                          ),
                                        )
                                      : null,
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        child.displayName,
                                        style: AppTextStyles.style(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Row(
                                        children: [
                                          if (child.age != null) ...[
                                            Text(
                                              'العمر: ${child.age} سنة',
                                              style: AppTextStyles.style(
                                                fontSize: 12.sp,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                          ],
                                          if (child.grade != null)
                                            Text(
                                              'الصف: ${child.grade}',
                                              style: AppTextStyles.style(
                                                fontSize: 12.sp,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            const Divider(height: 1, thickness: 0.5),
                            SizedBox(height: 12.h),
                            _InfoRow(
                              icon: Icons.wc_rounded,
                              label: 'الجنس',
                              value: child.gender == 'male' ? 'ذكر' : (child.gender == 'female' ? 'أنثى' : 'غير متوفر'),
                            ),
                            _InfoRow(
                              icon: Icons.note_alt_rounded,
                              label: 'الملاحظات الطبية',
                              value: (child.notes == null || child.notes!.trim().isEmpty)
                                  ? 'لا توجد ملاحظات طبية'
                                  : child.notes!,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // CARD 2: معلومات ولي الأمر (Parent Info)
                      _SectionCard(
                        icon: Icons.family_restroom_rounded,
                        iconColor: AppColors.pending,
                        title: 'معلومات ولي الأمر',
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.person_rounded,
                              label: 'الاسم',
                              value: parent.name,
                            ),
                            if (parent.phone != null && parent.phone!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone_rounded, size: 16.sp, color: AppColors.textMuted),
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
                                        onTap: () => _makeCall(parent.phone!),
                                        borderRadius: BorderRadius.circular(4.r),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.phone_in_talk_rounded, size: 18.sp, color: AppColors.success),
                                      onPressed: () => _makeCall(parent.phone!),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            if (parent.email != null && parent.email!.isNotEmpty)
                              _InfoRow(
                                icon: Icons.email_rounded,
                                label: 'البريد الإلكتروني',
                                value: parent.email!,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // CARD 3: تفاصيل الرحلة (Trip Details)
                      _SectionCard(
                        icon: Icons.directions_bus_rounded,
                        iconColor: context.primaryColor,
                        title: 'تفاصيل الرحلة',
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.alt_route_rounded,
                              label: 'نوع الرحلة',
                              value: subscription.tripType == 'both'
                                  ? 'ذهاب وعودة'
                                  : (subscription.tripType == 'morning' ? 'ذهاب فقط' : 'عودة فقط'),
                            ),
                            _InfoRow(
                              icon: Icons.login_rounded,
                              label: 'وقت الانطلاق (الذهاب)',
                              value: _formatTimeArabic(subscription.pickupTime),
                            ),
                            _InfoRow(
                              icon: Icons.logout_rounded,
                              label: 'وقت الرجوع (العودة)',
                              value: _formatTimeArabic(subscription.dropoffTime),
                            ),
                            _InfoRow(
                              icon: Icons.home_rounded,
                              label: 'نقطة الصعود',
                              value: subscription.pickupLabel ?? 'غير محدد',
                            ),
                            _InfoRow(
                              icon: Icons.school_rounded,
                              label: 'نقطة النزول',
                              value: subscription.dropoffLabel ?? 'غير محدد',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // CARD 4: المواقع (Map Locations)
                      _SectionCard(
                        icon: Icons.map_rounded,
                        iconColor: AppColors.error,
                        title: 'المواقع الجغرافية',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // المنزل
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'موقع المنزل',
                                        style: AppTextStyles.style(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'العنوان: ${subscription.pickupLabel ?? "غير متوفر"}',
                                        style: AppTextStyles.style(
                                          fontSize: 12.sp,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      if (coords?.home?.latitude != null)
                                        Text(
                                          '${coords!.home!.latitude.toStringAsFixed(4)}, ${coords.home!.longitude.toStringAsFixed(4)}',
                                          style: AppTextStyles.style(
                                            fontSize: 11.sp,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (coords?.home?.latitude != null && coords?.home?.longitude != null)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success.withValues(alpha: 0.1),
                                      foregroundColor: AppColors.success,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                    ),
                                    icon: Icon(Icons.navigation_rounded, size: 14.sp),
                                    label: Text('خريطة', style: AppTextStyles.style(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.success)),
                                    onPressed: () => _openMap(coords!.home!.latitude, coords.home!.longitude),
                                  ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            const Divider(height: 1, thickness: 0.5),
                            SizedBox(height: 12.h),
                            // المدرسة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'موقع المدرسة',
                                        style: AppTextStyles.style(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'العنوان: ${subscription.dropoffLabel ?? "غير متوفر"}',
                                        style: AppTextStyles.style(
                                          fontSize: 12.sp,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      if (coords?.school?.latitude != null)
                                        Text(
                                          '${coords!.school!.latitude.toStringAsFixed(4)}, ${coords.school!.longitude.toStringAsFixed(4)}',
                                          style: AppTextStyles.style(
                                            fontSize: 11.sp,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (coords?.school?.latitude != null && coords?.school?.longitude != null)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success.withValues(alpha: 0.1),
                                      foregroundColor: AppColors.success,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                    ),
                                    icon: Icon(Icons.navigation_rounded, size: 14.sp),
                                    label: Text('خريطة', style: AppTextStyles.style(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.success)),
                                    onPressed: () => _openMap(coords!.school!.latitude, coords.school!.longitude),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // CARD 5: العقد والاشتراك (Contract & Finance)
                      if (contract != null) ...[
                        _SectionCard(
                          icon: Icons.assignment_rounded,
                          iconColor: AppColors.primaryLight,
                          title: 'بيانات العقد والمالية',
                          child: Column(
                            children: [
                              _InfoRow(
                                icon: Icons.receipt_rounded,
                                label: 'رقم العقد',
                                value: contract.contractNumber,
                              ),
                              _InfoRow(
                                icon: Icons.date_range_rounded,
                                label: 'مدة الاشتراك',
                                value: '${_formatDate(contract.startDate)} - ${_formatDate(contract.endDate)}',
                              ),
                              _InfoRow(
                                icon: Icons.calendar_month_rounded,
                                label: 'عدد أيام العمل الفعلية',
                                value: '${contract.totalWorkingDays} يوم',
                              ),
                              _InfoRow(
                                icon: Icons.monetization_on_rounded,
                                label: 'سعر الاشتراك',
                                value: '${contract.totalPrice} د.ل',
                              ),
                              _InfoRow(
                                icon: Icons.info_outline_rounded,
                                label: 'حالة العقد',
                                value: contract.status == 'active' ? 'مفعّل' : contract.status,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // CARD 6: معلومات إضافية (Additional Info)
                      _SectionCard(
                        icon: Icons.info_rounded,
                        iconColor: AppColors.grey600,
                        title: 'معلومات إضافية',
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'تاريخ الإنشاء',
                              value: _formatDate(subscription.createdAt),
                            ),
                            _InfoRow(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'حالة الاشتراك',
                              value: subscription.statusDisplayLabel,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
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
        icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.white, size: 20.sp),
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
          color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.12),
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
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.textMuted),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              color: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
