class ParentDriverModel {
  final int id;
  final int userId;
  final String name;
  final String? avatarUrl;
  final String? photoUrl;
  final String? image;
  final String? phoneNumber;
  final double rating;
  final String subscriptionStatus;
  final String subscriptionStatusLabel;

  ParentDriverModel({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.photoUrl,
    this.image,
    this.phoneNumber,
    required this.rating,
    required this.subscriptionStatus,
    required this.subscriptionStatusLabel,
  });

  String get effectivePhoto => photoUrl ?? avatarUrl ?? image ?? '';

  factory ParentDriverModel.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'];
    final parsedRating = rawRating is num
        ? rawRating.toDouble()
        : double.tryParse(rawRating?.toString() ?? '0') ?? 0.0;

    return ParentDriverModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'سائق',
      avatarUrl: json['avatar_url']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      image: json['image']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      rating: parsedRating,
      subscriptionStatus: json['subscription_status']?.toString() ?? '',
      subscriptionStatusLabel: json['subscription_status_label']?.toString() ?? '',
    );
  }
}
