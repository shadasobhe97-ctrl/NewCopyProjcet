import 'package:equatable/equatable.dart';

/// عنصر مُشتق يمثل طفلاً واحداً داخل الرحلة الحية — يجمع بين:
/// - الحالة الموثوقة (status/trip_child_id) من تفاصيل الرحلة (children[])
/// - موقع المحطة المستهدفة (lat/lng/eta) من نقطة /stops
/// ضروري لأن نقطة /stops تُرجع محطة مدرسة واحدة مشتركة بين عدة أطفال،
/// بينما إجراءات الحالة تحتاج trip_child_id الفردي لكل طفل.
class LiveTripChildItem extends Equatable {
  final int tripChildId;
  final int childId;
  final String name;
  final String school;
  final String pickupAddress;
  final String dropoffAddress;
  final String status;
  final int sequenceOrder;
  final String? eta;
  final double? targetLatitude;
  final double? targetLongitude;
  final bool targetIsSchool;

  const LiveTripChildItem({
    required this.tripChildId,
    required this.childId,
    required this.name,
    required this.school,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.sequenceOrder,
    required this.eta,
    required this.targetLatitude,
    required this.targetLongitude,
    required this.targetIsSchool,
  });

  bool get isPickupPhase => status == 'pending';
  bool get isDropoffPhase => status == 'boarded';
  bool get isResolved => !isPickupPhase && !isDropoffPhase;

  LiveTripChildItem copyWith({String? status}) {
    return LiveTripChildItem(
      tripChildId: tripChildId,
      childId: childId,
      name: name,
      school: school,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      status: status ?? this.status,
      sequenceOrder: sequenceOrder,
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
        school,
        pickupAddress,
        dropoffAddress,
        status,
        sequenceOrder,
        eta,
        targetLatitude,
        targetLongitude,
        targetIsSchool,
      ];
}
