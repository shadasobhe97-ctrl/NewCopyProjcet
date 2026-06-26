import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/features/admin/logic/admin_dashboard_provider.dart';
import 'package:kids_transport/features/admin/logic/admin_auth_provider.dart';

class AdminSidebar extends StatelessWidget {
  final bool isDrawer;
  
  const AdminSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    final bool isCollapsed = dashboardProvider.isSidebarCollapsed && !isDrawer;
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = themeState.isDarkMode;

    // القوائم المطلوبة
    final menuItems = [
      {'title': 'الشاشة الرئيسية', 'icon': Icons.dashboard},
      {'title': 'إدارة السائقين', 'icon': Icons.directions_car},
      {'title': 'إدارة الاشتراكات', 'icon': Icons.subscriptions},
      {'title': 'إدارة الشكاوي', 'icon': Icons.report_problem, 'color': Colors.red},
      {'title': 'مراقبة الرحلات', 'icon': Icons.map},
      {'title': 'تنبيهات الطوارئ', 'icon': Icons.warning},
      {'title': 'إدارة التقارير', 'icon': Icons.analytics},
      {'title': 'إضافة موظف جديد', 'icon': Icons.person_add},
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 250,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // رأس السايد بار (ثيم + تصغير)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed)
                  const Expanded(
                    child: Text(
                      'لوحة الإدارة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (!isCollapsed)
                  IconButton(
                    icon: Icon(isDark ? Icons.nights_stay : Icons.wb_sunny, color: isDark ? Colors.amber : Colors.orange),
                    onPressed: () {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                if (!isDrawer)
                  IconButton(
                    icon: Icon(isCollapsed ? Icons.menu : Icons.chevron_left),
                    onPressed: () => dashboardProvider.toggleSidebar(),
                  ),
              ],
            ),
          ),
          
          // أيقونة الثيم في حالة التصغير
          if (isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: IconButton(
                icon: Icon(isDark ? Icons.nights_stay : Icons.wb_sunny, color: isDark ? Colors.amber : Colors.orange),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ),
          
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = dashboardProvider.selectedSidebarIndex == index;
                final customColor = menuItems[index]['color'] as Color?;
                
                return Tooltip(
                  message: isCollapsed ? menuItems[index]['title'] as String : '',
                  child: ListTile(
                    contentPadding: isCollapsed ? const EdgeInsets.symmetric(horizontal: 16.0) : const EdgeInsets.symmetric(horizontal: 16.0),
                    leading: Icon(
                      menuItems[index]['icon'] as IconData,
                      color: isSelected 
                          ? AppColors.primaryLight 
                          : (customColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                    ),
                    title: isCollapsed 
                        ? null 
                        : Text(
                            menuItems[index]['title'] as String,
                            style: TextStyle(
                              color: isSelected 
                                  ? AppColors.primaryLight 
                                  : (customColor ?? (isDark ? Colors.white : Colors.grey.shade800)),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                    tileColor: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : null,
                    onTap: () {
                      dashboardProvider.setSidebarIndex(index);
                      if (isDrawer) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          
          // زر تسجيل الخروج
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isCollapsed
                ? IconButton(
                    icon: const Icon(Icons.logout, color: AppColors.errorLight),
                    onPressed: () => _showLogoutDialog(context),
                  )
                : ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.errorLight),
                    title: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: AppColors.errorLight, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _showLogoutDialog(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.errorLight),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من لوحة التحكم؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorLight,
                minimumSize: const Size(80, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); // إغلاق النافذة
                
                final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
                await authProvider.logout();
                
                // توجيه لصفحة تسجيل الدخول ومسح مسار التصفح (Routing)
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/adminLogin', (route) => false);
                }
              },
              child: const Text('خروج'),
            ),
          ],
        );
      },
    );
  }
}
