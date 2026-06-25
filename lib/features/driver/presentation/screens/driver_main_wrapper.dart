import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import '../../logic/driver_home_cubit/driver_home_cubit.dart';
import '../widgets/driver_drawer.dart';
import 'driver_home_screen.dart';

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
      const Center(
        child: Text('🗺️ رحلاتي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      const Center(
        child: Text('💰 المحفظة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      const Center(
        child: Text('📋 الطلبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => DriverHomeCubit()..loadDriverHomeData(),
      child: BlocBuilder<DriverHomeCubit, DriverHomeState>(
        builder: (context, state) {
          // استخراج بيانات السائق من الحالة لتمريرها للدروار
          final driver = state is DriverHomeLoaded ? state.driver : null;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor:
                  isDark ? const Color(0xFF0F0F0F) : AppColors.backgroundLight,

              // AppBar الرئيسي
              appBar: _buildAppBar(context, theme, isDark, state),

              // الدروار من جهة اليمين (في RTL يفتح من اليمين باستخدام drawer وليس endDrawer)
              drawer: driver != null
                  ? DriverDrawer(driver: driver)
                  : null,

              body: IndexedStack(
                index: _selectedIndex,
                children:
                    _screens.map((s) => _KeepAliveWrapper(child: s)).toList(),
              ),

              // شريط التنقل السفلي - نفس مكتبة convex_bottom_bar كالـ parent
              bottomNavigationBar: ConvexAppBar(
                style: TabStyle.reactCircle,
                backgroundColor:
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                activeColor: AppColors.primaryLight,
                color: Colors.grey[400],
                initialActiveIndex: _selectedIndex,
                height: 60,
                curveSize: 80,
                top: -20,
                items: const [
                  TabItem(icon: Icons.home_rounded, title: 'الرئيسية'),
                  TabItem(icon: Icons.route_rounded, title: 'الرحلات'),
                  TabItem(icon: Icons.account_balance_wallet_rounded, title: 'المحفظة'),
                  TabItem(icon: Icons.assignment_rounded, title: 'الطلبات'),
                ],
                onTap: (int index) {
                  setState(() => _selectedIndex = index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// بناء الـ AppBar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    DriverHomeState state,
  ) {
    final isHome = _selectedIndex == 0;
    final gradientColors = isDark
        ? [const Color(0xFF1A2332), const Color(0xFF0F172A)]
        : [AppColors.primaryLight, const Color(0xFF0E78C4)];

    // اسم السائق للتحية
    // TODO: استبدل بالاسم الحقيقي من الـ API
    final driverName = state is DriverHomeLoaded
        ? state.driver.fullName
        : 'السائق';

    return PreferredSize(
      preferredSize: Size.fromHeight(isHome ? 100 : 64),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withOpacity(isDark ? 0.1 : 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(isHome ? 24 : 0),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: isHome
                ? _buildHomeHeader(context, driverName)
                : _buildStandardHeader(context),
          ),
        ),
      ),
    );
  }

  /// هيدر الشاشة الرئيسية مع التحية
  Widget _buildHomeHeader(BuildContext context, String driverName) {
    return Row(
      children: [
        // زر القائمة الجانبية - يفتح الـ drawer العادي ليكون من اليمين
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        const SizedBox(width: 8),

        // نص الترحيب - وسط/متمدد
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: استبدل النص باسم السائق الحقيقي القادم من الـ API
              Text(
                'مرحباً، $driverName 👋',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              const Text(
                'لوحة تحكم السائق',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),

        // زر المحادثة - جهة اليسار
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded,
              color: Colors.white, size: 22),
          onPressed: () {
            // TODO: التوجيه لشاشة المحادثات
          },
        ),

        // زر الإشعارات مع نقطة تنبيه حمراء
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: Colors.white, size: 24),
              onPressed: () {
                // TODO: التوجيه لشاشة الإشعارات
              },
            ),
            // نقطة الإشعار الحمراء
            // TODO: اجعل هذه النقطة مشروطة بوجود إشعارات غير مقروءة
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// هيدر كلاسيكي للشاشات الأخرى
  Widget _buildStandardHeader(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _getAppBarTitle(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded,
              color: Colors.white, size: 24),
          onPressed: () {
            // TODO: التوجيه لشاشة الإشعارات
          },
        ),
      ],
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
