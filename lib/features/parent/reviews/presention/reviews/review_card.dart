import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import 'package:kids_transport/features/parent/reviews/data/models/review_model.dart';
import 'rating_stars.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isOwnReview {
    final parentId = getIt<SessionRepository>().getParentId();
    final userId = getIt<SessionRepository>().getUserId();
    
    if (review.parent == null) return false;
    
    final isMatchingParent = parentId != null && review.parent!.id == parentId;
    final isMatchingUser = userId != null && review.parent!.userId.toString() == userId;
    
    return isMatchingParent || isMatchingUser;
  }

  String _fmtDate(String raw) {
    try {
      if (raw.isEmpty) return '—';
      final parts = raw.split('T');
      final dateStr = parts.first;
      final ymd = dateStr.split('-');
      if (ymd.length == 3) {
        return '${ymd[0]}/${ymd[1]}/${ymd[2]}';
      }
      return dateStr;
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18.r,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: (review.parent?.avatarUrl != null && review.parent!.avatarUrl!.isNotEmpty)
                    ? NetworkImage(review.parent!.avatarUrl!)
                    : null,
                child: (review.parent?.avatarUrl == null || review.parent!.avatarUrl!.isEmpty)
                    ? Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 18.r)
                    : null,
              ),
              SizedBox(width: 10.w),
              // Name and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.parent?.fullName ?? 'ولي أمر',
                      style: AppTextStyles.style(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    Text(
                      _fmtDate(review.createdAt),
                      style: AppTextStyles.style(
                        fontSize: 10.sp,
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating stars
              RatingStars(rating: review.rating.toDouble(), itemSize: 14.r),
              // Edit/Delete buttons if own review
              if (_isOwnReview) ...[
                SizedBox(width: 6.w),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: isDark ? AppColors.grey400 : AppColors.grey500, size: 20.r),
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  onSelected: (val) {
                    if (val == 'edit') {
                      onEdit();
                    } else if (val == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, color: theme.colorScheme.primary, size: 16.r),
                          SizedBox(width: 8.w),
                          Text('تعديل التقييم', style: AppTextStyles.style(fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16.r),
                          SizedBox(width: 8.w),
                          Text('حذف التقييم', style: AppTextStyles.style(fontSize: 12.sp, color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            review.comment,
            style: AppTextStyles.style(
              fontSize: 12.5.sp,
              color: isDark ? AppColors.grey200 : AppColors.textDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
