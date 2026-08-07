class SeatSlotModel {
  final int totalSeats;
  final int reservedSeats;
  final int availableSeats;

  SeatSlotModel({
    required this.totalSeats,
    required this.reservedSeats,
    required this.availableSeats,
  });

  factory SeatSlotModel.fromJson(Map<String, dynamic> json) {
    return SeatSlotModel(
      totalSeats: json['total_seats'] as int? ?? 0,
      reservedSeats: json['reserved_seats'] as int? ?? 0,
      availableSeats: json['available_seats'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_seats': totalSeats,
      'reserved_seats': reservedSeats,
      'available_seats': availableSeats,
    };
  }
}
