import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:kids_transport/features/app_entry/presentation/screens/onboarding_screen.dart';
import 'package:kids_transport/features/app_entry/presentation/screens/splash_screen.dart';
import 'package:kids_transport/features/auth/login/presentation/screens/login_screen.dart';
import 'package:kids_transport/features/auth/login/presentation/screens/forgot_password_screen.dart';
import 'package:kids_transport/features/auth/login/presentation/screens/verify_otp_screen.dart';
import 'package:kids_transport/features/auth/login/presentation/screens/reset_password_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/select_role_screen.dart';

// Admin
import 'package:kids_transport/features/admin/presentation/screens/admin_login_screen.dart';
import 'package:kids_transport/features/admin/presentation/screens/admin_dashboard_screen.dart';

// Parent Features
import 'package:kids_transport/features/parent/home/presentation/screens/parent_home_screen.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/my_children_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/child_detail_screen.dart';
import 'package:kids_transport/features/parent/profile/presentation/screens/parent_profile_screen.dart';
import 'package:kids_transport/features/parent/addresses/presentation/screens/saved_addresses_screen.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

// Parent Registration
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_alternative_phone.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_avatar_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_basic_info_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_email_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_otp_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_location_screen.dart';

// Driver Features
import 'package:kids_transport/features/driver/home/presentation/screens/driver_home_screen.dart';
import 'package:kids_transport/features/driver/dashboard/presentation/screens/driver_main_wrapper.dart';
import 'package:kids_transport/features/driver/vehicles/presentation/screens/driver_backup_vehicle_screen.dart';
import 'package:kids_transport/features/driver/profile/presentation/screens/driver_profile_screen.dart';
import 'package:kids_transport/features/driver/vehicles/presentation/screens/driver_primary_vehicle_screen.dart';

// Driver Registration
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_alternative_phone_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_avatar_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_basic_info_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_docs_stage_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_location_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_national_info_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_otp_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_vehicle_stage_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_waiting_screen.dart';

class AppRoutes {
  // ─── Entry & Auth ───
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgotPassword';
  static const String verifyOtp = '/verifyOtp';
  static const String resetPassword = '/resetPassword';
  static const String selectRole = '/selectRole';

  // ─── Admin ───
  static const String adminLogin = '/adminLogin';
  static const String adminDashboard = '/admin/dashboard';

  // ─── Parent Flows ───
  static const String parentHome = '/parentHome';
  static const String parentHomeLegacy = '/home';
  static const String parentMainWrapper = '/parentMainWrapper';
  static const String addChild = '/addChild';
  static const String myChildren = '/myChildren';
  static const String childDetail = '/childDetail';
  static const String parentProfile = '/parentProfile';
  static const String savedAddresses = '/savedAddresses';
  
  // Parent Registration
  static const String parentEmail = '/parentEmail';
  static const String parentOtp = '/parentOtp';
  static const String parentBasicInfo = '/parentBasicInfo';
  static const String parentAvatar = '/parentAvatar';
  static const String parentAlternativePhone = '/parentAlternativePhone';
  static const String parentLocation = '/parentLocation';

  // ─── Driver Flows ───
  static const String driverHome = '/driverHome';
  static const String driverMainWrapper = '/driverMainWrapper';
  static const String driverBackupVehicle = '/driverBackupVehicle';
  static const String driverProfile = '/driverProfile';
  static const String driverPrimaryVehicle = '/driverPrimaryVehicle';
  
  // Driver Registration
  static const String driverBasicInfo = '/driverBasicInfo';
  static const String driverAvatar = '/driverAvatar';
  static const String driverAlternativePhone = '/driverAlternativePhone';
  static const String driverOtp = '/driverOtp';
  static const String driverNationalInfo = '/driverNationalInfo';
  static const String driverVehicleStage = '/driverVehicleStage';
  static const String driverDocsStage = '/driverDocsStage';
  static const String driverLocation = '/driverLocation';
  static const String driverWaiting = '/driverWaiting';

