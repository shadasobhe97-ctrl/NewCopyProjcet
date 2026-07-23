import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

// Components
import 'package:kids_transport/features/driver/home/presentation/widgets/online_status_card.dart';
import 'package:kids_transport/features/driver/work_areas/presentation/widgets/work_areas_card.dart';
import 'package:kids_transport/features/driver/home/presentation/widgets/welcome_guide_card.dart';
import 'package:kids_transport/features/driver/home/presentation/widgets/daily_stats_row.dart';
import 'package:kids_transport/features/driver/home/presentation/widgets/active_trip_card.dart';
import 'package:kids_transport/features/driver/requests/presentation/widgets/new_requests_section.dart';

import 'package:kids_transport/features/driver/home/logic/driver_home_cubit/driver_home_cubit.dart';

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

        return Scaffold(
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
    final isNewDriver = state.newRequests.isEmpty && !state.hasActiveTrip;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // كرت حالة الاتصال (متصل/غير متصل)
          OnlineStatusCard(isOnline: state.isOnline),
          const SizedBox(height: 24),

          // إرشاد ترحيبي للسائق الجديد (إذا لم يكن هناك رحلات أو طلبات)
          if (isNewDriver) ...[
            WelcomeGuideCard(driverName: state.driver.fullName),
            const SizedBox(height: 24),
          ],

          // كرت مناطق العمل
          const WorkAreasCard(),
          const SizedBox(height: 24),

          // إحصائيات سريعة (رحلات وطلاب اليوم)
          DailyStatsRow(
            tripsCount: state.todayTripsCount,
            studentsCount: state.todayStudentsCount,
          ),
          const SizedBox(height: 30),

          // قسم الرحلة الحالية
          ActiveTripCard(hasActiveTrip: state.hasActiveTrip),
          const SizedBox(height: 30),

          // قسم طلبات الاشتراك الجديدة
          NewRequestsSection(requests: state.newRequests),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
