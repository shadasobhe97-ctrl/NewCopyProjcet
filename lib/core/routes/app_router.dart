import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kids_transport/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:kids_transport/features/admin/presentation/screens/admin_login_screen.dart';
import 'package:kids_transport/features/app_entry/presentation/screens/onboarding_screen.dart';
import 'package:kids_transport/features/app_entry/presentation/screens/splash_screen.dart';
import 'package:kids_transport/features/auth/login/presentation/screens/forgot_password_screen.dart';
import 'package:kids_transport/features/auth/login/presentation/screens/login_screen.dart';
import 'package:kids_transport/features/auth/login/presentation/screens/reset_password_screen.dart';
import 'package:kids_transport/features/auth/login/presentation/screens/verify_otp_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/select_role_screen.dart';

import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_alternative_phone_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_avatar_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_basic_info_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_docs_stage_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_location_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_national_info_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_otp_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_vehicle_stage_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_waiting_screen.dart';

import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_alternative_phone.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_avatar_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_basic_info_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_email_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_location_screen.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_otp_screen.dart';

import 'package:kids_transport/features/driver/dashboard/presentation/screens/driver_main_wrapper.dart';
import 'package:kids_transport/features/driver/home/presentation/screens/driver_home_screen.dart';
import 'package:kids_transport/features/driver/profile/presentation/screens/driver_profile_screen.dart';
import 'package:kids_transport/features/driver/vehicles/presentation/screens/driver_primary_vehicle_screen.dart';
import 'package:kids_transport/features/driver/vehicles/logic/vehicle_cubit.dart';

import 'package:kids_transport/features/driver/profile/logic/cubit/driver_profile_cubit.dart';
import 'package:kids_transport/features/driver/shared/di/driver_injection.dart';
import 'package:kids_transport/features/driver/driver_preferences/logic/driver_preferences_cubit.dart';
import 'package:kids_transport/features/driver/driver_preferences/presentation/screens/driver_preferences_screen.dart';

import 'package:kids_transport/features/parent/addresses/presentation/screens/saved_addresses_screen.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_step1_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_step2_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/child_data_details_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/child_pass_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/my_children_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/transport_details_screen.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';
import 'package:kids_transport/features/parent/home/presentation/screens/parent_home_screen.dart';
import 'package:kids_transport/features/parent/profile/presentation/screens/parent_profile_screen.dart';
import 'package:kids_transport/features/parent/subscriptions/presentation/screens/subscription_details_screen.dart';
import 'package:kids_transport/features/parent/subscriptions/logic/subscriptions_cubit/subscriptions_cubit.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_cubit.dart';

// Wallet & Finance
import 'package:kids_transport/features/parent/wallet/presentation/screens/wallet_screen.dart';
import 'package:kids_transport/features/parent/wallet/presentation/screens/recharge_screen.dart';
import 'package:kids_transport/features/parent/wallet/presentation/screens/invoices_screen.dart';
import 'package:kids_transport/features/parent/wallet/presentation/screens/invoice_details_screen.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_cubit.dart';

// Trips & Live Tracking
import 'package:kids_transport/features/parent/trips/data/models/active_trip_model.dart';
import 'package:kids_transport/features/parent/trips/presentation/screens/trips_home_screen.dart';
import 'package:kids_transport/features/parent/trips/presentation/screens/trip_tracking_screen.dart';
import 'package:kids_transport/features/parent/trips/presentation/screens/upcoming_trips_screen.dart';
import 'package:kids_transport/features/parent/trips/presentation/screens/trip_history_screen.dart';

