import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/features/app_entry/logic/app_entry_cubit.dart';
import 'package:kids_transport/features/app_entry/logic/app_entry_state.dart';

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
        } else if (state is NavigateToParentHome) {
          Navigator.pushReplacementNamed(context, AppRoutes.parentHome);
        } else if (state is NavigateToAdminHome) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        } else if (state is NavigateToDriverWaiting) {
          Navigator.pushReplacementNamed(context, '/driverWaiting');
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
