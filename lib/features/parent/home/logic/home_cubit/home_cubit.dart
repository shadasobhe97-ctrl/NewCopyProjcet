import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/home/logic/home_cubit/home_state.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

class ParentHomeCubit extends Cubit<ParentHomeState> {
  ParentHomeCubit() : super(ParentHomeLoading());

  // دالة محاكاة لجلب البيانات وفحص حالة ولي الأمر (تتغير لاحقاً بربط الـ Repository)
  void fetchParentHomeData(int simulatedStateCase) {
    emit(ParentHomeLoading());
    
    // محاكاة تأخير الشبكة
    Future.delayed(const Duration(milliseconds: 800), () {
      switch (simulatedStateCase) {
        case 1:
          emit(ParentNewUserMode());
          break;
          
        case 2:
          emit(ParentHasKidsNoSubscription(kids: [
            ChildModel(
              id: "1", fullName: "عبدالله أحمد", schoolId: "s1", schoolName: "مدرسة الأمل",
              birthDate: DateTime(2015, 5, 12), homeAddressId: "h1", homeAddressTitle: "المنزل الرئيسي",
              preferredTimeSlot: PreferredTimeSlot.MORNING, gender: "MALE"
            ),
            ChildModel(
              id: "2", fullName: "سارة أحمد", schoolId: "s1", schoolName: "مدرسة الأمل النموذجية",
              birthDate: DateTime(2018, 8, 20), homeAddressId: "h1", homeAddressTitle: "المنزل الرئيسي",
              preferredTimeSlot: PreferredTimeSlot.BOTH, gender: "FEMALE"
            ),
          ]));
          break;
          
        case 3:
          emit(ParentPendingRequestsMode(pendingRequests: [
            {
              'children': 'عبدالله + سارة',
              'driver_name': 'أحمد الوداني',
              'status': 'بانتظار موافقة السائق',
              'type': 'طلب اشتراك جديد'
            }
          ]));
          break;
          
        case 4:
          emit(ParentActiveTripMode(
            todayTrips: [
              {'name': 'عبدالله', 'time': '07:00 ص', 'status': 'تم الاستلام'},
              {'name': 'سارة', 'time': '01:00 م', 'status': 'مجدولة'},
            ],
            activeTrip: {
              'child_name': 'عبدالله',
              'driver_name': 'أحمد الوداني',
              'status': 'في الطريق إلى المدرسة'
            }
          ));
          break;
          
        default:
          emit(ParentHomeError(errorMessage: "حدث خطأ غير متوقع أثناء تحميل البيانات."));
      }
    });
  }
}