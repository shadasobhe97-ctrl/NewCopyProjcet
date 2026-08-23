import 'package:kids_transport/core/routes/notification_navigation_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/features/app_entry/logic/app_entry_cubit.dart';
import 'package:kids_transport/features/app_entry/logic/app_entry_state.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppEntryCubit>().checkSession();
  }

  void _showResumeRegistrationDialog(
    BuildContext context,
    NavigateToResumeDriverRegistration state,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.assignment_turned_in, color: AppColors.orange),
              SizedBox(width: 8),
              Text(
                'استئناف إنشاء الحساب',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'هل ترغب في إكمال التسجيل وإدخال البيانات الآن، أم ترغب في إلغاء التسجيل والخروج؟',
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      final msg = await context
                          .read<RegisterCubit>()
                          .cancelDriverRegistration();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: AppColors.orange,
                        ),
                      );
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'إلغاء التسجيل والخروج',
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      if (state.stage == 'docs') {
                        // 🌟 يبقيه فوراً في شاشة الوثائق دون السماح بالرجوع لشاشة المركبة
                        Navigator.pushReplacementNamed(
                          context,
                          '/driverDocsStage',
                          arguments: state.draftData,
                        );
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          '/driverVehicleStage',
                          arguments: state.draftData,
                        );
                      }
                    },
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'متابعة التسجيل',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return BlocListener<AppEntryCubit, AppEntryState>(
      listener: (context, state) {
        if (state is NavigateToOnboarding) {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        } else if (state is NavigateToLogin) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else if (state is NavigateToDriverHome) {
          Navigator.pushReplacementNamed(context, AppRoutes.driverMainWrapper);
          NotificationNavigationHandler.handlePendingNotification();
        } else if (state is NavigateToParentHome) {
          Navigator.pushReplacementNamed(context, AppRoutes.parentMainWrapper);
          NotificationNavigationHandler.handlePendingNotification();
        } else if (state is NavigateToDriverWaiting) {
          Navigator.pushReplacementNamed(context, '/driverWaiting');
        } else if (state is NavigateToDriverPreferencesRequired) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.driverPreferences,
            arguments: true, // isMandatory = true
          );
        } else if (state is NavigateToResumeDriverRegistration) {
          _showResumeRegistrationDialog(context, state);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                isDark
                    ? 'assets/images/dark_logo.png'
                    : 'assets/images/ligth_logo.png',
                width: 240,
                height: 240,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.directions_bus_rounded,
                  size: 110,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(strokeWidth: 3),
            ],
          ),
        ),
      ),
    );
  }
}
