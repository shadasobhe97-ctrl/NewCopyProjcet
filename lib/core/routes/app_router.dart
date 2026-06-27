import 'package:flutter/material.dart';
import 'package:kids_transport/features/app_entry/presentation/screens/onboarding_screen.dart';
import 'package:kids_transport/features/app_entry/presentation/screens/splash_screen.dart';
import 'package:kids_transport/features/driver/presentation/screens/driver_home_screen.dart';
import 'package:kids_transport/features/parent/presentation/screens/parent_home_screen.dart';
import 'package:kids_transport/features/parent/presentation/screens/parent_main_wrapper.dart';
import 'package:kids_transport/features/parent/presentation/screens/add_child_screen.dart';
import 'package:kids_transport/features/parent/presentation/screens/my_children_screen.dart';
import 'package:kids_transport/features/parent/presentation/screens/child_detail_screen.dart';
import 'package:kids_transport/features/parent/presentation/screens/parent_profile_screen.dart';
import 'package:kids_transport/features/parent/presentation/screens/saved_addresses_screen.dart';
import 'package:kids_transport/features/parent/data/models/child_model.dart';
import 'package:kids_transport/features/registration/presentation/screens/driver/driver_alternative_phone_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/driver/driver_avatar_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/driver/driver_basic_info_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/driver/driver_docs_stage_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/driver/driver_location_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/driver/driver_national_info_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/driver/driver_otp_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/driver/driver_vehicle_stage_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/driver/driver_waiting_screen.dart';
import 'package:kids_transport/features/driver/presentation/screens/driver_main_wrapper.dart';
import 'package:kids_transport/features/driver/presentation/screens/driver_backup_vehicle_screen.dart';
import 'package:kids_transport/features/driver/presentation/screens/driver_profile_screen.dart';
import 'package:kids_transport/features/driver/presentation/screens/driver_primary_vehicle_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_alternative_phone.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_avatar_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_basic_info_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_email_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_otp_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/select_role_screen.dart';
import 'package:kids_transport/features/registration/presentation/screens/parent/parent_location_screen.dart';

