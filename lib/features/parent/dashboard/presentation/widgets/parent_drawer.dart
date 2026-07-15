import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/features/auth/login/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/login/logic/auth_state.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_cubit.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/widgets/app_drawer_item.dart';

class ParentDrawer extends StatelessWidget {
  const ParentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cachedName = context.read<ParentProfileCubit>().getCachedFullName();
    final fullName = cachedName.isEmpty ? 'ولي أمر' : cachedName;
    final phoneNumber = context.read<ParentProfileCubit>().getCachedPhoneNumber();

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
        shape: AppTheme.roundedRectangleBorder(
          borderRadius: AppTheme.horizontalRadius(left: AppTheme.cornerRadius(24)),
        ),
        child: Column(
          children: [
            _DrawerHeader(fullName: fullName, phoneNumber: phoneNumber),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  AppDrawerItem(
                    icon: Icons.person_outline_rounded,
                    iconColor: context.primaryColor,
                    label: 'الملف الشخصي',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.parentProfile);
                    },
                  ),
                  AppDrawerItem(
                    icon: Icons.people_alt_rounded,
                    iconColor: context.accentPurple,
                    label: 'أطفالي',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.myChildren);
                    },
                  ),
                  AppDrawerItem(
                    icon: Icons.location_on_outlined,
                    iconColor: context.successColor,
                    label: 'إدارة العناوين المحفوظة',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.savedAddresses);
                    },
                  ),
                  AppDrawerItem(
                    icon: Icons.description_outlined,
                    iconColor: context.pendingColor,
                    label: 'عقودي واشتراكاتي',
                    onTap: () => Navigator.pop(context),
                  ),
                  AppDrawerItem(
                    icon: Icons.credit_card_rounded,
                    iconColor: context.genderFemaleColor,
                    label: 'المحفظة والفواتير',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  AppDrawerItem(
                    icon: Icons.settings_outlined,
                    iconColor: context.textMuted,
                    label: 'الإعدادات',
                    onTap: () => Navigator.pop(context),
                  ),
                  AppDrawerItem(
                    icon: Icons.help_outline_rounded,
                    iconColor: context.textMuted,
                    label: 'ميزات دربي',
                    onTap: () => Navigator.pop(context),
                  ),
                  AppDrawerItem(
                    icon: Icons.support_agent_rounded,
                    iconColor: context.textMuted,
                    label: 'التواصل مع الدعم',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return AppDrawerItem(
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

class _DrawerHeader extends StatelessWidget {
  final String fullName;
  final String phoneNumber;

  const _DrawerHeader({required this.fullName, required this.phoneNumber});

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
                  Container(
                    decoration: AppTheme.boxDecoration(
                      shape: BoxShape.circle,
                      border: AppTheme.border(
                        color: AppColors.white.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.white24,
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  Container(
                    decoration: AppTheme.boxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: AppTheme.radius(12),
                    ),
                    child: IconButton(
                      tooltip: context.isDarkMode
                          ? 'الوضع الفاتح'
                          : 'الوضع الداكن',
                      icon: Icon(
                        context.isDarkMode
                            ? Icons.wb_sunny_rounded
                            : Icons.brightness_3_rounded,
                        color: AppColors.white,
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
                  Expanded(
                    child: Text(
                      phoneNumber.isEmpty
                          ? 'رقم الهاتف غير محفوظ'
                          : phoneNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.style(
                        color: AppColors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                      'ولي أمر',
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

// _DrawerItem removed and replaced with AppDrawerItem
