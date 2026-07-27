/// نوع الغياب
enum AbsenceType {
  pickup,  // ذهاب فقط
  dropoff, // عودة فقط
  both;    // ذهاب وعودة

  String get value {
    switch (this) {
      case AbsenceType.pickup:
        return 'pickup';
      case AbsenceType.dropoff:
        return 'dropoff';
      case AbsenceType.both:
        return 'both';
    }
  }

  String get labelAr {
    switch (this) {
      case AbsenceType.pickup:
        return 'رحلة الذهاب فقط';
      case AbsenceType.dropoff:
        return 'رحلة العودة فقط';
      case AbsenceType.both:
        return 'ذهاب وعودة';
    }
  }

  static AbsenceType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pickup':
        return AbsenceType.pickup;
      case 'dropoff':
        return AbsenceType.dropoff;
      default:
        return AbsenceType.both;
    }
  }
}

/// نموذج بيانات الغياب المجدول
class AbsenceModel {
  final int? id;
  final int childId;
  final String date;
  final AbsenceType absenceType;
  final String typeLabel;
  final String? createdAt;

  const AbsenceModel({
    this.id,
    required this.childId,
    required this.date,
    required this.absenceType,
    required this.typeLabel,
    this.createdAt,
  });

  /// تحويل التاريخ إلى DateTime
  DateTime get dateTime {
    return DateTime.tryParse(date) ?? DateTime.now();
  }

  factory AbsenceModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final idVal = rawId is num ? rawId.toInt() : int.tryParse(rawId?.toString() ?? '');

    final rawChildId = json['child_id'] ?? 0;
    final childIdVal = rawChildId is num
        ? rawChildId.toInt()
        : int.tryParse(rawChildId.toString()) ?? 0;

    final rawType = json['absence_type']?.toString() ?? json['type']?.toString();
    final type = AbsenceType.fromString(rawType);

    final typeLabel = json['type_label']?.toString() ??
        json['absence_type_label']?.toString() ??
        type.labelAr;

    return AbsenceModel(
      id: idVal,
      childId: childIdVal,
      date: json['date']?.toString() ?? '',
      absenceType: type,
      typeLabel: typeLabel,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'child_id': childId,
      'date': date,
      'absence_type': absenceType.value,
    };
  }
}
