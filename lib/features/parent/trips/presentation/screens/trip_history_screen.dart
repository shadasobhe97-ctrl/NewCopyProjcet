import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import '../../data/models/trip_history_model.dart';
import '../../logic/trip_history_cubit/trip_history_cubit.dart';
import '../../logic/trip_history_cubit/trip_history_state.dart';

class TripHistoryScreen extends StatefulWidget {
  final List<TripHistoryModel>? historyTrips;

  const TripHistoryScreen({
    super.key,
    this.historyTrips,
  });

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  String _selectedDirectionFilter = 'all'; // 'all', 'to_school', 'to_home'
  final Set<int> _expandedTripIds = {};

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'سجل الرحلات السابقة',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: context.textPrimary,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? context.cardSurface : AppColors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.textPrimary,
              size: 18.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // 🌟 FULL-WIDTH DROPDOWN FILTER CONTAINER (SPANNING FULL SCREEN WIDTH)
            _buildFullWidthDropdownFilter(context, isDark),

            Expanded(
              child: widget.historyTrips != null
                  ? _buildHistoryList(widget.historyTrips!, isDark)
                  : BlocProvider(
                      create: (context) => getIt<TripHistoryCubit>()..loadHistory(),
                      child: BlocBuilder<TripHistoryCubit, TripHistoryState>(
                        builder: (context, state) {
                          if (state is TripHistoryLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is TripHistoryError) {
                            return Center(
                              child: Text(
                                state.message,
                                style: AppTextStyles.style(color: AppColors.error),
                              ),
                            );
                          } else if (state is TripHistoryLoaded) {
                            return _buildHistoryList(state.historyTrips, isDark);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Full-Width Dropdown Filter (Edge-to-Edge)
  Widget _buildFullWidthDropdownFilter(BuildContext context, bool isDark) {
    final List<Map<String, String>> filterOptions = [
      {'value': 'all', 'label': 'جميع الرحلات السابقة'},
      {'value': 'to_school', 'label': 'رحلات الذهاب (إلى المدرسة)'},
      {'value': 'to_home', 'label': 'رحلات العودة (إلى المنزل)'},
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedDirectionFilter,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.primaryColor, size: 22.r),
          items: filterOptions.map((opt) {
            return DropdownMenuItem<String>(
              value: opt['value'],
              child: Row(
                children: [
                  Icon(
                    opt['value'] == 'to_school'
                        ? Icons.school_rounded
                        : (opt['value'] == 'to_home' ? Icons.home_rounded : Icons.history_rounded),
                    color: context.primaryColor,
                    size: 18.r,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    opt['label']!,
                    style: AppTextStyles.style(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedDirectionFilter = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<TripHistoryModel> trips, bool isDark) {
    final filtered = trips.where((t) {
      if (_selectedDirectionFilter == 'all') return true;
      return t.direction == _selectedDirectionFilter;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'لا توجد رحلات مكتملة تطابق التصفية',
          style: AppTextStyles.style(
            fontSize: 13.sp,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => SizedBox(height: 14.h),
      itemBuilder: (context, index) {
        final trip = filtered[index];
        final isExpanded = _expandedTripIds.contains(trip.tripId);
        return _buildExpandableHistoryCard(context, trip, isExpanded, isDark);
      },
    );
  }

  // 🌟 EXPANDABLE TRIP HISTORY CARD (NO SEPARATE DETAILS PAGE, INLINE EXPANSION)
  Widget _buildExpandableHistoryCard(
    BuildContext context,
    TripHistoryModel trip,
    bool isExpanded,
    bool isDark,
  ) {
    final isToSchool = trip.direction == 'to_school';
    final totalCost = trip.children.isNotEmpty ? trip.children.length * 15 : 30;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Trip Type, Date & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isToSchool ? 'رحلة الذهاب' : 'رحلة العودة',
                style: AppTextStyles.style(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'تم الاستلام',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            trip.tripDate,
            style: AppTextStyles.style(
              fontSize: 10.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 8.h),

          // Driver Name
          Row(
            children: [
              Icon(Icons.person_rounded, size: 14.r, color: AppColors.textMuted),
              SizedBox(width: 6.w),
              Text(
                'السائق: ${trip.driverName}',
                style: AppTextStyles.style(
                  fontSize: 11.sp,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          Divider(height: 16.h, thickness: 1),

          // Children List (Collapsed View)
          Text(
            'الأطفال (${trip.children.length}):',
            style: AppTextStyles.style(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 6.h),
          ...trip.children.map((c) {
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  AppUserAvatar(imageUrl: c.childPhoto, radius: 10.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.childName,
                          style: AppTextStyles.style(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        Text(
                          'مدرسة الجيل الجديد الدولية',
                          style: AppTextStyles.style(
                            fontSize: 9.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 8.h),

          // 🌟 EXPANDED DETAILS (In-place inline cost breakdown)
          if (isExpanded) ...[
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey900 : AppColors.grey50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل التكلفة والتسعير:',
                    style: AppTextStyles.style(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  ...trip.children.map((c) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            c.childName,
                            style: AppTextStyles.style(
                              fontSize: 10.sp,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            '15 LYD',
                            style: AppTextStyles.style(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 10.h),
          ],

          // Total Cost & Expand Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'إجمالي الرحلة: ',
                    style: AppTextStyles.style(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '$totalCost LYD',
                    style: AppTextStyles.style(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedTripIds.remove(trip.tripId);
                    } else {
                      _expandedTripIds.add(trip.tripId);
                    }
                  });
                },
                child: Row(
                  children: [
                    Text(
                      isExpanded ? 'عرض أقل' : 'عرض المزيد',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      size: 18.r,
                      color: context.primaryColor,
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
}
