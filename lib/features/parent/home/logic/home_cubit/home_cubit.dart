import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/data/models/transport_pref_model.dart';
import 'package:kids_transport/features/parent/home/logic/home_cubit/home_state.dart';

class ParentHomeCubit extends Cubit<ParentHomeState> {
  ParentHomeCubit() : super(ParentHomeLoading());

  void fetchParentHomeData(int simulatedStateCase) {
    emit(ParentHomeLoading());

    Future.delayed(const Duration(milliseconds: 800), () {
      switch (simulatedStateCase) {
        case 1:
          emit(ParentNewUserMode());
          break;

        case 2:
          emit(
            ParentHasKidsNoSubscription(
              kids: [
                ChildModel(
                  id: 1,
                  name: 'عبدالله أحمد',
                  gender: 'male',
                  birthDate: DateTime(2015, 5, 12),
                  gradeLevel: 2,
                  schoolId: 101,
                  schoolName: 'مدرسة الأمل',
                  addressId: 1,
                  addressName: 'المنزل الرئيسي',
                  qrToken: 'darbi_home_qr_1',
                  transportPref: TransportPrefModel(
                    subscriptionType: 'monthly',
                    period: 'morning',
                    serviceType: 'both',
                    startDate: DateTime.now(),
                    schoolStartTime: '08:00 AM',
                    schoolEndTime: '01:30 PM',
                  ),
                ),
                ChildModel(
                  id: 2,
                  name: 'سارة أحمد',
                  gender: 'female',
                  birthDate: DateTime(2018, 8, 20),
                  gradeLevel: 1,
                  schoolId: 101,
                  schoolName: 'مدرسة الأمل النموذجية',
                  addressId: 1,
                  addressName: 'المنزل الرئيسي',
                  qrToken: 'darbi_home_qr_2',
                  transportPref: TransportPrefModel(
                    subscriptionType: 'weekly',
                    period: 'morning',
                    serviceType: 'both',
                    startDate: DateTime.now(),
                    schoolStartTime: '08:15 AM',
                    schoolEndTime: '01:00 PM',
                  ),
                ),
              ],
            ),
          );
          break;

        case 3:
          emit(
            ParentPendingRequestsMode(
              pendingRequests: [
                {
                  'children': 'عبدالله + سارة',
                  'driver_name': 'أحمد الوداني',
                  'status': 'بانتظار موافقة السائق',
                  'type': 'طلب اشتراك جديد',
                },
              ],
            ),
          );
          break;

        case 4:
          emit(
            ParentActiveTripMode(
              todayTrips: [
                {'name': 'عبدالله', 'time': '07:00 ص', 'status': 'تم الاستلام'},
                {'name': 'سارة', 'time': '01:00 م', 'status': 'مجدولة'},
              ],
              activeTrip: {
                'child_name': 'عبدالله',
                'driver_name': 'أحمد الوداني',
                'status': 'في الطريق إلى المدرسة',
              },
            ),
          );
          break;

        default:
          emit(
            ParentHomeError(
              errorMessage: 'حدث خطأ غير متوقع أثناء تحميل البيانات.',
            ),
          );
      }
    });
  }
}
