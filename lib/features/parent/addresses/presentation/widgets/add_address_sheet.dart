import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';

/// Bottom Sheet إضافة / تعديل عنوان بالخريطة.
class AddAddressSheet extends StatefulWidget {
  /// يُستدعى عند الحفظ — يعيد رسالة الخطأ أو null عند النجاح.
  final Future<String?> Function(AddressModel address) onSave;

  /// إذا كان غير null فهذا وضع التعديل.
  final AddressModel? initialAddress;

  const AddAddressSheet({
    super.key,
    required this.onSave,
    this.initialAddress,
  });

  @override
  State<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<AddAddressSheet> {
  final MapController _mapController = MapController();
  final _labelController = TextEditingController();
  late LatLng _currentCenter;
  bool _isDefault = false;
  bool _isLoading = false;

  bool get _isEditMode => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;
    if (addr != null) {
      _labelController.text = addr.title;
      _currentCenter = LatLng(addr.latitude, addr.longitude);
      _isDefault = addr.isDefault;
    } else {
      _currentCenter = const LatLng(32.8872, 13.1913);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getUserLocation();
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      if (mounted && widget.initialAddress == null) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentCenter, 15.5);
      }
    } catch (_) {
      // Keep default coordinates in case of error/timeout
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _labelController.dispose();
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
                    _isEditMode ? 'تعديل العنوان' : 'إضافة عنوان جديد',
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                        if (hasGesture) {
                          _currentCenter = position.center;
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
                    enabled: !_isLoading,
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
                  CheckboxListTile(
                    title: const Text('تعيين كعنوان رئيسي'),
                    value: _isDefault,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primaryLight,
                    onChanged: _isLoading
                        ? null
                        : (val) => setState(() => _isDefault = val ?? false),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: AppTheme.elevatedButtonStyle(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: _isLoading ? AppColors.grey400 : AppColors.primaryLight,
                      foregroundColor: AppColors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            _isEditMode ? 'تحديث العنوان' : 'حفظ العنوان',
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

  Future<void> _save() async {
    final labelText = _labelController.text.trim();
    if (labelText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اسم العنوان مطلوب'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final lat = _currentCenter.latitude;
    final lng = _currentCenter.longitude;

    if (lat == 0.0 && lng == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد موقع صالح على الخريطة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('إحداثيات الموقع غير صالحة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final address = AddressModel(
      id: widget.initialAddress?.id,
      label: labelText,
      lat: lat,
      lng: lng,
      isDefault: _isDefault,
    );

    final errorMsg = await widget.onSave(address);

    if (!mounted) return;

    if (errorMsg != null) {
      // فشلت العملية — أظهر خطأ وأبق الـ Sheet مفتوحة
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      // نجحت العملية — أغلق الـ Sheet
      Navigator.pop(context);
    }
  }
}
