import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/features/auth/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/logic/auth_state.dart';

class ParentDrawer extends StatelessWidget {
  const ParentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fullName = StorageService.getFullName() ?? 'ولي أمر';
    final phoneNumber = StorageService.getPhoneNumber() ?? '';

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (_, state) => state is AuthLogoutSuccess || state is AuthError,
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
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
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.82,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _DrawerHeader(
              isDark: isDark,
              fullName: fullName,
              phoneNumber: phoneNumber,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primaryLight,
                    label: 'الملف الشخصي',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.parentProfile);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.accentPurple,
                    label: 'أطفالي',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.myChildren);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.success,
                    label: 'إدارة العناوين المحفوظة',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.savedAddresses);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.description_outlined,
                    iconColor: AppColors.pending,
                    label: 'عقودي واشتراكاتي',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.credit_card_rounded,
                    iconColor: AppColors.femalePink,
                    label: 'المحفظة والفواتير',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    iconColor: AppColors.textMuted,
                    label: 'الإعدادات',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppColors.textMuted,
                    label: 'ميزات دربي',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.support_agent_rounded,
                    iconColor: AppColors.textMuted,
                    label: 'التواصل مع الدعم',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return _DrawerItem(
                        icon: isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.logout_rounded,
                        iconColor: AppColors.error,
                        label:
                            isLoading ? 'جاري تسجيل الخروج...' : 'تسجيل الخروج',
                        labelColor: AppColors.error,
                        onTap: isLoading
                            ? () {}
                            : () => context.read<AuthCubit>().logout(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'دربي v1.0.0 - نسخة تجريبية',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final bool isDark;
  final String fullName;
  final String phoneNumber;

  const _DrawerHeader({
    required this.isDark,
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A2332), const Color(0xFF0F172A)]
              : [AppColors.primaryLight, const Color(0xFF0E78C4)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
                      icon: Icon(
                        isDark
                            ? Icons.wb_sunny_rounded
                            : Icons.brightness_3_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone_rounded,
                      color: Colors.white60, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      phoneNumber.isEmpty ? 'رقم الهاتف غير محفوظ' : phoneNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ولي أمر',
                      style: TextStyle(
                        color: Colors.white,
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
