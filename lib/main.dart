import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// استيراد الـ Routes والخدمات
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'features/app_entry/logic/app_entry_cubit.dart';

import 'package:kids_transport/features/registration/logic/register_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const transportApp());
}

class transportApp extends StatelessWidget {
  const transportApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 التعديل الجذري: جعل الـ MultiBlocProvider هو الجذر الرئيسي فوق كل شيء
    return MultiBlocProvider(
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

                // لو تبي مستقبلاً يتبع الـ Cubit فكي الكومنت على السطر هذا وسكري اللي تحته
                // themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                themeMode: ThemeMode.system,

                // نقطة البداية
                initialRoute: AppRoutes.splash,
                onGenerateRoute: AppRoutes.generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
