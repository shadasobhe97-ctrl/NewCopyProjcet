import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kids_transport/firebase_options.dart';
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
import 'package:kids_transport/core/services/notification_service.dart';
import 'package:kids_transport/features/chat/presentation/screens/chat_room_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _setupNotificationDeepLink() {
  NotificationService.setNotificationTapCallback((Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        debugPrint('🔔 [Notification Tap Callback Triggered]: $data');
      }

      final String? type = data['type']?.toString();
      final String? chatRoomId = data['chat_room_id']?.toString() ??
          data['chatRoomId']?.toString();

      if (type == 'chat_message' ||
          (chatRoomId != null && chatRoomId.isNotEmpty)) {
        final sessionRepo = getIt<SessionRepository>();
        final String? currentUserId = sessionRepo.getUserId();
        final String currentUserRole = sessionRepo.getRoleName() ?? '';

        final String otherUserName = data['sender_name']?.toString() ??
            data['other_user_name']?.toString() ??
            data['title']?.toString() ??
            'محادثة جديدة';

        final String? otherUserPhoto = data['sender_photo']?.toString() ??
            data['other_user_photo']?.toString();

        if (currentUserId != null &&
            currentUserId.isNotEmpty &&
            chatRoomId != null &&
            chatRoomId.isNotEmpty) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                chatRoomId: chatRoomId,
                otherUserName: otherUserName,
                otherUserPhoto: otherUserPhoto,
                canChat: true,
                currentUserId: currentUserId,
                currentUserRole: currentUserRole,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling notification deep link: $e');
      }
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await StorageService.init();
  await HiveHelper.init(); // تهيئة قاعدة بيانات Hive
  setupDependencyInjection();
  initDriverInjection();
  await NotificationService.init();
  _setupNotificationDeepLink();
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
        BlocProvider<AdminDashboardCubit>(create: (_) => AdminDashboardCubit()),
        BlocProvider<AppEntryCubit>(
          create: (_) => getIt<AppEntryCubit>()..checkSession(),
        ),
        BlocProvider<RegisterCubit>(create: (_) => getIt<RegisterCubit>()),
        BlocProvider<ChildrenCubit>(create: (_) => getIt<ChildrenCubit>()),
        BlocProvider<AddChildCubit>(create: (_) => getIt<AddChildCubit>()),
        BlocProvider<SubscriptionsCubit>(
          create: (_) => getIt<SubscriptionsCubit>(),
        ),
        BlocProvider<SearchCubit>(create: (_) => getIt<SearchCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: false,
            splitScreenMode: false,
            builder: (context, child) {
              return MaterialApp(
                navigatorKey: navigatorKey,
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
