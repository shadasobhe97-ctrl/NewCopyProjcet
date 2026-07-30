import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

class MessengerChildItem {
  final int childId;
  final String childName;
  final String? childPhoto;
  final String childStatus; // in_bus, waiting, absent, arrived
  final int tripId;

  const MessengerChildItem({
    required this.childId,
    required this.childName,
    this.childPhoto,
    required this.childStatus,
    required this.tripId,
  });
}

class MessengerChildrenBar extends StatelessWidget {
  final List<MessengerChildItem> children;
  final bool isAllSelected;
  final int? selectedChildId;
  final VoidCallback onSelectAll;
  final Function(MessengerChildItem item) onSelectChild;

  const MessengerChildrenBar({
    super.key,
    required this.children,
    required this.isAllSelected,
    required this.selectedChildId,
    required this.onSelectAll,
    required this.onSelectChild,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: children.length + 1,
        separatorBuilder: (context, index) => SizedBox(width: 14.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "الكل" Circle (All Active Buses)
            return _buildAllCircle(context);
          }
          final item = children[index - 1];
          final isSelected = !isAllSelected && selectedChildId == item.childId;
          return _buildChildCircle(context, item, isSelected);
        },
      ),
    );
  }

  Widget _buildAllCircle(BuildContext context) {
    return GestureDetector(
      onTap: onSelectAll,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isAllSelected
                  ? LinearGradient(
                      colors: context.primaryGradient,
                    )
                  : null,
              border: !isAllSelected
                  ? Border.all(color: AppColors.grey300, width: 1.5)
                  : null,
            ),
            child: Container(
              width: 54.r,
              height: 54.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAllSelected
                    ? context.primaryColor
                    : (context.isDarkMode ? AppColors.grey800 : AppColors.grey100),
              ),
              child: Icon(
                Icons.directions_bus_rounded,
                color: isAllSelected ? AppColors.white : context.primaryColor,
                size: 28.r,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'الكل',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: isAllSelected ? FontWeight.bold : FontWeight.w500,
              color: isAllSelected ? context.primaryColor : context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCircle(BuildContext context, MessengerChildItem item, bool isSelected) {
    Color badgeColor = _getStatusBadgeColor(item.childStatus);
    String statusIconText = _getStatusIconText(item.childStatus);

    return GestureDetector(
      onTap: () => onSelectChild(item),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? LinearGradient(
                          colors: context.primaryGradient,
                        )
                      : null,
                  border: !isSelected
                      ? Border.all(color: badgeColor, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 27.r,
                  backgroundColor: context.isDarkMode ? AppColors.grey800 : AppColors.grey200,
                  backgroundImage: item.childPhoto != null && item.childPhoto!.isNotEmpty
                      ? CachedNetworkImageProvider(item.childPhoto!)
                      : null,
                  child: item.childPhoto == null || item.childPhoto!.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 28.r,
                          color: context.primaryColor,
                        )
                      : null,
                ),
              ),
              // Status Badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 14.r,
                    height: 14.r,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      statusIconText,
                      style: const TextStyle(fontSize: 8, color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          SizedBox(
            width: 64.w,
            child: Text(
              item.childName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? context.primaryColor : context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBadgeColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('in_bus') || s.contains('داخل الحافلة') || s.contains('onboard')) {
      return AppColors.success; // 🟢
    } else if (s.contains('waiting') || s.contains('ينتظر') || s.contains('pending')) {
      return AppColors.warning; // 🟡
    } else if (s.contains('absent') || s.contains('غائب')) {
      return AppColors.error; // 🔴
    } else if (s.contains('arrived') || s.contains('وصل') || s.contains('completed')) {
      return AppColors.info; // 🔵
    }
    return AppColors.success;
  }

  String _getStatusIconText(String status) {
    final s = status.toLowerCase();
    if (s.contains('in_bus') || s.contains('داخل الحافلة')) return '✓';
    if (s.contains('waiting') || s.contains('ينتظر')) return '⏱';
    if (s.contains('absent') || s.contains('غائب')) return '✕';
    if (s.contains('arrived') || s.contains('وصل')) return '✓';
    return '•';
  }
}
