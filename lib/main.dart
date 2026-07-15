import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/features/admin/logic/admin_auth_cubit.dart';
import 'package:kids_transport/features/admin/logic/admin_dashboard_cubit.dart';
import 'package:kids_transport/features/app_entry/logic/app_entry_cubit.dart';
import 'package:kids_transport/features/auth/login/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/login/data/repositories/auth_repository.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/add_child_cubit.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/subscriptions/logic/subscriptions_cubit/subscriptions_cubit.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/features/parent/search/logic/search_cubit.dart';
import 'package:kids_transport/core/services/hive_helper.dart';
import 'package:kids_transport/features/driver/shared/di/driver_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await HiveHelper.init(); // تهيئة قاعدة بيانات Hive
  setupDependencyInjection();
  initDriverInjection();
  runApp(const TransportApp());
}

class TransportApp extends StatelessWidget {
  const TransportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<AdminAuthCubit>(
          create: (_) => AdminAuthCubit(
            getIt<AuthRepository>(),
            getIt<SessionRepository>(),
          ),
        ),
        BlocProvider<AdminDashboardCubit>(
          create: (_) => AdminDashboardCubit(),
        ),
        BlocProvider<AppEntryCubit>(
          create: (_) => getIt<AppEntryCubit>()..checkSession(),
        ),
        BlocProvider<RegisterCubit>(create: (_) => getIt<RegisterCubit>()),
        BlocProvider<ChildrenCubit>(
          create: (_) => getIt<ChildrenCubit>(),
        ),
        BlocProvider<AddChildCubit>(
          create: (_) => getIt<AddChildCubit>(),
        ),
        BlocProvider<SubscriptionsCubit>(
          create: (_) => getIt<SubscriptionsCubit>(),
        ),
        BlocProvider<SearchCubit>(
          create: (_) => getIt<SearchCubit>(),
        ),
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
                locale: const Locale('ar', 'LY'),
                supportedLocales: const [Locale('ar', 'LY')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                // هذا السطر هو السر، هو الذي يجعل كل التطبيق RTL
                builder: (context, child) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: child!,
                  );
                },
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                initialRoute: AppRoutes.getInitialRoute(),
                onGenerateRoute: AppRoutes.generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
