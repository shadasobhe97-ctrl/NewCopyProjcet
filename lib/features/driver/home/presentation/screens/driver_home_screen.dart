import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_section_header.dart';

// Components
import 'package:kids_transport/features/driver/work_areas/presentation/widgets/work_areas_card.dart';
import 'package:kids_transport/features/driver/home/presentation/widgets/welcome_guide_card.dart';
import 'package:kids_transport/features/driver/home/presentation/widgets/active_trip_card.dart';
import 'package:kids_transport/features/driver/home/presentation/widgets/driver_services_widget.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_card.dart';
import 'package:kids_transport/features/driver/requests/presentation/widgets/new_requests_section.dart';

import 'package:kids_transport/features/driver/home/logic/driver_home_cubit/driver_home_cubit.dart';
import 'package:kids_transport/features/driver/requests/logic/driver_location_change_cubit.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_emergency_cubit/driver_emergency_cubit.dart';
import 'package:kids_transport/features/driver/shared/di/driver_injection.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل بيانات الصفحة الرئيسية عند بدء الشاشة
    context.read<DriverHomeCubit>().loadDriverHomeData();
  }

  Future<void> _onRefresh() async {
    await context.read<DriverHomeCubit>().loadDriverHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverHomeCubit, DriverHomeState>(
      listener: (context, state) {
        if (state is DriverHomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final loadedState = state is DriverHomeLoaded ? state : null;

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  driverSl<DriverLocationChangeCubit>()..fetchPendingCount(),
            ),
            BlocProvider(
              create: (_) =>
                  driverSl<DriverEmergencyCubit>()..fetchAvailableCount(),
            ),
          ],
          child: Scaffold(
            body: SafeArea(
              child: state is DriverHomeLoading
                  ? const Center(child: CircularProgressIndicator())
                  : loadedState == null
                      ? const Center(child: Text('حدث خطأ في التحميل'))
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: AppColors.primaryLight,
                          child: _HomeBody(state: loadedState),
                        ),
            ),
          ),
        );
      },
    );
  }
}

/// جسم الشاشة الرئيسية - يعرض المكونات المنفصلة باستخدام البيانات من الـ State
class _HomeBody extends StatelessWidget {
  final DriverHomeLoaded state;

  const _HomeBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) كرت الترحيب الأزرق في أعلى الصفحة الرئيسية بدلاً من كرت الاتصال
          WelcomeGuideCard(
            driverName: state.driver.fullName,
            onDismiss: state.showFirstWelcome
                ? () => context.read<DriverHomeCubit>().dismissFirstWelcome()
                : null,
          ),
          const SizedBox(height: 20),

          // 2) قسم الخدمات السريعة للسائق
          const DriverServicesWidget(),
          const SizedBox(height: 20),

          // 3) كرت مناطق العمل
          const WorkAreasCard(),
          const SizedBox(height: 20),

          // 4) قسم رحلات اليوم — عرض أول رحلة مع زر عرض الكل
          AppSectionHeader(
            title: 'رحلات اليوم (${state.todayTrips.length})',
            actionWidget: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.driverTripsHistory,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'عرض الكل',
                  style: AppTextStyles.style(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (state.todayTrips.isNotEmpty)
            TripCard(
              trip: state.todayTrips.first,
              isStarting: false,
              onDetails: () => Navigator.pushNamed(
                context,
                AppRoutes.driverTripDetails,
                arguments: state.todayTrips.first.tripId,
              ),
              onStart: () => Navigator.pushNamed(
                context,
                AppRoutes.driverLiveTrip,
                arguments: state.todayTrips.first.tripId,
              ),
              onLive: () => Navigator.pushNamed(
                context,
                AppRoutes.driverLiveTrip,
                arguments: state.todayTrips.first.tripId,
              ),
            )
          else if (state.hasActiveTrip && state.activeTripId != null)
            InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.driverLiveTrip,
                arguments: state.activeTripId,
              ),
              borderRadius: BorderRadius.circular(20),
              child: const ActiveTripCard(hasActiveTrip: true),
            )
          else
            ActiveTripCard(hasActiveTrip: state.hasActiveTrip),
          const SizedBox(height: 24),

          // 5) قسم طلبات الاشتراك الجديدة — عرض أول طلب مع زر عرض الكل
          NewRequestsSection(
            requests: state.newRequests,
            onViewAll: () => Navigator.pushNamed(
              context,
              AppRoutes.driverLocationChangeRequests,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
