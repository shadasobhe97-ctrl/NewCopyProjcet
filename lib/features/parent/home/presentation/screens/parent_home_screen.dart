import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';

import 'package:kids_transport/features/parent/home/presentation/widgets/welcome_header_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/search_action_cards_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/top_card_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/children_section_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/quick_services_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/notifications_widget.dart';

/// الشاشة الأساسية (نفس الاسم الذي يبحث عنه الـ Router والـ Wrapper)
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFF8FAFC),
        body: const SafeArea(
          child: HomeScreenBody(),
        ),
      ),
    );
  }
}

/// 🏠 HomeScreenBody - الويدجت الرئيسي لمحتوى الشاشة الرئيسية
class HomeScreenBody extends StatefulWidget {
  final Future<void> Function()? onRefresh;

  const HomeScreenBody({super.key, this.onRefresh});

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

    return RefreshIndicator(
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
          // 👋 1) قسم الترحيب البسيط
          const WelcomeHeaderWidget(),
          SizedBox(height: 16.h),

          // 🔍 2) إجراءات البحث الرئيسية (البحث عن سائق للاشتراك + البحث السريع لليوم)
          const SearchActionCardsWidget(),
          SizedBox(height: 18.h),

          // 🧠 3) قسم الرحلة النشطة (يعرض الكارد فقط عند وجود رحلة نشطة، وحالة خفيفة جداً عند عدم وجودها)
          const TopCardWidget(hasTrips: hasTrips),
          SizedBox(height: 18.h),

          // 👶 4) قسم الأطفال (ديناميكي مع إظهار حالة الاشتراك)
          const ChildrenSectionWidget(),
          SizedBox(height: 18.h),

          // 🔔 5) قسم الإشعارات المهمة
          const NotificationsWidget(hasNotifications: hasNotifications),
          SizedBox(height: 18.h),

          // ⚡ 6) قسم الخدمات السريعة (محفوظ بكامله دون حذف)
          const QuickServicesWidget(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

