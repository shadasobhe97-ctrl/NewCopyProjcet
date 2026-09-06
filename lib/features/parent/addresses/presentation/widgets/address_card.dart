import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// بطاقة عنوان واحد في شاشة العناوين المحفوظة.
class AddressCard extends StatelessWidget {
  String _formatCoords(dynamic lat, dynamic lng) {
    final latStr = (lat is num) ? lat.toStringAsFixed(4) : '0.0000';
    final lngStr = (lng is num) ? lng.toStringAsFixed(4) : '0.0000';
    return 'إحداثيات: ($latStr, $lngStr)';
  }

  final Map<String, dynamic> address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final title = address['title']?.toString() ?? 'عنوان بدون اسم';
    final streetAddress = address['street_address']?.toString() ??
        address['streetAddress']?.toString();
    final zoneName =
        address['zone_name']?.toString() ?? address['zoneName']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(
          color: AppColors.transparent,
          width: 1,
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.radius(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // تفاصيل العنوان
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (streetAddress != null &&
                            streetAddress.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.signpost_outlined,
                                size: 14,
                                color:
                                    AppColors.textMuted.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  streetAddress.trim(),
                                  style: AppTextStyles.style(
                                    color: isDark
                                        ? AppColors.grey300
                                        : AppColors.grey700,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (zoneName != null &&
                            zoneName.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_city_outlined,
                                size: 14,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'المنطقة: ${zoneName.trim()}',
                                  style: AppTextStyles.style(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          _formatCoords(
                            address['latitude'] ?? address['lat'],
                            address['longitude'] ?? address['lng'],
                          ),
                          style: AppTextStyles.style(
                            color: AppColors.textMuted.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // شريط التحكم (تعديل + حذف)
            Container(
              color: isDark ? AppColors.black26 : AppColors.grey50,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: primaryColor,
                    ),
                    label: Text(
                      'تعديل',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