// Complaints
import 'package:kids_transport/features/parent/complaints/presentation/screens/complaints_list_screen.dart';
import 'package:kids_transport/features/parent/complaints/presentation/screens/create_complaint_screen.dart';
import 'package:kids_transport/features/parent/complaints/presentation/screens/complaint_details_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgotPassword';
  static const String verifyOtp = '/verifyOtp';
  static const String resetPassword = '/resetPassword';
  static const String selectRole = '/selectRole';

  static const String adminLogin = '/adminLogin';
  static const String adminDashboard = '/admin/dashboard';

  static const String parentHome = '/parentHome';
  static const String parentHomeLegacy = '/home';
  static const String parentMainWrapper = '/parentMainWrapper';
  static const String parentProfile = '/parentProfile';
  static const String parentSubscriptions = '/parent-subscriptions';
  static const String savedAddresses = '/savedAddresses';
  static const String myChildren = '/my-children';
  static const String addChild = '/add-child';

  // Parent Wallet & Finance Routes
  static const String parentWallet = '/parent-wallet';
  static const String parentRecharge = '/parent-recharge';
  static const String parentInvoices = '/parent-invoices';
  static const String parentInvoiceDetails = '/parent-invoice-details';

  // Parent Trips & Live Tracking Routes
  static const String parentTripsHome = '/parent-trips-home';
  static const String parentTripTracking = '/parent-trip-tracking';
  static const String parentUpcomingTrips = '/parent-upcoming-trips';
  static const String parentTripHistory = '/parent-trip-history';

  // Parent Complaints Routes
  static const String parentComplaints = '/parent-complaints';
  static const String createComplaint = '/create-complaint';
  static const String complaintDetails = '/complaint-details';

  // ===== Driver Features =====
  static const String addChildStep1 = '/children/add/step1';
  static const String addChildStep2 = '/children/add/step2';
  static const String childDetail = '/childDetail';
  static const String childDataDetails = '/children/data';
  static const String childPass = '/children/pass';
  static const String transportDetails = '/children/transport';
  static const String subscriptionDetails = '/parent/subscriptionDetails';

  static const String parentEmail = '/parentEmail';
  static const String parentOtp = '/parentOtp';
  static const String parentBasicInfo = '/parentBasicInfo';
  static const String parentAvatar = '/parentAvatar';
  static const String parentAlternativePhone = '/parentAlternativePhone';
  static const String parentLocation = '/parentLocation';

  static const String driverHome = '/driverHome';
  static const String driverMainWrapper = '/driverMainWrapper';
  static const String driverBackupVehicle = '/driverBackupVehicle';
  static const String driverProfile = '/driverProfile';
  static const String driverPrimaryVehicle = '/driverPrimaryVehicle';
  static const String driverPreferences = '/driverPreferences';

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
    final entryRoute = _buildEntryAndAuthRoutes(settings);
    if (entryRoute != null) return entryRoute;

    final adminRoute = _buildAdminRoutes(settings);
    if (adminRoute != null) return adminRoute;

    final parentRoute = _buildParentRoutes(settings);
    if (parentRoute != null) return parentRoute;

    final driverRoute = _buildDriverRoutes(settings);
    if (driverRoute != null) return driverRoute;

    return _errorRoute('الشاشة غير موجودة!');
  }

  static Route<dynamic>? _buildEntryAndAuthRoutes(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _route(settings, const SplashScreen());
      case onboarding:
        return _route(settings, const OnboardingScreen());
      case login:
        return _route(settings, const LoginScreen());
      case forgotPassword:
        return _route(settings, const ForgotPasswordScreen());
      case verifyOtp:
        final email = settings.arguments as String;
        return _route(settings, VerifyOtpScreen(email: email));
      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>;
        return _route(
          settings,
          ResetPasswordScreen(email: args['email'] as String),
        );
      case selectRole:
        return _route(settings, const SelectRoleScreen());
      default:
        return null;
    }
  }

  static Route<dynamic>? _buildAdminRoutes(RouteSettings settings) {
    switch (settings.name) {
      case adminLogin:
        return _route(settings, const AdminLoginScreen());
      case adminDashboard:
        return _route(settings, const AdminDashboardScreen());
      default:
        return null;
    }
  }

  static Route<dynamic>? _buildParentRoutes(RouteSettings settings) {
    switch (settings.name) {
      case parentHome:
      case parentMainWrapper:
        return _route(
          settings,
          BlocProvider(
            create: (context) => getIt<ParentProfileCubit>()..fetchProfile(),
            child: const ParentMainWrapper(),
          ),
        );
      case parentHomeLegacy:
        return _route(settings, const ParentHomeScreen());
      case parentProfile:
        return _route(
          settings,
          BlocProvider(
            create: (context) => getIt<ParentProfileCubit>(),
            child: const ParentProfileScreen(),
          ),
        );
      case savedAddresses:
        return _route(settings, const SavedAddressesScreen());
      case myChildren:
        return _route(settings, const MyChildrenScreen());
      case addChild:
      case addChildStep1:
        return _route(settings, const AddChildStep1Screen());
      case addChildStep2:
        return _route(settings, const AddChildStep2Screen());
      case childDetail:
      case childDataDetails:
        return _childRoute(
          settings,
          (child) => ChildDataDetailsScreen(child: child),
        );
      case childPass:
        return _childRoute(settings, (child) => ChildPassScreen(child: child));
      case transportDetails:
        return _childRoute(
          settings,
          (child) => TransportDetailsScreen(child: child),
        );
      case subscriptionDetails:
        final subscriptionId = settings.arguments as int;
        return _route(
          settings,
          BlocProvider(
            create: (_) => getIt<SubscriptionsCubit>(),
            child: SubscriptionDetailsScreen(subscriptionId: subscriptionId),
          ),
        );

      // --- Wallet & Finance ---
      case parentWallet:
        return _route(settings, const WalletScreen());
      case parentRecharge:
        final walletCubit = settings.arguments as WalletCubit;
        return _route(
          settings,
          BlocProvider.value(
            value: walletCubit,
            child: const RechargeScreen(),
          ),
        );
      case parentInvoices:
        return _route(settings, const InvoicesScreen());
      case parentInvoiceDetails:
        final id = settings.arguments as int;
        return _route(settings, InvoiceDetailsScreen(invoiceId: id));

      // --- Trips & Live Tracking ---
      case parentTripsHome:
        return _route(settings, const TripsHomeScreen());
      case parentTripTracking:
        final trip = settings.arguments as ActiveTripModel;
        return _route(settings, TripTrackingScreen(trip: trip));
      case parentUpcomingTrips:
        return _route(settings, const UpcomingTripsScreen());
      case parentTripHistory:
        return _route(settings, const TripHistoryScreen());

      // --- Complaints ---
      case parentComplaints:
        return _route(settings, const ComplaintsListScreen());
      case createComplaint:
        final args = settings.arguments as Map<String, dynamic>;
        return _route(
          settings,
          CreateComplaintScreen(
            driverId: args['driverId'] as int,
            driverName: args['driverName'] as String,
            driverAvatar: args['driverAvatar'] as String?,
          ),
        );
      case complaintDetails:
        final id = settings.arguments as int;
        return _route(settings, ComplaintDetailsScreen(complaintId: id));

      case parentEmail:
        return _route(settings, const ParentEmailScreen());
      case parentOtp:
        final email = settings.arguments as String;
        return _route(settings, ParentOtpScreen(email: email));
      case parentBasicInfo:
        return _route(settings, const ParentBasicInfoScreen());
      case parentAvatar:
        return _route(settings, const ParentAvatarScreen());
      case parentAlternativePhone:
        return _route(settings, const ParentAlternativePhoneScreen());
      case parentLocation:
        return _route(settings, const ParentLocationScreen());
      default:
        return null;
    }
  }

  static Route<dynamic>? _buildDriverRoutes(RouteSettings settings) {
    switch (settings.name) {
      case driverHome:
        return _route(settings, const DriverHomeScreen());
      case driverMainWrapper:
        return _route(settings, const DriverMainWrapper());
      /*case driverBackupVehicle:
        return _route(settings, const DriverBackupVehicleScreen());*/
      case driverPrimaryVehicle:
        return _route(
          settings,
          BlocProvider(
            create: (_) => driverSl<VehicleCubit>(),
            child: const DriverPrimaryVehicleScreen(),
          ),
        );
      case driverProfile:
        return _route(
          settings,
          BlocProvider(
            create: (_) => driverSl<DriverProfileCubit>(),
            child: const DriverProfileScreen(),
          ),
        );
      case driverBasicInfo:
        return _route(settings, const DriverBasicInfoScreen());
      case driverAvatar:
        return _route(settings, const DriverAvatarScreen());
      case driverAlternativePhone:
        return _route(settings, const DriverAlternativePhoneScreen());
      case driverOtp:
        return _route(settings, const DriverOtpScreen());
      case driverNationalInfo:
        return _route(settings, const DriverNationalInfoScreen());
      case driverVehicleStage:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _route(settings, DriverVehicleStageScreen(collectedData: args));
      case driverDocsStage:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _route(settings, DriverDocsStageScreen(finalData: args));
      case driverLocation:
        return _route(settings, const DriverLocationScreen());
      case driverWaiting:
        return _route(settings, const DriverWaitingScreen());
      case driverPreferences:
        final isMandatory = settings.arguments as bool? ?? false;
        return _route(
          settings,
          BlocProvider(
            create: (context) => driverSl<DriverPreferencesCubit>(),
            child: DriverPreferencesScreen(isMandatory: isMandatory),
          ),
        );
      default:
        return null;
    }
  }

  static MaterialPageRoute<dynamic> _route(
    RouteSettings settings,
    Widget screen,
  ) {
    return MaterialPageRoute(settings: settings, builder: (_) => screen);
  }

  static Route<dynamic> _childRoute(
    RouteSettings settings,
    Widget Function(ChildModel child) builder,
  ) {
    final child = settings.arguments;
    if (child is! ChildModel) {
      return _errorRoute('بيانات الطفل غير موجودة.');
    }

    return _route(settings, builder(child));
  }

  static MaterialPageRoute<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text(message))),
    );
  }
}