  static String getInitialRoute() {
    if (kIsWeb) {
      return adminLogin;
    }
    return splash;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 1. App Entry & Global Auth
    final entryRoute = _buildEntryAndAuthRoutes(settings);
    if (entryRoute != null) return entryRoute;

    // 2. Admin Routes
    final adminRoute = _buildAdminRoutes(settings);
    if (adminRoute != null) return adminRoute;

    // 3. Parent Routes
    final parentRoute = _buildParentRoutes(settings);
    if (parentRoute != null) return parentRoute;

    // 4. Driver Routes
    final driverRoute = _buildDriverRoutes(settings);
    if (driverRoute != null) return driverRoute;

    // 5. Fallback Route
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('الشاشة غير موجودة!')),
      ),
    );
  }

  static Route<dynamic>? _buildEntryAndAuthRoutes(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case verifyOtp:
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => VerifyOtpScreen(email: email));
      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: args['email'] as String),
        );
      case selectRole:
        return MaterialPageRoute(builder: (_) => const SelectRoleScreen());
      default:
        return null;
    }
  }

  static Route<dynamic>? _buildAdminRoutes(RouteSettings settings) {
    switch (settings.name) {
      case adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      default:
        return null;
    }
  }

  static Route<dynamic>? _buildParentRoutes(RouteSettings settings) {
    switch (settings.name) {
      // Parent Dashboard & Features
      case parentHome:
      case parentMainWrapper:
        return MaterialPageRoute(builder: (_) => const ParentMainWrapper());
      case parentHomeLegacy:
        return MaterialPageRoute(builder: (_) => const ParentHomeScreen());
      case addChild:
        return MaterialPageRoute(builder: (_) => const AddChildScreen());
      case myChildren:
        return MaterialPageRoute(builder: (_) => const MyChildrenScreen());
      case childDetail:
        final child = settings.arguments as ChildModel;
        return MaterialPageRoute(builder: (_) => ChildDetailScreen(child: child));
      case parentProfile:
        return MaterialPageRoute(builder: (_) => const ParentProfileScreen());
      case savedAddresses:
        return MaterialPageRoute(builder: (_) => const SavedAddressesScreen());
      
      // Parent Registration Flow
      case parentEmail:
        return MaterialPageRoute(builder: (_) => const ParentEmailScreen());
      case parentOtp:
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ParentOtpScreen(email: email));
      case parentBasicInfo:
        return MaterialPageRoute(builder: (_) => const ParentBasicInfoScreen());
      case parentAvatar:
        return MaterialPageRoute(builder: (_) => const ParentAvatarScreen());
      case parentAlternativePhone:
        return MaterialPageRoute(builder: (_) => const ParentAlternativePhoneScreen());
      case parentLocation:
        return MaterialPageRoute(builder: (_) => const ParentLocationScreen());
      default:
        return null;
    }
  }

  static Route<dynamic>? _buildDriverRoutes(RouteSettings settings) {
    switch (settings.name) {
      // Driver Dashboard & Features
      case driverHome:
        return MaterialPageRoute(builder: (_) => const DriverHomeScreen());
      case driverMainWrapper:
        return MaterialPageRoute(builder: (_) => const DriverMainWrapper());
      case driverBackupVehicle:
        return MaterialPageRoute(builder: (_) => const DriverBackupVehicleScreen());
      case driverProfile:
        return MaterialPageRoute(builder: (_) => const DriverProfileScreen());
      case driverPrimaryVehicle:
        return MaterialPageRoute(builder: (_) => const DriverPrimaryVehicleScreen());
      
      // Driver Registration Flow
      case driverBasicInfo:
        return MaterialPageRoute(builder: (_) => const DriverBasicInfoScreen());
      case driverAvatar:
        return MaterialPageRoute(builder: (_) => const DriverAvatarScreen());
      case driverAlternativePhone:
        return MaterialPageRoute(builder: (_) => const DriverAlternativePhoneScreen());
      case driverOtp:
        return MaterialPageRoute(builder: (_) => const DriverOtpScreen());
      case driverNationalInfo:
        return MaterialPageRoute(builder: (_) => const DriverNationalInfoScreen());
      case driverVehicleStage:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(builder: (_) => DriverVehicleStageScreen(collectedData: args));
      case driverDocsStage:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(builder: (_) => DriverDocsStageScreen(finalData: args));
      case driverLocation:
        return MaterialPageRoute(builder: (_) => const DriverLocationScreen());
      case driverWaiting:
        return MaterialPageRoute(builder: (_) => const DriverWaitingScreen());
      default:
        return null;
    }
  }
}
