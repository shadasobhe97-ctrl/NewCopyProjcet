import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/child_model.dart';
import 'child_state.dart';

class ChildCubit extends Cubit<ChildState> {
  ChildCubit() : super(ChildInitial());

  // بيانات وهمية تجريبية - ستُستبدل بـ Repository + API لاحقاً
  final List<ChildModel> _children = [
    ChildModel(
      id: 'child-001',
      parentId: 'parent-001',
      schoolId: 'sch-1',
      schoolName: 'مدرسة الأمل النموذجية',
      fullName: 'عبدالله أحمد الفرجاني',
      birthDate: DateTime(2015, 5, 12),
      homeAddressId: 'addr-1',
      homeAddressTitle: 'المنزل الرئيسي (حي الأندلس)',
      notificationRadius: 300,
      qrCodeToken: 'QR-TOKEN-001',
      dailyStatus: DailyStatus.present,
      photoUrl: null,
      medicalNotes: 'لا يوجد',
      preferredTimeSlot: PreferredTimeSlot.MORNING,
      gender: 'MALE',
    ),
    ChildModel(
      id: 'child-002',
      parentId: 'parent-001',
      schoolId: 'sch-2',
      schoolName: 'مدرسة الفجر الحديثة',
      fullName: 'سارة أحمد الفرجاني',
      birthDate: DateTime(2018, 8, 20),
      homeAddressId: 'addr-1',
      homeAddressTitle: 'المنزل الرئيسي (حي الأندلس)',
      notificationRadius: 200,
      qrCodeToken: 'QR-TOKEN-002',
      dailyStatus: DailyStatus.absent,
      photoUrl: null,
      medicalNotes: 'حساسية من الغبار',
      preferredTimeSlot: PreferredTimeSlot.BOTH,
      gender: 'FEMALE',
    ),
  ];

  /// تحميل قائمة الأطفال
  Future<void> loadChildren() async {
    emit(ChildLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: استبدل بـ: final result = await _repository.getChildren();
    emit(ChildLoaded(children: List.from(_children)));
  }

  /// حذف طفل بالـ ID
  Future<void> deleteChild(String childId) async {
    emit(ChildLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: استبدل بـ: await _repository.deleteChild(childId);
    _children.removeWhere((c) => c.id == childId);
    emit(ChildLoaded(children: List.from(_children)));
  }

  /// إضافة طفل جديد
  Future<void> addChild(ChildModel child) async {
    emit(ChildLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: استبدل بـ: final result = await _repository.addChild(child);
    _children.add(child.copyWith(id: 'child-${DateTime.now().millisecondsSinceEpoch}'));
    emit(ChildLoaded(children: List.from(_children)));
  }

  /// تعديل بيانات طفل
  Future<void> updateChild(ChildModel updatedChild) async {
    emit(ChildLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: استبدل بـ: await _repository.updateChild(updatedChild);
    final index = _children.indexWhere((c) => c.id == updatedChild.id);
    if (index != -1) {
      _children[index] = updatedChild;
    }
    emit(ChildLoaded(children: List.from(_children)));
  }
}
