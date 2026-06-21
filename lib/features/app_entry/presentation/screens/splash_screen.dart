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
    // بدء فحص الجلسة (الـ 2 ثانية) فوراً عند الإقلاع
    context.read<AppEntryCubit>().checkSession();
  }

  @override
  Widget build(BuildContext context) {
    // 1. قراءة حالة الثيم الحالية لتحديد اللوجو المناسب
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return BlocListener<AppEntryCubit, AppEntryState>(
      listener: (context, state) {
        if (state is NavigateToOnboarding) {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        } else if (state is NavigateToLogin) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else if (state is NavigateToDriverHome || state is NavigateToParentHome) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
        //else if (state is NavigateToParentHome) {
  // لو طلع ولي أمر ومسجل دخول، ابعثيه لصفحة ولي الأمر
         // Navigator.pushReplacementNamed(context, AppRoutes.parentHome);
           //}
    },
      child: Scaffold(
        // الخلفية تتغير تلقائياً حسب الثيم المعتمد في الـ ThemeData
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2. تغيير مسار الصورة ذكياً بناءً على وضع الثيم
              Image.asset(
                isDark 
                    ? 'assets/images/dark_logo.png'  // لوجو الوضع الداكن
                    : 'assets/images/ligth_logo.png', // لوجو الوضع الفاتح
                width: 240, // جعل اللوجو أكبر ومميزاً في شاشة السبلاش
                height: 240,
                // في حال عدم وجود الملفات لتفادي كراش التطبيق مؤقتاً
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.directions_bus_rounded,
                  size: 110,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              // مؤشر التحميل يأخذ لون الثيم الافتراضي تلقائياً
              const CircularProgressIndicator(strokeWidth: 3),
            ],
          ),
        ),
      ),
    );
  }
}