import 'transport_pref_model.dart';

class ChildModel {
  final int id;
  final String name;
  final String? image;
  final String gender;
  final DateTime birthDate;
  final int gradeLevel; // 1: روضة، 2: ابتدائي، 3: إعدادي، 4: ثانوي
  final int schoolId;
  final String schoolName; // للعرض في القائمة بدون عمل Fetch
  final int addressId;
  final String addressName; // للعرض في القائمة
  final String? medicalNotes;
  final String qrToken; // يرسله الباك إند
  final TransportPrefModel transportPref;
  final bool hasActiveSubscription;

  ChildModel({
    required this.id,
    required this.name,
    this.image,
    required this.gender,
    required this.birthDate,
    required this.gradeLevel,
    required this.schoolId,
    required this.schoolName,
    required this.addressId,
    required this.addressName,
    this.medicalNotes,
    required this.qrToken,
    required this.transportPref,
    this.hasActiveSubscription = false,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      gender: json['gender'],
      birthDate: DateTime.parse(json['birth_date']),
      gradeLevel: int.parse(json['grade_level'].toString()),
      schoolId: json['school_id'],
      schoolName: json['school_name'],
      addressId: json['address_id'],
      addressName: json['address_name'],
      medicalNotes: json['medical_notes'],
      qrToken: json['qr_token'],
      transportPref: TransportPrefModel.fromJson(json['transport_pref']),
      hasActiveSubscription: json['has_active_subscription'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // id, qrToken لا نرسلها عند الإضافة (يولدها الباك إند)
      'name': name,
      'image': image,
      'gender': gender,
      'birth_date': birthDate.toIso8601String(),
      'grade_level': gradeLevel,
      'school_id': schoolId,
      'address_id': addressId,
      'medical_notes': medicalNotes,
      'transport_pref': transportPref.toJson(),
      'has_active_subscription': hasActiveSubscription,
    };
  }
}