// 🌟 استيراد شاشة تسجيل دخول الأدمن الجديدة
import 'package:kids_transport/features/admin/presentation/screens/admin_login_screen.dart'; 
import 'package:kids_transport/features/admin/presentation/screens/admin_dashboard_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verify_otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String adminLogin = '/adminLogin'; // 👈 تم إضافة روت الأدمن هنا
  static const String adminDashboard = '/admin/dashboard';
  static const String forgotPassword = '/forgotPassword';
  static const String verifyOtp = '/verifyOtp';
  static const String resetPassword = '/resetPassword';
  static const String onboarding = '/onboarding';
  static const String parentHome = '/parentHome';
  static const String driverHome = '/driverHome';
  
  // روتس فلو ولي الأمر
  static const String parentMainWrapper = '/parentMainWrapper';
  static const String addChild = '/addChild';
  static const String myChildren = '/myChildren';
  static const String childDetail = '/childDetail';
  static const String parentProfile = '/parentProfile';
  static const String savedAddresses = '/savedAddresses';

  // روتس فلو السائق
  // TODO: عند الربط الكامل، يُوجَّه السائق هنا بعد قبول الأدمن لحسابه
  static const String driverMainWrapper = '/driverMainWrapper';
  static const String driverBackupVehicle = '/driverBackupVehicle';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
        
      case AppRoutes.adminLogin: // 👈 تم إضافة الحالة هنا لفتح شاشة الأدمن
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case AppRoutes.verifyOtp:
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => VerifyOtpScreen(email: email));
      
      case AppRoutes.resetPassword:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: args['email'] as String,
          ),
        );
        
      case '/selectRole':
        return MaterialPageRoute(builder: (_) => const SelectRoleScreen());
    
      case '/parentEmail':
        return MaterialPageRoute(builder: (_) => const ParentEmailScreen());

      // 🌟 الحاضن والداشبورد الرئيسي المحدث لولي الأمر
      case AppRoutes.parentHome:
      case AppRoutes.parentMainWrapper:
        return MaterialPageRoute(
          builder: (_) => const ParentMainWrapper(),
        );

      case AppRoutes.driverHome:
        return MaterialPageRoute(
          builder: (_) => const DriverHomeScreen(),
        );

      // شاشة إضافة طفل جديد
      case AppRoutes.addChild:
        return MaterialPageRoute(
          builder: (_) => const AddChildScreen(),
        );

      // شاشة أطفالي
      case AppRoutes.myChildren:
        return MaterialPageRoute(
          builder: (_) => const MyChildrenScreen(),
        );

      // شاشة تفاصيل طفل
      case AppRoutes.childDetail:
        final child = settings.arguments as ChildModel;
        return MaterialPageRoute(
          builder: (_) => ChildDetailScreen(child: child),
        );

      // شاشة الملف الشخصي لولي الأمر
      case AppRoutes.parentProfile:
        return MaterialPageRoute(
          builder: (_) => const ParentProfileScreen(),
        );

      // شاشة إدارة العناوين
      case AppRoutes.savedAddresses:
        return MaterialPageRoute(
          builder: (_) => const SavedAddressesScreen(),
        );

      case '/parentOtp':
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ParentOtpScreen(email: email));
      
      case '/parentBasicInfo':
        return MaterialPageRoute(builder: (_) => const ParentBasicInfoScreen());
      
      // الخطوة 2: صورة شخصية
      case '/parentAvatar':
        return MaterialPageRoute(builder: (_) => const ParentAvatarScreen());
      
      // الخطوة 3: هاتف بديل (اختياري)
      case '/parentAlternativePhone':
        return MaterialPageRoute(builder: (_) => const ParentAlternativePhoneScreen());
      
      // الخطوة 4: إدخال البريد وإرسال OTP
      case '/parentEmail':
        return MaterialPageRoute(builder: (_) => const ParentEmailScreen());
      
      // الخطوة 5: إدخال OTP + إرسال طلب التسجيل النهائي

      case '/parentLocation':
        return MaterialPageRoute(builder: (_) => const ParentLocationScreen());
      
      case '/home':
        return MaterialPageRoute(builder: (_) => const ParentHomeScreen());

      // الشاشة 1: بيانات السائق الأساسية
      case '/driverBasicInfo':
        return MaterialPageRoute(builder: (_) => const DriverBasicInfoScreen());

      // الشاشة 2: الصورة الشخصية للسائق
      case '/driverAvatar':
        return MaterialPageRoute(builder: (_) => const DriverAvatarScreen());

      // الشاشة 3: الهاتف البديل للسائق
      case '/driverAlternativePhone':
        return MaterialPageRoute(builder: (_) => const DriverAlternativePhoneScreen());

      // الشاشة 4: رمز تحقق السائق
      case '/driverOtp':
        return MaterialPageRoute(builder: (_) => const DriverOtpScreen());

      // الشاشة 5: البيانات الوطنية والرخصة للسائق
      case '/driverNationalInfo':
        return MaterialPageRoute(builder: (_) => const DriverNationalInfoScreen());

      // الشاشة 6: بيانات وصورة السيارة
      case '/driverVehicleStage':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => DriverVehicleStageScreen(collectedData: args),
        );

      // الشاشة 7: وثائق السيارة وإرسال الحساب
      case '/driverDocsStage':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => DriverDocsStageScreen(finalData: args),
        );

      // الشاشة 8: شاشة تحديد موقع السائق
      case '/driverLocation':
        return MaterialPageRoute(
          builder: (_) => const DriverLocationScreen(),
        );

      // شاشة انتظار مراجعة حساب السائق
      case '/driverWaiting':
        return MaterialPageRoute(builder: (_) => const DriverWaitingScreen());

      // ── الهوم سكرين الخاص بالسائق (بعد القبول من الأدمن) ──
      // TODO: عند الربط، تأكد من التحقق من حالة السائق قبل الدخول لهذه الشاشة
      case AppRoutes.driverMainWrapper:
        return MaterialPageRoute(builder: (_) => const DriverMainWrapper());

      // ── شاشة إضافة المركبة الاحتياطية ──
      case AppRoutes.driverBackupVehicle:
        return MaterialPageRoute(
          builder: (_) => const DriverBackupVehicleScreen(),
        );

      // ── شاشة الملف الشخصي للسائق ──
      case '/driverProfile':
        return MaterialPageRoute(
          builder: (_) => const DriverProfileScreen(),
        );

      // ── شاشة المركبة الأساسية للسائق ──
      case '/driverPrimaryVehicle':
        return MaterialPageRoute(
          builder: (_) => const DriverPrimaryVehicleScreen(),
        );

      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('الشاشة غير موجودة!'))));
    }
  }
}
