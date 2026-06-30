import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/admin/logic/admin_auth_cubit.dart';
import 'package:kids_transport/features/admin/logic/admin_dashboard_cubit.dart';

class AdminSidebar extends StatelessWidget {
  final bool isDrawer;

  const AdminSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = themeState.isDarkMode;

    final menuItems = [
      {'title': 'الشاشة الرئيسية', 'icon': Icons.dashboard},
      {'title': 'إدارة السائقين', 'icon': Icons.directions_car},
      {'title': 'إدارة الاشتراكات', 'icon': Icons.subscriptions},
      {
        'title': 'إدارة الشكاوى',
        'icon': Icons.report_problem,
        'color': AppColors.red,
      },
      {'title': 'مراقبة الرحلات', 'icon': Icons.map},
      {'title': 'تنبيهات الطوارئ', 'icon': Icons.warning},
      {'title': 'إدارة التقارير', 'icon': Icons.analytics},
      {'title': 'إضافة موظف جديد', 'icon': Icons.person_add},
    ];

    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        final isCollapsed = state.isSidebarCollapsed && !isDrawer;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCollapsed ? 80 : 250,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 8.0,
                ),
                decoration: AppTheme.boxDecoration(
                  border: AppTheme.bottomBorder(
                    color: isDark ? AppColors.grey800 : AppColors.grey200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isCollapsed)
                      Expanded(
                        child: Text(
                          'لوحة الإدارة',
                          style: AppTextStyles.style(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (!isCollapsed)
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.nights_stay : Icons.wb_sunny,
                          color: isDark ? AppColors.amber : AppColors.orange,
                        ),
                        onPressed: () {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      ),
                    if (!isDrawer)
                      IconButton(
                        icon: Icon(
                          isCollapsed ? Icons.menu : Icons.chevron_left,
                        ),
                        onPressed: () {
                          context.read<AdminDashboardCubit>().toggleSidebar();
                        },
                      ),
                  ],
                ),
              ),
              if (isCollapsed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: IconButton(
                    icon: Icon(
                      isDark ? Icons.nights_stay : Icons.wb_sunny,
                      color: isDark ? AppColors.amber : AppColors.orange,
                    ),
                    onPressed: () {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final isSelected = state.selectedSidebarIndex == index;
                    final customColor = menuItems[index]['color'] as Color?;

                    return Tooltip(
                      message: isCollapsed
                          ? menuItems[index]['title'] as String
                          : '',
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        leading: Icon(
                          menuItems[index]['icon'] as IconData,
                          color: isSelected
                              ? context.primaryColor
                              : (customColor ??
                                    (isDark
                                        ? AppColors.grey400
                                        : AppColors.grey600)),
                        ),
                        title: isCollapsed
                            ? null
                            : Text(
                                menuItems[index]['title'] as String,
                                style: AppTextStyles.style(
                                  color: isSelected
                                      ? context.primaryColor
                                      : (customColor ??
                                            (isDark
                                                ? AppColors.white
                                                : AppColors.grey800)),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                        tileColor: isSelected
                            ? context.primaryColor.withValues(alpha: 0.1)
                            : null,
                        onTap: () {
                          context
                              .read<AdminDashboardCubit>()
                              .setSidebarIndex(index);
                          if (isDrawer) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: isCollapsed
                    ? IconButton(
                        icon: Icon(Icons.logout, color: context.errorColor),
                        onPressed: () => _showLogoutDialog(context),
                      )
                    : ListTile(
                        leading: Icon(Icons.logout, color: context.errorColor),
                        title: Text(
                          'تسجيل الخروج',
                          style: AppTextStyles.style(
                            color: context.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _showLogoutDialog(context),
                        shape: AppTheme.roundedRectangleBorder(
                          borderRadius: AppTheme.radius(12),
                          side: AppTheme.borderSide(color: context.errorColor),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج من لوحة التحكم؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: AppTextStyles.style(color: AppColors.grey),
              ),
            ),
            ElevatedButton(
              style: AppTheme.elevatedButtonStyle(
                backgroundColor: context.errorColor,
                minimumSize: const Size(80, 40),
                shape: AppTheme.roundedRectangleBorder(
                  borderRadius: AppTheme.radius(8),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                final authCubit = context.read<AdminAuthCubit>();
                final success = await authCubit.logout();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'تم تسجيل الخروج بنجاح.'
                            : authCubit.errorMessage ?? 'فشل تسجيل الخروج.',
                      ),
                      backgroundColor: success
                          ? context.successColor
                          : context.errorColor,
                    ),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/adminLogin',
                    (route) => false,
                  );
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
