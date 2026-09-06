import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';
import 'package:kids_transport/features/parent/addresses/data/repositories/address_repository.dart';

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
  final _streetController = TextEditingController();
  late LatLng _currentCenter;
  bool _isLoading = false;

  // إدارة المناطق
  List<ZoneModel> _zones = [];
  bool _isLoadingZones = true;
  String? _zonesError;
  int? _selectedZoneId;
  String? _selectedZoneName;

  bool get _isEditMode => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;
    if (addr != null) {
      _labelController.text = addr.title;
      _streetController.text = addr.streetAddress ?? '';
      _selectedZoneId = addr.zoneId;
      _selectedZoneName = addr.zoneName;
      _currentCenter = LatLng(addr.latitude, addr.longitude);
    } else {
      _currentCenter = const LatLng(32.8872, 13.1913);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getUserLocation();
      });
    }

    _loadZones();
  }

  Future<void> _loadZones() async {
    setState(() {
      _isLoadingZones = true;
      _zonesError = null;
    });

    try {
      final repository = getIt<AddressRepository>();
      final (zones, error) = await repository.getZones();

      if (!mounted) return;

      if (error != null || zones == null) {
        setState(() {
          _isLoadingZones = false;
          _zonesError = error ?? 'تعذر تحميل المناطق';
        });
      } else {
        setState(() {
          _isLoadingZones = false;
          _zones = zones;
          if (_selectedZoneId != null) {
            final match = _zones.where((z) => z.id == _selectedZoneId);
            if (match.isNotEmpty) {
              _selectedZoneName = match.first.name;
            }
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingZones = false;
        _zonesError = 'تعذر تحميل المناطق';
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
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
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
              flex: 5,
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
                      color: primaryColor,
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
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  top: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // حقل اسم العنوان
                    TextFormField(
                      controller: _labelController,
                      textAlign: TextAlign.right,
                      enabled: !_isLoading,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: 'اسم العنوان (مثال: المنزل، العمل، المدرسة)',
                        prefixIcon: const Icon(
                          Icons.label_outline_rounded,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // حقل وصف العنوان / الشارع
                    TextFormField(
                      controller: _streetController,
                      textAlign: TextAlign.right,
                      enabled: !_isLoading,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: 'وصف العنوان / الشارع (مثال: شارع بن عاشور)',
                        prefixIcon: const Icon(
                          Icons.signpost_outlined,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // اختيار المنطقة
                    _buildZoneSelector(context),

                    const SizedBox(height: 16),

                    // زر الحفظ
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: AppTheme.elevatedButtonStyle(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _isLoading
                            ? AppColors.grey400
                            : AppColors.primaryLight,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneSelector(BuildContext context) {
    if (_isLoadingZones) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.boxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCard
              : AppColors.grey50,
          borderRadius: AppTheme.radius(12),
          border: AppTheme.border(color: AppColors.grey300, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'جاري تحميل المناطق...',
              style: AppTextStyles.style(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (_zonesError != null && _zones.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: AppTheme.boxDecoration(
          color: AppColors.errorLight.withValues(alpha: 0.1),
          borderRadius: AppTheme.radius(12),
          border: AppTheme.border(color: AppColors.errorLight, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تعذر تحميل المناطق',
                style: AppTextStyles.style(
                  color: AppColors.error,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadZones,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: _selectedZoneId != null &&
              _zones.any((z) => z.id == _selectedZoneId)
          ? _selectedZoneId
          : null,
      decoration: AppTheme.inputDecoration(
        context,
        labelText: 'المنطقة',
        prefixIcon: const Icon(
          Icons.map_outlined,
          color: AppColors.primaryLight,
        ),
      ),
      hint: Text(
        'اختر المنطقة',
        style: AppTextStyles.style(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
      ),
      isExpanded: true,
      items: _zones.map((zone) {
        return DropdownMenuItem<int>(
          value: zone.id,
          child: Text(
            zone.name,
            style: AppTextStyles.style(
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
      onChanged: _isLoading
          ? null
          : (val) {
              setState(() {
                _selectedZoneId = val;
                if (val != null) {
                  final match = _zones.where((z) => z.id == val);
                  _selectedZoneName =
                      match.isNotEmpty ? match.first.name : null;
                }
              });
            },
    );
  }

  Future<void> _save() async {
    final titleText = _labelController.text.trim();
    if (titleText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اسم العنوان مطلوب'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final streetText = _streetController.text.trim();
    if (streetText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال وصف العنوان / الشارع'),
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

    if (_selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المنطقة التي يتبع لها العنوان'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final address = AddressModel(
      id: widget.initialAddress?.id,
      title: titleText,
      streetAddress: streetText,
      latitude: lat,
      longitude: lng,
      zoneId: _selectedZoneId,
      zoneName: _selectedZoneName,
      isDefault: widget.initialAddress?.isDefault ?? false,
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
