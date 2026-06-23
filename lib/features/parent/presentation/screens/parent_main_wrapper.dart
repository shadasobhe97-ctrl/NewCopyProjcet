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
  final String _userName = "أسماء الفرجاني";
  final String? _userAvatarUrl = null;

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

          // ✅ AppBar مُصلح وكامل - PreferredSize ثابت
          appBar: _buildAppBar(context, theme, isDark),

          // الدروار من جهة اليمين (endDrawer = يفتح من اليمين في RTL)
          endDrawer: const ParentDrawer(),

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
            height: 60,
            curveSize: 80,
            top: -20,
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

  /// ✅ بناء الـ AppBar بشكل صحيح بدون أخطاء
  PreferredSizeWidget _buildAppBar(
      BuildContext context, ThemeData theme, bool isDark) {
    final isHome = _selectedIndex == 0;

    final gradientColors = isDark
        ? [const Color(0xFF1A2332), const Color(0xFF0F172A)]
        : [AppColors.primaryLight, const Color(0xFF0E78C4)];

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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: isHome
                ? _buildExtendedMainHeader(context)
                : _buildStandardHeader(context),
          ),
        ),
      ),
    );
  }

  /// هيدر الصفحة الرئيسية (كبير مع ترحيب)
  Widget _buildExtendedMainHeader(BuildContext context) {
    return Row(
      children: [
        // زر الدروار
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
        const SizedBox(width: 8),
        // أفاتار المستخدم
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white.withOpacity(0.2),
          backgroundImage:
              _userAvatarUrl != null ? NetworkImage(_userAvatarUrl!) : null,
          child: _userAvatarUrl == null
              ? const Icon(Icons.person_rounded, color: Colors.white, size: 20)
              : null,
        ),
        const SizedBox(width: 10),
        // نص الترحيب
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "مرحباً، $_userName 👋",
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              const Text(
                "لوحة التحكم",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ],
          ),
        ),
        // أيقونة الرسائل
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded,
              color: Colors.white, size: 22),
          onPressed: () {},
        ),
        // أيقونة الإشعارات مع نقطة تنبيه
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: Colors.white, size: 24),
              onPressed: () {},
            ),
            // ✅ نقطة الإشعار داخل Stack بشكل صحيح
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
          onPressed: () {},
        ),
      ],
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return "الرئيسية";
      case 1:
        return "أطفالي";
      case 2:
        return "استكشاف السائقين";
      case 3:
        return "العقود والتوثيق";
      case 4:
        return "المحفظة الرقمية";
      default:
        return "داربي";
    }
  }
}