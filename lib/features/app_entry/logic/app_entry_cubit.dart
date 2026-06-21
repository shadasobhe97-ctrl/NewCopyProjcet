import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'app_entry_state.dart';

class AppEntryCubit extends Cubit<AppEntryState> {
  AppEntryCubit() : super(AppEntryInitial());

  void checkSession() async {
    await Future.delayed(const Duration(seconds: 2)); // تأثير وقت السبلاش

    // 1. تفقد هل المستخدم جديد كلياً؟
    final bool isFirstTimeUser = StorageService.isFirstTime();

    if (isFirstTimeUser) {
      // لو أول مرة في حياته يفتح التطبيق، نرفعوه للأونبوردينق
      emit(NavigateToOnboarding());
    } else {
      // 2. لو مش أول مرة، تفقد هل هو مسجل دخول مسبقاً؟
      // 2. لو مش أول مرة، تفقد هل هو مسجل دخول مسبقاً؟
      final token = StorageService.getToken();
      final roleId = StorageService.getRoleId(); // نقروا الـ ID المخزن

      if (token == null) {
        // مش أول مرة، لكن مش مسجل دخول، نرفعوه لصفحة الدخول فوراً
        emit(NavigateToLogin());
      } else {
        // مسجل دخول مسبقاً، نوجهوه حسب الـ ID تابعه ديناميكياً
        if (roleId == 2 || roleId == "2") {
          emit(NavigateToDriverHome()); // الـ ID رقم 2 خاص بالسائق
        } else if (roleId == 3 || roleId == "3") {
          emit(
            NavigateToParentHome(),
          ); // الـ ID رقم 3 خاص بولي الأمر (حسب الـ Response)
        } else {
          // حماية إضافية لو الـ ID مش معروف أو صار خطأ في الكاش
          emit(NavigateToLogin());
        }
      }
    }
  }
}
