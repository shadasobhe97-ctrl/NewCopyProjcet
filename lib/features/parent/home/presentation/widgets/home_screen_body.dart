import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/welcome_header_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/search_action_cards_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/top_card_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/children_section_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/quick_services_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/notifications_widget.dart';

class HomeScreenBody extends StatefulWidget {
  final Future<void> Function()? onRefresh;

  const HomeScreenBody({
    super.key,
    this.onRefresh,
  });

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChildrenCubit>().fetchChildren();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    const bool hasTrips = true;
    const bool hasNotifications = false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        onRefresh: widget.onRefresh ??
            () async {
              await context.read<ChildrenCubit>().fetchChildren();
            },
        color: primaryColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            // 👋 1) قسم الترحيب
            const WelcomeHeaderWidget(),
            SizedBox(height: 16.h),

            // 🔍 2) كروت البحث الرئيسية (البحث للاشتراك + البحث السريع)
            const SearchActionCardsWidget(),
            SizedBox(height: 18.h),

            // 🧠 3) قسم الرحلة النشطة
            const TopCardWidget(hasTrips: hasTrips),
            SizedBox(height: 18.h),

            // 👶 4) قسم الأطفال
            const ChildrenSectionWidget(),
            SizedBox(height: 18.h),

            // 🔔 5) قسم الإشعارات
            const NotificationsWidget(hasNotifications: hasNotifications),
            SizedBox(height: 18.h),

            // ⚡ 6) قسم الخدمات السريعة (محفوظ بالكامل)
            const QuickServicesWidget(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}