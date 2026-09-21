import 'package:equatable/equatable.dart';

/// عنصر مُشتق يمثل طفلاً واحداً داخل الرحلة الحية — يجمع بين:
/// - الحالة الموثوقة (status/trip_child_id) من تفاصيل الرحلة (children[])
/// - موقع المحطة المستهدفة (lat/lng/eta) من تفاصيل الطفل مباشرة أو نقطة /stops
class LiveTripChildItem extends Equatable {
  final int tripChildId;
  final int childId;
  final String name;
  final String? photo;
  final String school;
  final String pickupAddress;
  final String dropoffAddress;
  final String status;
  final int sequenceOrder;

  /// ترتيب المحطة الرسمي القادم من stops[].sequence_order للمحطة المطابقة
  /// لهذا الطفل عبر child_id/school_id — هو المصدر الوحيد المعتمد لترتيب
  /// عرض المحطات بالرحلة الحية. يكون null فقط إذا تعذّر إيجاد محطة مطابقة
  /// ببيانات Backend (بيانات ناقصة)، وعندها يُوضع العنصر بنهاية القائمة
  /// كحل احتياطي بدون اختراع ترتيب.
  final int? stopSequenceOrder;
  final String? eta;
  final double? targetLatitude;
  final double? targetLongitude;
  final bool targetIsSchool;

  const LiveTripChildItem({
    required this.tripChildId,
    required this.childId,
    required this.name,
    this.photo,
    required this.school,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.sequenceOrder,
    this.stopSequenceOrder,
    required this.eta,
    required this.targetLatitude,
    required this.targetLongitude,
    required this.targetIsSchool,
  });

  bool get isPickupPhase => status == 'pending';
  bool get isDropoffPhase => status == 'boarded';

  /// حالات نهائية معروفة فعلياً بالـ Backend Contract (مطابقة تماماً لما
  /// يميّزه [TripChildStatusBadge] بواجهة العرض). أي status غير مُدرج هنا
  /// (بما فيه أي status جديد يُضيفه الـ Backend مستقبلاً) يُعتبر تلقائياً
  /// **غير منتهٍ** (isResolved = false) حتى لا تختفي أزرار الإجراء بصمت.
  static const Set<String> _terminalStatuses = {
    'completed',
    'skipped',
    'skipped_unresponsive',
    'absent',
    'absent_late',
    'absent_pre',
    'dropped_off',
    'dropped_off_school',
    'delivered_home',
    'dropoff_failed',
    'direct_parent_handling',
  };

  bool get isResolved => _terminalStatuses.contains(status);

  LiveTripChildItem copyWith({String? status}) {
    return LiveTripChildItem(
      tripChildId: tripChildId,
      childId: childId,
      name: name,
      photo: photo,
      school: school,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      status: status ?? this.status,
      sequenceOrder: sequenceOrder,
      stopSequenceOrder: stopSequenceOrder,
      eta: eta,
      targetLatitude: targetLatitude,
      targetLongitude: targetLongitude,
      targetIsSchool: targetIsSchool,
    );
  }

  @override
  List<Object?> get props => [
        tripChildId,
        childId,
        name,
        photo,
        school,
        pickupAddress,
        dropoffAddress,
        status,
        sequenceOrder,
        stopSequenceOrder,
        eta,
        targetLatitude,
        targetLongitude,
        targetIsSchool,
      ];
}
