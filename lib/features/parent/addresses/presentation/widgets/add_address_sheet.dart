import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// Bottom Sheet إضافة عنوان جديد بالخريطة.
class AddAddressSheet extends StatefulWidget {
  final void Function(Map<String, dynamic> newAddress) onSave;

  const AddAddressSheet({super.key, required this.onSave});

  @override
  State<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<AddAddressSheet> {
  final MapController _mapController = MapController();
  final _labelController = TextEditingController();
  final _detailsController = TextEditingController();
  LatLng _currentCenter = const LatLng(32.8872, 13.1913);
  bool _isDefault = false;

  @override
  void dispose() {
    _mapController.dispose();
    _labelController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: AppTheme.verticalRadius(top: AppTheme.cornerRadius(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // شريط السحب
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: AppTheme.boxDecoration(
                  color: AppColors.grey400,
                  borderRadius: AppTheme.radius(10),
                ),
              ),
            ),
            // العنوان
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إضافة عنوان جديد',
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // الخريطة
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentCenter,
                      initialZoom: 14.5,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture && position.center != null) {
                          _currentCenter = position.center!;
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.kids_transport',
                      ),
                    ],
                  ),
                  // دبوس ثابت
                  IgnorePointer(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 45,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  // إرشاد فوق الخريطة
                  Positioned(
                    top: 10,
                    right: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: AppTheme.boxDecoration(
                        color: AppColors.black.withValues(alpha: 0.7),
                        borderRadius: AppTheme.radius(10),
                      ),
                      child: Text(
                        'قم بسحب الخريطة لتركيز الدبوس في موقعك بدقة',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style(
                          color: AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // نموذج البيانات
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _labelController,
                    textAlign: TextAlign.right,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: 'اسم العنوان (مثال: العمل، بيت الجدة)',
                      prefixIcon: const Icon(
                        Icons.label_outline_rounded,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _detailsController,
                    textAlign: TextAlign.right,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: 'تفاصيل العنوان / الشقة / علامة مميزة',
                      prefixIcon: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text('تعيين كعنوان رئيسي'),
                    value: _isDefault,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => setState(() => _isDefault = val ?? false),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _save,
                    style: AppTheme.elevatedButtonStyle(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primaryLight,
                    ),
                    child: Text(
                      'حفظ العنوان',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم العنوان أولاً'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    widget.onSave({
      'id': 'addr-${DateTime.now().millisecondsSinceEpoch}',
      'title': _labelController.text.trim(),
      'latitude': _currentCenter.latitude,
      'longitude': _currentCenter.longitude,
      'is_default': _isDefault,
      'details': _detailsController.text.trim(),
    });
    Navigator.pop(context);
  }
}
