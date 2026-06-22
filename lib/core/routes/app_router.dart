import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/app_entry/logic/app_entry_cubit.dart';
import 'package:kids_transport/features/app_entry/presentation/screens/onboarding_screen.dart';
import 'package:kids_transport/features/app_entry/presentation/screens/splash_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_alternative_phone.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_avatar_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_basic_info_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_email_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_otp_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/select_role_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_location_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/home_screen.dart';
import 'package:kids_transport/features/auth/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/presentation/screens/login_screen.dart';
import 'package:kids_transport/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:kids_transport/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:kids_transport/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:kids_transport/features/admin/presentation/screens/admin_login_screen.dart';
import 'package:kids_transport/features/admin/presentation/screens/admin_dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgotPassword';
  static const String verifyOtp = '/verifyOtp';
  static const String resetPassword = '/resetPassword';
  static const String onboarding = '/onboarding';
  
  // مسارات لوحة الإدارة
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (kIsWeb) {
      // إذا كان التشغيل على الويب، يتم توجيه كل شيء للوحة التحكم
      switch (settings.name) {
        case AppRoutes.splash:
        case AppRoutes.adminLogin:
          return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
        case AppRoutes.adminDashboard:
          return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
        default:
          return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('هذا المسار غير متاح على متصفح الويب (مخصص للموبايل)'))));
      }
    } else {
      // إذا كان التشغيل على الموبايل، يتم تشغيل تطبيق العملاء والسائقين بشكل طبيعي
      switch (settings.name) {
        case AppRoutes.splash:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => AppEntryCubit()..checkSession(),
              child: const SplashScreen(),
            ),
          );
        case AppRoutes.adminLogin:
        case AppRoutes.adminDashboard:
          return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('لوحة التحكم متاحة على الويب فقط'))));
        case AppRoutes.onboarding:
       return MaterialPageRoute(builder: (_) => const OnboardingScreen());
        case AppRoutes.login:
          return MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthCubit(), child: const LoginScreen()));
        case AppRoutes.forgotPassword:
          return MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthCubit(), child: const ForgotPasswordScreen()));
        case AppRoutes.verifyOtp:
          final email = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthCubit(), child: VerifyOtpScreen(email: email)));
        case AppRoutes.resetPassword:
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthCubit(), child: ResetPasswordScreen(email: args['email']!, otpCode: args['otpCode']!)));
          case '/selectRole':
        return MaterialPageRoute(builder: (_) => const SelectRoleScreen());
      
      case '/parentEmail':
        return MaterialPageRoute(builder: (_) => const ParentEmailScreen());
      
      case '/parentOtp':
        // هنا استلام الإيميل كـ Argument
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ParentOtpScreen(email: email));
        
      case '/parentBasicInfo':
        return MaterialPageRoute(builder: (_) => const ParentBasicInfoScreen());
        
      case '/parentAvatar':
        return MaterialPageRoute(builder: (_) => const ParentAvatarScreen());
        
      case '/parentAlternativePhone':
        return MaterialPageRoute(builder: (_) => const ParentAlternativePhoneScreen());
        
      case '/parentLocation':
        return MaterialPageRoute(builder: (_) => const ParentLocationScreen());
        
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        default:
          return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('الشاشة غير موجودة!'))));
      }
    }
  }
}