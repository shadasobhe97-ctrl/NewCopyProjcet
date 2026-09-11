import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/trips/logic/active_trip_cubit/active_trip_cubit.dart';

import 'package:kids_transport/features/parent/home/presentation/widgets/welcome_header_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/home_search_section_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/top_card_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/children_section_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/quick_services_widget.dart';
import 'package:kids_transport/features/parent/search/presentation/screens/parent_search_screen.dart';

/// الشاشة الأساسية لولي الأمر (DARBI Parent Home Screen)
/// مكونة بدقة من 4 أقسام رئيسية:
/// 1️⃣ قسم الترحيب + كرت تتبع الرحلة المدمج الذكي (المتصل بالـ ActiveTripCubit)
/// 2️⃣ قسم البحث المباشر (حقل البحث الدائري + فاصل "أو" + زر البحث الدائري بالأزرق الداكن)
/// 3️⃣ قسم أطفالي (كروت بيضاوية كبسولية أنيقة ومودرن)
/// 4️⃣ قسم الخدمات السريعة (محفوظة بكامل وظائفها)
///
/// عند الضغط على البحث، يتحول العرض لوضع البحث الموسّع بكامل إمكانياته وفلاتره مع زر رجوع سلس.
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

/// 🏠 HomeScreenBody - الويدجت الرئيسي لمحتوى الشاشة الرئيسية مع إدارة وضع البحث الموسع
class HomeScreenBody extends StatefulWidget {
  final Future<void> Function()? onRefresh;

  const HomeScreenBody({super.key, this.onRefresh});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  bool _isSearchActive = false;
  String? _initialSearchQuery;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChildrenCubit>().fetchChildren();
        context.read<ActiveTripCubit>().loadActiveTrips();
      }
    });
  }

  void _enterSearchMode({String? query}) {
    setState(() {
      _isSearchActive = true;
      _initialSearchQuery = query;
    });
  }

  void _exitSearchMode() {
    setState(() {
      _isSearchActive = false;
      _initialSearchQuery = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return PopScope(
      canPop: !_isSearchActive,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSearchActive) {
          _exitSearchMode();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _isSearchActive
            // 🔍 وضع البحث الموسّع الكامل داخل الهوم سكرين مع زر الرجوع
            ? ParentSearchScreen(
                key: const ValueKey('expanded_search'),
                isEmbedded: true,
                autoFocus: true,
                initialQuery: _initialSearchQuery,
                onBack: _exitSearchMode,
              )
            // 🏠 الواجهة الرئيسية المكونة بدقة من الأقسام الأربعة
            : RefreshIndicator(
                key: const ValueKey('home_sections'),
                onRefresh: widget.onRefresh ??
                    () async {
                      await Future.wait([
                        context.read<ChildrenCubit>().fetchChildren(),
                        context.read<ActiveTripCubit>().loadActiveTrips(),
                      ]);
                    },
                color: primaryColor,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  children: [
                    // 👋 1️⃣ قسم الترحيب البسيط + كرت تتبع الرحلة المدمج الذكي
                    const WelcomeHeaderWidget(),
                    SizedBox(height: 8.h),
                    const TopCardWidget(),
                    SizedBox(height: 18.h),

                    // 🔍 2️⃣ قسم البحث المباشر (حقل دائري + فاصل أو + زر بحث دائري بالأزرق الداكن)
                    HomeSearchSectionWidget(
                      onTapSearch: () => _enterSearchMode(),
                      onTapSmartSearch: () => _enterSearchMode(),
                      onSubmitQuery: (query) => _enterSearchMode(query: query),
                    ),
                    SizedBox(height: 20.h),

                    // 👶 3️⃣ قسم أطفالي (كروت بيضاوية كبسولية أنيقة ومودرن)
                    const ChildrenSectionWidget(),
                    SizedBox(height: 20.h),

                    // ⚡ 4️⃣ قسم الخدمات السريعة (محفوظ بكامله دون حذف)
                    const QuickServicesWidget(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
      ),
    );
  }
}
