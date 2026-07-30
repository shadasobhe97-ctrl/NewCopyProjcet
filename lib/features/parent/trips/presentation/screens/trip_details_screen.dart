import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import '../../data/models/trip_details_model.dart';
import '../../data/models/active_trip_model.dart';
import '../../logic/trip_details_cubit/trip_details_cubit.dart';
import '../../logic/trip_details_cubit/trip_details_state.dart';
import 'trip_timeline_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final dynamic tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late final TripDetailsCubit _detailsCubit;

  @override
  void initState() {
    super.initState();
    _detailsCubit = getIt<TripDetailsCubit>()..loadTripDetails(widget.tripId);
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendMessage(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'تفاصيل الرحلة #${widget.tripId}',
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
        ),
        body: BlocProvider.value(
          value: _detailsCubit,
          child: BlocBuilder<TripDetailsCubit, TripDetailsState>(
            builder: (context, state) {
              if (state is TripDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TripDetailsError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Text(
                      'تعذر تحميل تفاصيل الرحلة: ${state.message}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.style(color: AppColors.error),
                    ),
                  ),
                );
              } else if (state is TripDetailsLoaded) {
                final details = state.tripDetails;
                return _buildDetailsContent(context, details, isDark);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context, TripDetailsModel details, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Driver Card
          _buildCardContainer(
            context,
            isDark: isDark,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: details.driver.photo != null && details.driver.photo!.isNotEmpty
                      ? CachedNetworkImageProvider(details.driver.photo!)
                      : null,
                  child: details.driver.photo == null || details.driver.photo!.isEmpty
                      ? Icon(Icons.person_rounded, size: 30.r, color: context.primaryColor)
                      : null,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'السائق',
                        style: AppTextStyles.style(fontSize: 11.sp, color: AppColors.textMuted),
                      ),
                      Text(
                        details.driver.name.isNotEmpty ? details.driver.name : 'السائق المعين',
                        style: AppTextStyles.style(fontSize: 15.sp, fontWeight: FontWeight.bold, color: context.textPrimary),
                      ),
                      if (details.driver.phone.isNotEmpty)
                        Text(
                          details.driver.phone,
                          style: AppTextStyles.style(fontSize: 12.sp, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
                if (details.driver.phone.isNotEmpty) ...[
                  IconButton(
                    onPressed: () => _makeCall(details.driver.phone),
                    style: IconButton.styleFrom(backgroundColor: AppColors.success.withValues(alpha: 0.12)),
                    icon: const Icon(Icons.phone_rounded, color: AppColors.success, size: 20),
                  ),
                  IconButton(
                    onPressed: () => _sendMessage(details.driver.phone),
                    style: IconButton.styleFrom(backgroundColor: context.primaryColor.withValues(alpha: 0.12)),
                    icon: Icon(Icons.chat_rounded, color: context.primaryColor, size: 20),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // 2. Vehicle Card
          _buildCardContainer(
            context,
            isDark: isDark,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_bus_rounded, color: AppColors.amber, size: 24.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المركبة والمعلومات',
                        style: AppTextStyles.style(fontSize: 11.sp, color: AppColors.textMuted),
                      ),
                      Text(
                        details.vehicle.info,
                        style: AppTextStyles.style(fontSize: 14.sp, fontWeight: FontWeight.bold, color: context.textPrimary),
                      ),
                      if (details.vehicle.plateNumber != null)
                        Text(
                          'رقم اللوحة: ${details.vehicle.plateNumber}',
                          style: AppTextStyles.style(fontSize: 12.sp, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // 3. Destination Card
          _buildCardContainer(
            context,
            isDark: isDark,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    details.destination.type == 'home' ? Icons.home_rounded : Icons.school_rounded,
                    color: AppColors.red,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوجهة المقررة',
                        style: AppTextStyles.style(fontSize: 11.sp, color: AppColors.textMuted),
                      ),
                      Text(
                        details.destination.name,
                        style: AppTextStyles.style(fontSize: 14.sp, fontWeight: FontWeight.bold, color: context.textPrimary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _openGoogleMaps(details.destination.lat, details.destination.lng),
                  style: IconButton.styleFrom(backgroundColor: context.primaryColor.withValues(alpha: 0.12)),
                  icon: Icon(Icons.map_rounded, color: context.primaryColor, size: 20),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // 4. Trip Summary (Distance, Duration, Status)
          _buildCardContainer(
            context,
            isDark: isDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCol('المسافة المقدرة', details.totalDistance ?? '12.4 كم', Icons.route_rounded, context),
                Container(width: 1.w, height: 35.h, color: isDark ? AppColors.grey700 : AppColors.grey300),
                _buildSummaryCol('الوقت المتوقع', details.estimatedDuration ?? '25 دقيقة', Icons.timer_outlined, context),
                Container(width: 1.w, height: 35.h, color: isDark ? AppColors.grey700 : AppColors.grey300),
                _buildSummaryCol('وقت البدء', details.startedAt, Icons.access_time_rounded, context),
              ],
            ),
          ),
          SizedBox(height: 18.h),

          // 5. Children List
          Text(
            'الأطفال المشمولين بالرحلة (${details.children.length}):',
            style: AppTextStyles.style(fontSize: 14.sp, fontWeight: FontWeight.bold, color: context.textPrimary),
          ),
          SizedBox(height: 10.h),

          ...details.children.map((child) => _buildChildTile(context, child, isDark)),

          SizedBox(height: 24.h),

          // 6. View Full Timeline Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripTimelineScreen(
                      tripTitle: details.destination.name,
                      timelineItems: details.timeline,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: const Icon(Icons.timeline_rounded, size: 20),
              label: Text(
                'عرض Timeline الرحلة بالكامل',
                style: AppTextStyles.style(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer(BuildContext context, {required bool isDark, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSummaryCol(String label, String value, IconData icon, BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20.r, color: context.primaryColor),
        SizedBox(height: 4.h),
        Text(value, style: AppTextStyles.style(fontSize: 13.sp, fontWeight: FontWeight.bold, color: context.textPrimary)),
        SizedBox(height: 2.h),
        Text(label, style: AppTextStyles.style(fontSize: 10.sp, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildChildTile(BuildContext context, TripChildInfo child, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: context.primaryColor.withValues(alpha: 0.1),
            backgroundImage: child.childPhoto != null && child.childPhoto!.isNotEmpty
                ? CachedNetworkImageProvider(child.childPhoto!)
                : null,
            child: child.childPhoto == null || child.childPhoto!.isEmpty
                ? Icon(Icons.person_rounded, size: 18.r, color: context.primaryColor)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              child.childName,
              style: AppTextStyles.style(fontSize: 13.sp, fontWeight: FontWeight.bold, color: context.textPrimary),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              child.childStatus.isNotEmpty ? child.childStatus : 'داخل الحافلة',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
