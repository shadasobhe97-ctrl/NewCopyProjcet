import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/home/logic/driver_home_cubit/driver_home_cubit.dart';
import 'package:kids_transport/features/driver/dashboard/presentation/widgets/driver_drawer.dart';
import 'package:kids_transport/features/driver/home/presentation/screens/driver_home_screen.dart';
import 'package:kids_transport/features/driver/requests/logic/driver_requests_cubit.dart';
import 'package:kids_transport/features/driver/requests/presentation/screens/driver_requests_screen.dart';
import 'package:kids_transport/features/driver/subscriptions/logic/driver_subscriptions_cubit.dart';
import 'package:kids_transport/features/driver/shared/di/driver_injection.dart';
import 'package:kids_transport/features/driver/finance/presentation/screens/finance_dashboard_screen.dart';
import 'package:kids_transport/features/driver/finance/presentation/logic/finance_cubit.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

// ==========================================
// الحاضن الرئيسي لشاشات السائق (نظير ParentMainWrapper)
// ==========================================

class DriverMainWrapper extends StatefulWidget {
  const DriverMainWrapper({super.key});

  @override
  State<DriverMainWrapper> createState() => _DriverMainWrapperState();
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});
  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _DriverMainWrapperState extends State<DriverMainWrapper> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      // الشاشة الرئيسية للسائق
      const DriverHomeScreen(),

      // TODO: استبدل هذه الشاشات بالشاشات الحقيقية عند إنشائها
      Center(
        child: Text(
          '🗺️ رحلاتي',
          style: AppTextStyles.style(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      BlocProvider(
        create: (_) => driverSl<FinanceCubit>(),
        child: const FinanceDashboardScreen(),
      ),
      // شاشة الطلبات الحقيقية مع Cubits للطلبات والاشتراكات
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => driverSl<DriverRequestsCubit>()),
          BlocProvider(create: (_) => driverSl<DriverSubscriptionsCubit>()),
        ],
        child: const DriverRequestsScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverHomeCubit()..loadDriverHomeData(),
      child: BlocBuilder<DriverHomeCubit, DriverHomeState>(
        builder: (context, state) {
          // استخراج بيانات السائق من الحالة لتمريرها للدروار
          final driver = state is DriverHomeLoaded ? state.driver : null;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: context.backgroundSurface,

              // AppBar الرئيسي
              appBar: _buildAppBar(context, state),

              // الدروار من جهة اليمين (في RTL يفتح من اليمين باستخدام drawer وليس endDrawer)
              drawer: driver != null ? DriverDrawer(driver: driver) : null,

              body: IndexedStack(
                index: _selectedIndex,
                children: _screens
                    .map((s) => _KeepAliveWrapper(child: s))
                    .toList(),
              ),

              // شريط التنقل السفلي - GNav أنيق واحترافي
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: context.cardSurface,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      color: Colors.black.withValues(
                        alpha: context.isDarkMode ? 0.3 : 0.05,
                      ),
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 10.0,
                    ),
                    child: GNav(
                      gap: 6,
                      activeColor: context.primaryColor,
                      iconSize: 22,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      duration: const Duration(milliseconds: 300),
                      tabBackgroundColor:
                          context.primaryColor.withValues(alpha: 0.1),
                      color: AppColors.grey400,
                      textStyle: AppTextStyles.style(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                      selectedIndex: _selectedIndex,
                      onTabChange: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      tabs: const [
                        GButton(icon: Icons.home_rounded, text: 'الرئيسية'),
                        GButton(icon: Icons.route_rounded, text: 'الرحلات'),
                        GButton(
                          icon: Icons.account_balance_wallet_rounded,
                          text: 'المحفظة',
                        ),
                        GButton(
                          icon: Icons.assignment_rounded,
                          text: 'الطلبات',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// بناء الـ AppBar (بسيط مثل واجهة ولي الأمر)
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DriverHomeState _,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        color: context.isDarkMode ? context.cardSurface : AppColors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: context.primaryColor,
                      size: 24,
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getAppBarTitle(),
                  style: AppTextStyles.style(
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: context.primaryColor,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: context.primaryColor,
                        size: 22,
                      ),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: AppTheme.boxDecoration(
                          color: context.errorColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'الرئيسية';
      case 1:
        return 'رحلاتي';
      case 2:
        return 'المحفظة';
      case 3:
        return 'الطلبات';
      default:
        return 'دربي';
    }
  }
}
