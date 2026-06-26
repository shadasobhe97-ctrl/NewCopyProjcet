import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/features/parent/logic/home_cubit/home_cubit.dart';
import 'package:kids_transport/features/parent/logic/child_cubit/child_cubit.dart';
import '../widgets/parent_drawer.dart';
import 'parent_home_screen.dart';
import 'parent_search_screen.dart';
import 'my_children_screen.dart';

class ParentMainWrapper extends StatefulWidget {
  const ParentMainWrapper({super.key});

  @override
  State<ParentMainWrapper> createState() => _ParentMainWrapperState();
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

class _ParentMainWrapperState extends State<ParentMainWrapper> {
  int _selectedIndex = 0;

  // دالة ستاتيكية للتحكم في تغيير التبويبات من الشاشات الداخلية
  static late Function(int) changeTab;

  // محاكاة بيانات المستخدم (تُستبدل بالـ Repository لاحقاً)
  final String userName = "أسماء الفرجاني";
  final String? userAvatarurl = null;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    changeTab = (index) {
      setState(() => _selectedIndex = index);
    };
    _screens = [
      const ParentHomeScreen(),
      const MyChildrenScreen(),
      const ParentSearchScreen(),
      const Center(
          child: Text("📄 العقود والاشتراكات",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      const Center(
          child: Text("💳 المدفوعات والفواتير",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ParentHomeCubit()..fetchParentHomeData(4),
        ),
        BlocProvider(
          create: (context) => ChildCubit()..loadChildren(),
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F0F0F) : AppColors.backgroundLight,

          // ✅ AppBar مُوحد ومصمم بلمسة احترافية
          appBar: _buildAppBar(context, theme, isDark),

          // الدروار يفتح من جهة اليمين (drawer في RTL)
          drawer: const ParentDrawer(),

          body: IndexedStack(
            index: _selectedIndex,
            children:
                _screens.map((s) => _KeepAliveWrapper(child: s)).toList(),
          ),

          bottomNavigationBar: ConvexAppBar(
            style: TabStyle.reactCircle,
            backgroundColor:
                isDark ? const Color(0xFF1E293B) : Colors.white,
            activeColor: AppColors.primaryLight,
            color: Colors.grey[400],
            initialActiveIndex: _selectedIndex,
            height: 52, // 🌟 تقليص الحجم ليكون أنيقاً وحديثاً
            curveSize: 72, // 🌟 مقاس منحنى أصغر
            top: -14, // 🌟 تقليص الارتفاع العلوي
            items: const [
              TabItem(icon: Icons.home_rounded, title: 'الرئيسية'),
              TabItem(icon: Icons.people_alt_rounded, title: 'أطفالي'),
              TabItem(icon: Icons.search_rounded, title: 'البحث'),
              TabItem(icon: Icons.description_rounded, title: 'العقود'),
              TabItem(icon: Icons.credit_card_rounded, title: 'المدفوعات'),
            ],
            onTap: (int index) {
              setState(() => _selectedIndex = index);
            },
          ),
        ),
      ),
    );
  }

  /// ✅ بناء الـ AppBar الموحد بشكل احترافي مع تدرج لوني
  PreferredSizeWidget _buildAppBar(
      BuildContext context, ThemeData theme, bool isDark) {
    final gradientColors = isDark
        ? [const Color(0xFF1A2332), const Color(0xFF0F172A)]
        : [AppColors.primaryLight, const Color(0xFF0D6EAD)];

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withValues(alpha: isDark ? 0.1 : 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // زر الدروار (يفتح من اليمين في RTL)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),

                // شعار التطبيق الأنيق (بدون اسم الصفحة)
                const Row(
                  children: [
                    Icon(Icons.directions_bus_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "داربي",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // أيقونة الرسائل
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () {},
                ),

                // أيقونة الإشعارات مع نقطة التنبيه الحمراء
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: Colors.white, size: 22),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
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
}