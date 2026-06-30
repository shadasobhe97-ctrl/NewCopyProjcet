import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ خلي هذا
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'features/auth/login/logic/auth_cubit.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'features/app_entry/logic/app_entry_cubit.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/admin/logic/admin_auth_provider.dart';
import 'package:kids_transport/features/admin/logic/admin_dashboard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const TransportApp());
}

class TransportApp extends StatelessWidget {
  const TransportApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 التعديل الجذري: جعل الـ MultiBlocProvider هو الجذر الرئيسي فوق كل شيء
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
          BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
          BlocProvider<AppEntryCubit>(
            // 🌟 ضفنا الـ الكاسكيد هادي باش أول ما يتكاريت الكيوبت، يفحص الجلسة طول ويطير إيرور الـ late
            create: (context) => AppEntryCubit()..checkSession(),
          ),
          BlocProvider<RegisterCubit>(create: (context) => RegisterCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp(
                  title: 'تطبيق دربي المدارس',
                  debugShowCheckedModeBanner: false,

                  // دعم اللغة العربية والـ RTL
                  locale: const Locale('ar', 'LY'),
                  supportedLocales: const [Locale('ar', 'LY')],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],

                  // استخدام الثيمات الاحترافية المحددة في AppTheme
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,

                  themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,

                  // نقطة البداية
                  initialRoute: _getInitialRoute(),
                  onGenerateRoute: AppRoutes.generateRoute,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ✅ دالة تحدد المسار حسب المنصة (نفس الكود القديم)
  String _getInitialRoute() {
    if (kIsWeb) {
      return AppRoutes.adminLogin; // ← روح لتسجيل دخول الادمن
    } else {
      return AppRoutes.splash; // ← روح للشاشة الافتتاحية
    }
  }
}