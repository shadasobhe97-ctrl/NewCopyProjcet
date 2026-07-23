class ReviewParentModel {
  final int id;
  final int userId;
  final String fullName;
  final String? avatarUrl;

  ReviewParentModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
  });

  factory ReviewParentModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : null;
    final parentId = json['id'] ?? json['parent_id'] ?? 0;
    final userId = json['user_id'] ?? userMap?['id'] ?? 0;
    final fullName = json['full_name'] ?? json['name'] ?? userMap?['full_name'] ?? userMap?['name'] ?? 'ولي أمر';
    final avatarUrl = json['avatar_url'] ?? json['photo_url'] ?? userMap?['avatar_url'] ?? userMap?['photo_url'];

    return ReviewParentModel(
      id: parentId is num ? parentId.toInt() : int.tryParse(parentId.toString()) ?? 0,
      userId: userId is num ? userId.toInt() : int.tryParse(userId.toString()) ?? 0,
      fullName: fullName.toString(),
      avatarUrl: avatarUrl?.toString(),
    );
  }
}

class ReviewModel {
  final int id;
  final int driverId;
  final int rating;
  final String comment;
  final String createdAt;
  final ReviewParentModel? parent;

  ReviewModel({
    required this.id,
    required this.driverId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.parent,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final reviewId = json['id'] ?? 0;
    final driverId = json['driver_id'] ?? 0;
    final rating = json['rating'] ?? 0;
    final comment = json['comment'] ?? '';
    final createdAt = json['created_at'] ?? '';
    final parentData = json['parent'] is Map 
        ? ReviewParentModel.fromJson(Map<String, dynamic>.from(json['parent'] as Map))
        : null;

    return ReviewModel(
      id: reviewId is num ? reviewId.toInt() : int.tryParse(reviewId.toString()) ?? 0,
      driverId: driverId is num ? driverId.toInt() : int.tryParse(driverId.toString()) ?? 0,
      rating: rating is num ? rating.toInt() : int.tryParse(rating.toString()) ?? 0,
      comment: comment.toString(),
      createdAt: createdAt.toString(),
      parent: parentData,
    );
  }
}

class ReviewsResponse {
  final List<ReviewModel> reviews;
  final int currentPage;
  final bool hasMore;

  ReviewsResponse({
    required this.reviews,
    required this.currentPage,
    required this.hasMore,
  });

  factory ReviewsResponse.fromJson(dynamic json) {
    List<ReviewModel> list = [];
    int page = 1;
    bool more = false;

    if (json is List) {
      list = json.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (json is Map) {
      final dataObj = json['data'];
      
      if (dataObj is List) {
        list = dataObj.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (dataObj is Map) {
        final items = dataObj['data'];
        if (items is List) {
          list = items.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
        }
        page = dataObj['current_page'] as int? ?? 1;
        final lastPage = dataObj['last_page'] as int? ?? 1;
        more = page < lastPage;
      }

      if (json['current_page'] != null) {
        page = json['current_page'] as int? ?? 1;
        final lastPage = json['last_page'] as int? ?? 1;
        more = page < lastPage;
      }
    }

    return ReviewsResponse(
      reviews: list,
      currentPage: page,
      hasMore: more,
    );
  }
}
