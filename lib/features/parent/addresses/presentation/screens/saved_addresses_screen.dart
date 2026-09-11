import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/hive_helper.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_bars.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import 'package:kids_transport/features/parent/addresses/data/datasources/address_remote_data_source.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _titleController = TextEditingController();

  AddressModel? _currentAddress;
  LatLng _selectedCenter = const LatLng(32.8872, 13.1913); // طرابلس افتراضياً
  ZoneModel? _selectedZone;

  List<ZoneModel> _zones = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLocating = false;
  bool _isEditMode = false; // وضع التعديل

  static const String _defaultAddressHiveKey = 'default_address';

  @override
  void initState() {
    super.initState();
    _loadCachedAddress();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// تحميل أولي فوري من الـ Hive (Offline First)
  void _loadCachedAddress() {
    try {
      final box = HiveHelper.addressesBox;
      final cachedMap = box.get(_defaultAddressHiveKey);
      if (cachedMap != null) {
        final address = AddressModel.fromJson(Map<String, dynamic>.from(cachedMap));
        _applyAddress(address);
      }
    } catch (e) {
      debugPrint('⚠️ [SavedAddressesScreen] loadCachedAddress error: $e');
    }
  }

  void _applyAddress(AddressModel address) {
    _currentAddress = address;
    _titleController.text = address.title;
    if (address.latitude != 0.0 && address.longitude != 0.0) {
      _selectedCenter = LatLng(address.latitude, address.longitude);
    }
    if (address.zoneId != null) {
      final match = _zones.where((z) => z.id == address.zoneId);
      if (match.isNotEmpty) {
        _selectedZone = match.first;
      } else if (address.zoneName != null && address.zoneName!.isNotEmpty) {
        _selectedZone = ZoneModel(
          id: address.zoneId!,
          name: address.zoneName!,
        );
      }
    }
  }

  Future<void> _loadData() async {
    final dataSource = AddressRemoteDataSource(ApiClient());
    try {
      final token = StorageService.getToken() ?? '';
      final results = await Future.wait([
        dataSource.getDefaultAddress(),
        dataSource.getZones(token: token),
      ]);

      final address = results[0] as AddressModel?;
      final zones = results[1] as List<ZoneModel>;

      if (mounted) {
        setState(() {
          _zones = zones;
          if (address != null) {
            _applyAddress(address);
            // حفظ في Hive للاستخدام دون إنترنت
            try {
              HiveHelper.addressesBox.put(_defaultAddressHiveKey, address.toDisplayMap());
            } catch (_) {}
          }
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(_selectedCenter, 15.5);
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ [SavedAddressesScreen] loadData error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        if (_currentAddress == null) {
          _showSnack('تعذر تحميل بيانات العنوان: $e', isError: true);
        }
      }
    }
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _showSnack('يرجى تفعيل صلاحية تحديد الموقع (GPS).', isError: true);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final newLoc = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedCenter = newLoc;
      });
      _mapController.move(newLoc, 16.0);
    } catch (e) {
      _showSnack('تعذر تحديد موقعك الحالي: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showZonePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredZones = _zones.where((z) {
              final q = searchQuery.trim().toLowerCase();
              if (q.isEmpty) return true;
              return z.name.toLowerCase().contains(q);
            }).toList();

            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: AppTheme.boxDecoration(
                color: isDark ? AppColors.grey950 : AppColors.white,
                borderRadius: AppTheme.onlyRadius(
                  topLeft: AppTheme.cornerRadius(24),
                  topRight: AppTheme.cornerRadius(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "اختر المنطقة السكنية",
                    style: AppTextStyles.style(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    textAlign: TextAlign.right,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: "ابحث باسم المنطقة...",
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredZones.isEmpty
                        ? Center(
                            child: Text(
                              _zones.isEmpty
                                  ? "لا توجد مناطق متاحة حالياً."
                                  : "لا توجد مناطق تطابق البحث.",
                              style: AppTextStyles.style(color: AppColors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredZones.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final zone = filteredZones[index];
                              final isSelected = _selectedZone?.id == zone.id;
                              return ListTile(
                                leading: Icon(
                                  Icons.location_on_outlined,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : AppColors.grey400,
                                ),
                                title: Text(
                                  zone.name,
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.style(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : null,
                                  ),
                                ),
                                onTap: () {
                                  setState(() => _selectedZone = zone);
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// عند طلب التعديل: إظهار دايلوق تحذيري بأن التعديل سيشمل كل أطفاله
  void _promptEditConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24.r),
            SizedBox(width: 8.w),
            Text(
              'تنبيه مهم',
              style: AppTextStyles.style(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'تعديل هذا العنوان الرئيسي سيؤدي إلى تحديث موقع الاستلام المعتمد لكافة أطفالك المسجلين.\n\nهل ترغب بالاستمرار والتعديل؟',
          style: AppTextStyles.style(
            fontSize: 13.5.sp,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: AppTextStyles.style(
                color: AppColors.grey600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isEditMode = true);
            },
            child: Text(
              'نعم، استمرار',
              style: AppTextStyles.style(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAddress() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showSnack('يرجى كتابة تسمية العنوان (مثل: المنزل الرئيسي).', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final dataSource = AddressRemoteDataSource(ApiClient());

    final addressToSave = AddressModel(
      id: _currentAddress?.id,
      title: title,
      latitude: _selectedCenter.latitude,
      longitude: _selectedCenter.longitude,
      isDefault: true,
      zoneId: _selectedZone?.id ?? _currentAddress?.zoneId,
      zoneName: _selectedZone?.name ?? _currentAddress?.zoneName,
    );

    try {
      String message;
      if (addressToSave.id != null && addressToSave.id!.isNotEmpty) {
        message = await dataSource.updateAddress(addressToSave);
      } else {
        message = await dataSource.addAddress(addressToSave);
      }

      if (mounted) {
        setState(() {
          _currentAddress = addressToSave;
          _isSaving = false;
          _isEditMode = false; // إغلاق وضع التعديل بعد الحفظ
        });

        // حفظ في Hive
        try {
          HiveHelper.addressesBox.put(_defaultAddressHiveKey, addressToSave.toDisplayMap());
        } catch (_) {}

        _showSnack(message.isNotEmpty ? message : 'تم حفظ وتحديث العنوان بنجاح');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnack(e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnack('تعذر حفظ العنوان: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppPrimaryAppBar(
          title: 'عنواني',
          actions: [
            // زر التعديل دائماً في الـ AppBar على اليسار
            if (!_isEditMode)
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'تعديل العنوان',
                onPressed: _promptEditConfirmation,
              ),
            if (_isEditMode)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                tooltip: 'إلغاء التعديل',
                onPressed: () {
                  setState(() {
                    _isEditMode = false;
                    if (_currentAddress != null) {
                      _applyAddress(_currentAddress!);
                    }
                  });
                  _mapController.move(_selectedCenter, 15.5);
                },
              ),
          ],
        ),
        // زر الحفظ ثابت في الأسفل داخل BottomNavigationBar عند وضع التعديل
        bottomNavigationBar: _isEditMode
            ? BottomActionBar(
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    style: AppTheme.elevatedButtonStyle(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    onPressed: _isSaving ? null : _saveAddress,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "حفظ التعديلات",
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              )
            : null,
        body: _isLoading && _currentAddress == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🗺️ كارد الخريطة مع حواف دائرية (Rounded Card)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                      child: Container(
                        height: 260.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AbsorbPointer(
                                absorbing: !_isEditMode,
                                child: FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: _selectedCenter,
                                    initialZoom: 15.5,
                                    onPositionChanged: (pos, hasGesture) {
                                      if (hasGesture && _isEditMode) {
                                        _selectedCenter = pos.center;
                                      }
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName:
                                          'com.darbi.kids_transport',
                                    ),
                                  ],
                                ),
                              ),
                              // الدبوس الثابت في منتصف الخريطة
                              IgnorePointer(
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: 48,
                                  color: primaryColor,
                                ),
                              ),
                              // زر GPS — فقط في وضع التعديل
                              if (_isEditMode)
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  child: FloatingActionButton.small(
                                    heroTag: 'my_address_gps_btn',
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    onPressed: _isLocating ? null : _getUserLocation,
                                    child: _isLocating
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.my_location_rounded, size: 20),
                                  ),
                                ),
                              // شريط إرشادي عند وضع التعديل
                              if (_isEditMode)
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  right: 12,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit_location_alt_rounded, size: 18.r, color: Colors.white),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'حرّك الخريطة لتعديل الموقع',
                                          style: AppTextStyles.style(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ═══════════════════════════════════════════════
                          // 📋 وضع العرض: بطاقة بيانات العنوان الحالي
                          // ═══════════════════════════════════════════════
                          if (!_isEditMode) ...[
                            Container(
                              padding: EdgeInsets.all(18.r),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.home_rounded, color: primaryColor, size: 22.r),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'بيانات العنوان المعتمد',
                                        style: AppTextStyles.style(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.white : AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 14.h),

                                  // اسم العنوان
                                  _buildDetailRow(
                                    icon: Icons.label_outline_rounded,
                                    label: 'اسم العنوان',
                                    value: _currentAddress != null && _currentAddress!.title.isNotEmpty
                                        ? _currentAddress!.title
                                        : (_titleController.text.isNotEmpty ? _titleController.text : 'المنزل الرئيسي'),
                                    isDark: isDark,
                                    primaryColor: primaryColor,
                                  ),
                                  SizedBox(height: 12.h),

                                  // المنطقة
                                  _buildDetailRow(
                                    icon: Icons.location_city_rounded,
                                    label: 'المنطقة السكنية',
                                    value: _selectedZone?.name ??
                                        (_currentAddress?.zoneName != null && _currentAddress!.zoneName!.isNotEmpty
                                            ? _currentAddress!.zoneName!
                                            : 'طرابلس المركز'),
                                    isDark: isDark,
                                    primaryColor: primaryColor,
                                  ),
                                  SizedBox(height: 12.h),

                                  // الإحداثيات
                                  _buildDetailRow(
                                    icon: Icons.my_location_rounded,
                                    label: 'الإحداثيات',
                                    value:
                                        '${_selectedCenter.latitude.toStringAsFixed(6)}, ${_selectedCenter.longitude.toStringAsFixed(6)}',
                                    isDark: isDark,
                                    primaryColor: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ═══════════════════════════════════════════════
                          // ✏️ وضع التعديل
                          // ═══════════════════════════════════════════════
                          if (_isEditMode) ...[
                            // حقل المنطقة السكنية
                            GestureDetector(
                              onTap: _showZonePicker,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                                  borderRadius: BorderRadius.circular(30.r),
                                  border: Border.all(
                                    color: _selectedZone != null
                                        ? primaryColor
                                        : (isDark ? AppColors.grey800 : AppColors.grey200),
                                    width: _selectedZone != null ? 1.5 : 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_city_rounded,
                                      color: primaryColor,
                                      size: 22.r,
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "المنطقة السكنية *",
                                            style: AppTextStyles.style(
                                              fontSize: 11.sp,
                                              color: isDark
                                                  ? AppColors.grey400
                                                  : AppColors.grey600,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            _selectedZone?.name ??
                                                (_currentAddress?.zoneName != null &&
                                                        _currentAddress!.zoneName!.isNotEmpty
                                                    ? _currentAddress!.zoneName!
                                                    : "اضغط لاختيار منطقتك..."),
                                            style: AppTextStyles.style(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: AppColors.grey500,
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // حقل تسمية العنوان
                            TextFormField(
                              controller: _titleController,
                              textAlign: TextAlign.right,
                              decoration: AppTheme.inputDecoration(
                                context,
                                labelText: "تسمية العنوان (مثل: المنزل الرئيسي) *",
                                prefixIcon: const Icon(Icons.home_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),

                            // عرض الإحداثيات الحالية المختارة
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.grey900
                                    : AppColors.grey50,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.my_location_rounded, size: 16.r, color: AppColors.grey500),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'الإحداثيات: ${_selectedCenter.latitude.toStringAsFixed(6)}, ${_selectedCenter.longitude.toStringAsFixed(6)}',
                                    style: AppTextStyles.style(
                                      fontSize: 11.sp,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// صف عرض بيانات العنوان (أيقونة + ليبل + قيمة)
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.r, color: primaryColor.withValues(alpha: 0.7)),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.style(
                  fontSize: 11.sp,
                  color: isDark ? AppColors.grey400 : AppColors.grey500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppTextStyles.style(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
