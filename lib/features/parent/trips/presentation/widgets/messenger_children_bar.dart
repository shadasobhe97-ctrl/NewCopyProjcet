import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';

class MessengerChildItem {
  final int childId;
  final String childName;
  final String? childPhoto;
  final String childStatus;
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
  final int activeTripsCount;
  final VoidCallback onSelectAll;
  final Function(MessengerChildItem item) onSelectChild;

  const MessengerChildrenBar({
    super.key,
    required this.children,
    required this.isAllSelected,
    required this.selectedChildId,
    this.activeTripsCount = 1,
    required this.onSelectAll,
    required this.onSelectChild,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 95.h, // ارتفاع مناسب بدون كونتينر خلفي
        child: ListView.separated(
          scrollDirection:
              Axis.horizontal, // سكرول أفقي يدعم حتى 10 أطفال وأكثر بسلاسة
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          itemCount: children.length + 1,
          separatorBuilder: (context, index) => SizedBox(width: 12.w),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildAllCircle(context);
            }
            final item = children[index - 1];
            final isSelected =
                !isAllSelected && selectedChildId == item.childId;
            return _buildChildCircle(context, item, isSelected);
          },
        ),
      ),
    );
  }

  Widget _buildAllCircle(BuildContext context) {
    return GestureDetector(
      onTap: onSelectAll,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isAllSelected
                    ? context.primaryColor
                    : Colors.transparent,
                width: 2.0,
              ),
            ),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: isAllSelected
                  ? context.primaryColor
                  : AppColors.grey200,
              child: Icon(
                Icons.directions_bus_rounded,
                color: isAllSelected ? AppColors.white : AppColors.grey700,
                size: 20.r,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'الكل',
            style: AppTextStyles.style(
              fontSize: 10.sp,
              fontWeight: isAllSelected ? FontWeight.bold : FontWeight.w600,
              color: isAllSelected ? context.primaryColor : context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCircle(
    BuildContext context,
    MessengerChildItem item,
    bool isSelected,
  ) {
    final statusColor = _getStatusColor(item.childStatus);

    return GestureDetector(
      onTap: () => onSelectChild(item),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: (!isAllSelected && !isSelected) ? 0.55 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusColor,
                  width: isSelected ? 2.5 : 1.5,
                ),
              ),
              child: AppUserAvatar(
                imageUrl: item.childPhoto,
                radius: 20.r,
                backgroundColor: context.isDarkMode
                    ? AppColors.grey800
                    : AppColors.grey200,
                iconColor: context.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: 50.w,
            child: Text(
              item.childName.split(' ')[0],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? context.primaryColor : context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('waiting') || s.contains('ينتظر')) {
      return AppColors.warning;
    }
    if (s.contains('in_bus') || s.contains('picked_up')) {
      return AppColors.success;
    }
    if (s.contains('absent') || s.contains('غائب')) {
      return AppColors.error;
    }
    return AppColors.grey400;
  }
}
