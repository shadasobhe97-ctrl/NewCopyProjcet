import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/widgets/parent_drawer.dart';
import 'package:kids_transport/features/parent/home/presentation/screens/parent_home_screen.dart';
import 'package:kids_transport/features/parent/search/presentation/screens/parent_search_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/my_children_screen.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

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

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0: return 'الرئيسية';
      case 1: return 'أطفالي';
      case 2: return 'البحث عن سائق';
      case 3: return 'العقود والاشتراكات';
      case 4: return 'المدفوعات والفواتير';
      default: return 'داربي';
    }
  }

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
      Center(
        child: Text(
          "📄 العقود والاشتراكات",
          style: AppTextStyles.style(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      Center(
        child: Text(
          "💳 المدفوعات والفواتير",
          style: AppTextStyles.style(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,

        // ✅ AppBar مُوحد ومصمم بلمسة احترافية
        appBar: _buildAppBar(context),

        // الدروار يفتح من جهة اليمين (drawer في RTL)
        drawer: const ParentDrawer(),

        body: IndexedStack(
          index: _selectedIndex,
          children: _screens.map((s) => _KeepAliveWrapper(child: s)).toList(),
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.cardSurface,
            boxShadow: [
              BoxShadow(
                blurRadius: 15,
                color: Colors.black.withValues(alpha: context.isDarkMode ? 0.3 : 0.05),
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: GNav(
                gap: 6,
                activeColor: context.primaryColor,
                iconSize: 22,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                duration: const Duration(milliseconds: 300),
                tabBackgroundColor: context.primaryColor.withValues(alpha: 0.1),
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
                  GButton(icon: Icons.people_alt_rounded, text: 'أطفالي'),
                  GButton(icon: Icons.search_rounded, text: 'البحث'),
                  GButton(icon: Icons.description_rounded, text: 'العقود'),
                  GButton(icon: Icons.credit_card_rounded, text: 'المدفوعات'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ بناء الـ AppBar الموحد بشكل احترافي مع تدرج لوني
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: AppTheme.boxDecoration(
          gradient: AppTheme.linearGradient(
            colors: context.primaryGradient,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            AppTheme.boxShadow(
              color: context.primaryColor.withValues(
                alpha: context.isDarkMode ? 0.1 : 0.3,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // زر الدروار (يفتح من اليمين في RTL)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),

                // عنوان التطبيق الديناميكي
                Row(
                  children: [
                    Text(
                      _getAppBarTitle(),
                      style: AppTextStyles.style(
                        color: AppColors.white,
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
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  onPressed: () {},
                ),

                // أيقونة الإشعارات مع نقطة التنبيه الحمراء
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.white,
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
}
