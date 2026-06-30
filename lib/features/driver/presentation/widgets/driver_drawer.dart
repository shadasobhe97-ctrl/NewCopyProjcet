import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/features/auth/login/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/login/logic/auth_state.dart';
import '../../data/models/driver_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

// ==========================================
// السايد بار (الدروار) الخاص بالسائق
// ==========================================

class DriverDrawer extends StatelessWidget {
  final DriverModel driver;

  const DriverDrawer({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (_, state) =>
          state is AuthLogoutSuccess ||
          state is AuthLogoutFailure ||
          state is AuthError,
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.successColor,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        } else if (state is AuthLogoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: context.errorColor,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: context.errorColor,
            ),
          );
        }
      },
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.82,
        backgroundColor: context.darkSurface,
        shape: AppTheme.roundedRectangleBorder(
          borderRadius: AppTheme.horizontalRadius(left: AppTheme.cornerRadius(24)),
        ),
        child: Column(
          children: [
            // ─── هيدر الدروار ───────────────────────────────────────
            _DriverDrawerHeader(driver: driver, isDark: isDark),

            // ─── قائمة العناصر ──────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // ── الملف الشخصي ──
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    iconColor: context.primaryColor,
                    label: 'الملف الشخصي',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/driverProfile');
                    },
                  ),

                  // ── معلومات المركبة الرئيسية ──
                  _DrawerItem(
                    icon: Icons.directions_car_filled_rounded,
                    iconColor: context.primaryColor,
                    label: 'معلومات المركبة الرئيسية',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/driverPrimaryVehicle');
                    },
                  ),

                  // ── المركبة الاحتياطية ──
                  _BackupVehicleDrawerItem(
                    driver: driver,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: التوجيه لشاشة إضافة/عرض المركبة الاحتياطية
                      Navigator.pushNamed(
                        context,
                        '/driverBackupVehicle',
                        arguments: {'collectedData': {}},
                      );
                    },
                  ),

                  // ── عقودي والتزاماتي ──
                  _DrawerItem(
                    icon: Icons.description_outlined,
                    iconColor: context.pendingColor,
                    label: 'عقودي والتزاماتي',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: التوجيه لشاشة العقود والالتزامات
                      // Navigator.pushNamed(context, AppRoutes.driverContracts);
                    },
                  ),

                  const Divider(height: 20, indent: 16, endIndent: 16),

                  // ── الإعدادات ──
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    iconColor: context.textMuted,
                    label: 'إعدادات التطبيق',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: التوجيه لشاشة الإعدادات
                      // Navigator.pushNamed(context, AppRoutes.driverSettings);
                    },
                  ),

                  // ── ميزات دربي ──
                  _DrawerItem(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: context.accentPurple,
                    label: 'ميزات دربي',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: التوجيه لشاشة ميزات دربي
                      // Navigator.pushNamed(context, AppRoutes.driverFeatures);
                    },
                  ),

                  // ── التواصل مع الدعم ──
                  _DrawerItem(
                    icon: Icons.support_agent_rounded,
                    iconColor: context.successColor,
                    label: 'التواصل مع الدعم',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: فتح قناة الدعم (واتساب / اتصال / شات)
                      // _launchSupportChannel();
                    },
                  ),

                  const Divider(height: 20, indent: 16, endIndent: 16),

                  // ── تسجيل الخروج ──
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return _DrawerItem(
                        icon: isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.logout_rounded,
                        iconColor: context.errorColor,
                        label: isLoading
                            ? 'جاري تسجيل الخروج...'
                            : 'تسجيل الخروج',
                        labelColor: context.errorColor,
                        onTap: isLoading
                            ? () {}
                            : () => context.read<AuthCubit>().logout(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ─── Footer: نسخة التطبيق ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'دربي v1.0.0 - نسخة تجريبية',
                style: AppTextStyles.style(
                  fontSize: 11,
                  color: context.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── هيدر الدروار المنفصل ────────────────────────────────────────────────
class _DriverDrawerHeader extends StatelessWidget {
  final DriverModel driver;
  final bool isDark;

  const _DriverDrawerHeader({required this.driver, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.boxDecoration(
        gradient: AppTheme.linearGradient(
          colors: context.primaryGradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppTheme.onlyRadius(topLeft: AppTheme.cornerRadius(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── أفاتار السائق ──
                  Container(
                    decoration: AppTheme.boxDecoration(
                      shape: BoxShape.circle,
                      border: AppTheme.border(
                        color: AppColors.white.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.white24,
                      child: driver.avatarUrl == null
                          ? const Icon(
                              Icons.person_rounded,
                              color: AppColors.white,
                              size: 36,
                            )
                          : null,
                    ),
                  ),

                  // ── زر تغيير الثيم (شمس/هلال) ──
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeState) {
                      return Container(
                        decoration: AppTheme.boxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          borderRadius: AppTheme.radius(12),
                        ),
                        child: IconButton(
                          tooltip: themeState.isDarkMode
                              ? 'التبديل للوضع المضيء'
                              : 'التبديل للوضع المظلم',
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                RotationTransition(
                                  turns: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                            child: Icon(
                              themeState.isDarkMode
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nightlight_round,
                              key: ValueKey(themeState.isDarkMode),
                              color: AppColors.white,
                              size: 22,
                            ),
                          ),
                          onPressed: () {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── اسم السائق ──
              Text(
                driver.fullName,
                style: AppTextStyles.style(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(
                    Icons.phone_rounded,
                    color: AppColors.white60,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    driver.phone,
                    style: AppTextStyles.style(
                      color: AppColors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  // شارة السائق
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: AppTheme.boxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: AppTheme.radius(20),
                    ),
                    child: Text(
                      '🚐 سائق',
                      style: AppTextStyles.style(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── عنصر المركبة الاحتياطية الذكي ────────────────────────────────────────
class _BackupVehicleDrawerItem extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onTap;

  const _BackupVehicleDrawerItem({required this.driver, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasBackupVehicle = driver.backupVehicle != null;

    return _DrawerItem(
      icon: hasBackupVehicle
          ? Icons.directions_car_rounded
          : Icons.add_circle_outline_rounded,
      iconColor: hasBackupVehicle ? context.accentPurple : context.primaryColor,
      label: hasBackupVehicle
          ? 'معلومات المركبة الاحتياطية'
          : 'إضافة مركبة احتياطية',
      badge:
          hasBackupVehicle && driver.backupVehicle!.approvalStatus == 'pending'
          ? 'قيد المراجعة'
          : null,
      onTap: onTap,
    );
  }
}

// ─── عنصر قائمة الدروار المُعاد استخدامه ─────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final String? badge; // شارة اختيارية
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: AppTheme.boxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: AppTheme.radius(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.style(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: AppTheme.boxDecoration(
                color: context.pendingColor.withValues(alpha: 0.15),
                borderRadius: AppTheme.radius(20),
              ),
              child: Text(
                badge!,
                style: AppTextStyles.style(
                  fontSize: 10,
                  color: context.pendingColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Icon(
        Icons.chevron_left_rounded,
        color: context.textMuted,
        size: 20,
      ),
      onTap: onTap,
      shape: AppTheme.roundedRectangleBorder(borderRadius: AppTheme.radius(12)),
    );
  }
}
