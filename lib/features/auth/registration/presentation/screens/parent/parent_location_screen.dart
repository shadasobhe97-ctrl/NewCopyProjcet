import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart'; // باقة OpenStreetMap
import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import 'package:kids_transport/features/parent/addresses/data/datasources/address_remote_data_source.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/auth/registration/logic/register_state.dart';
import 'package:latlong2/latlong.dart';

import 'package:kids_transport/core/services/storage_service.dart';

class ParentLocationScreen extends StatefulWidget {
  const ParentLocationScreen({super.key});

  @override
  State<ParentLocationScreen> createState() => _ParentLocationScreenState();
}

class _ParentLocationScreenState extends State<ParentLocationScreen> {
  final _labelController = TextEditingController(text: "المنزل الرئيسي");
  final MapController _mapController = MapController();

  // إحداثيات افتراضية لوسط طرابلس (ليبيا) كـ Fallback مؤقت
  static const LatLng _tripoliCenter = LatLng(32.8872, 13.1913);
  LatLng _currentCenter = _tripoliCenter;

  List<ZoneModel> _zones = [];
  ZoneModel? _selectedZone;
  bool _isLoadingZones = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    StorageService.saveParentRegStage('location');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
      _loadZones();
    });
  }

  /// جلب قائمة المناطق من السيرفر (GET /api/admin/zones)
  Future<void> _loadZones() async {
    setState(() => _isLoadingZones = true);
    try {
      final cubitToken = context.read<RegisterCubit>().parentAccessToken;
      final token = (cubitToken != null && cubitToken.isNotEmpty)
          ? cubitToken
          : (StorageService.getToken() ?? '');
      final zones = await AddressRemoteDataSource(ApiClient()).getZones(token: token);
      if (mounted) {
        setState(() {
          _zones = zones;
          _isLoadingZones = false;
        });
      }
    } catch (e) {
      debugPrint("خطأ أثناء جلب قائمة المناطق من الخادم: $e");
      if (mounted) {
        setState(() => _isLoadingZones = false);
      }
    }
  }

  /// طلب الصلاحية وجلب الموقع الحالي الحقيقي للمستخدم عبر GPS
  Future<void> _determinePosition({bool isUserAction = false}) async {
    if (!mounted) return;
    setState(() => _isLocating = true);

    try {
      // 1. التحقق من تفعيل خدمة الموقع (GPS)
      bool serviceEnabled = true;
      try {
        if (!kIsWeb) {
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }
      } catch (e) {
        debugPrint("تحقق خدمة الموقع: $e");
      }

      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _currentCenter = _tripoliCenter);
          _mapController.move(_tripoliCenter, 14.5);
          if (isUserAction) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "خدمة تحديد الموقع (GPS) مغلقة، يرجى تفعيلها من إعدادات الجهاز.",
                ),
                backgroundColor: AppColors.orange,
              ),
            );
          }
        }
        return;
      }

      // 2. التحقق وطلب صلاحية الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint("⚠️ إذن الموقع مرفوض من المستخدم (أو مرفوض دائمًا). عرض موقع طرابلس الافتراضي.");
        if (mounted) {
          setState(() => _currentCenter = _tripoliCenter);
          _mapController.move(_tripoliCenter, 14.5);
          if (isUserAction) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "لم يتم منح إذن الوصول إلى الموقع. تم إظهار طرابلس افتراضياً، ويمكنك تحديد مكان المنزلك يدوياً.",
                ),
                backgroundColor: AppColors.orange,
              ),
            );
          }
        }
        return;
      }

      // 3. جلب الموقع الحقيقي الحالي للمستخدم عند الموافقة (سماح)
      debugPrint("📡 تم منح الإذن! جاري طلب موقع المستخدم الحقيقي...");
      Position? position;
      if (!kIsWeb) {
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (_) {}
      }
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: kIsWeb ? LocationAccuracy.low : LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      debugPrint("📍 [GPS] تم استلام الإحداثيات: Lat=${position.latitude}, Lng=${position.longitude}");

      if (position.latitude != 0.0 || position.longitude != 0.0) {
        final userLatLng = LatLng(position.latitude, position.longitude);

        if (mounted) {
          setState(() {
            _currentCenter = userLatLng;
          });
          _mapController.move(userLatLng, 16.0);
        }
      } else {
        if (mounted) {
          setState(() => _currentCenter = _tripoliCenter);
          _mapController.move(_tripoliCenter, 14.5);
        }
      }
    } catch (e) {
      debugPrint("خطأ أثناء جلب الموقع الحالي: $e");
      if (mounted) {
        setState(() => _currentCenter = _tripoliCenter);
        _mapController.move(_tripoliCenter, 14.5);
        if (isUserAction) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تعذر تحديد موقعك الحالي بدقة، يرجى المحاولة مرة أخرى أو تحريك الخريطة يدوياً."),
              backgroundColor: AppColors.orange,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showSearchableZonePicker() {
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isLoadingZones
                                      ? "جاري تحميل المناطق من الخادم..."
                                      : (_zones.isEmpty
                                          ? "لا توجد مناطق متاحة من الخادم حالياً."
                                          : "لا توجد مناطق تطابق البحث."),
                                  style: AppTextStyles.style(color: AppColors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                if (!_isLoadingZones && _zones.isEmpty) ...[
                                  const SizedBox(height: 12),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _loadZones();
                                    },
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text("إعادة المحاولة"),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredZones.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final zone = filteredZones[index];
                              final isSelected = _selectedZone?.id == zone.id;
                              return ListTile(
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
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedZone = zone;
                                  });
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

  @override
  void dispose() {
    _labelController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _submitLocation() {
    final labelText = _labelController.text.trim();
    if (labelText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء إدخال تسمية للموقع أولاً (مثال: المنزل الرئيسي)."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    if (_zones.isNotEmpty && _selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء اختيار المنطقة السكنية أولاً."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    context.read<RegisterCubit>().saveLocation(
      label: labelText,
      lat: _currentCenter.latitude,
      lng: _currentCenter.longitude,
      zoneId: _selectedZone?.id,
    );
  }

  void _navigateToNextStep() {
    StorageService.saveParentRegStage('add_child');
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/parentAddFirstChild',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false, // 🛑 إجبار عدم إمكانية العودة للخلف قبل إضافة العنوان
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تحديد موقع المنزل"),
          centerTitle: true,
          automaticallyImplyLeading: false, // 🛑 إخفاء زر العودة في الـ AppBar
          backgroundColor: AppColors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) {
              if (state is LocationSaveSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.green,
                  ),
                );
                _navigateToNextStep();
              } else if (state is LocationSaveError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      "يرجى تحديد موقع منزلك الرئيسي واختيار المنطقة السكنية لإتمام إنشاء الحساب.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  // 🌟 الخريطة التفاعلية (OpenStreetMap عبر flutter_map)
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
                              userAgentPackageName: 'com.darbi.kids_transport',
                              tileProvider: NetworkTileProvider(),
                            ),
                          ],
                        ),

                        // 📍 مؤشر موقع المنزل الثابت في منتصف الشاشة
                        IgnorePointer(
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 45,
                            color: theme.primaryColor,
                          ),
                        ),

                        // 📍 زر تحديد موقعي الحالي لإعادة الخريطة لموقع المستخدم بنقرة واحدة
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: FloatingActionButton.small(
                            heroTag: 'locate_my_home_btn',
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            tooltip: 'تحديد موقعي الحالي',
                            onPressed: () => _determinePosition(isUserAction: true),
                            child: _isLocating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // حقول البيانات واختيار المنطقة من أسفل
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.boxDecoration(
                      color: isDark ? AppColors.grey950 : AppColors.white,
                      borderRadius: AppTheme.onlyRadius(
                        topLeft: AppTheme.cornerRadius(24),
                        topRight: AppTheme.cornerRadius(24),
                      ),
                      boxShadow: [
                        AppTheme.boxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // اختيار المنطقة المجلوبة من السيرفر (مع إمكانية البحث)
                        InkWell(
                          onTap: _isLoadingZones ? null : _showSearchableZonePicker,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.grey900 : AppColors.grey50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedZone != null 
                                    ? AppColors.primary 
                                    : (isDark ? AppColors.grey800 : AppColors.grey300),
                                width: _selectedZone != null ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_city_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "المنطقة السكنية *",
                                        style: AppTextStyles.style(
                                          fontSize: 12,
                                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isLoadingZones
                                            ? "جاري تحميل المناطق..."
                                            : (_selectedZone?.name ?? "اضغط لاختيار المنطقة بالبحث..."),
                                        style: AppTextStyles.style(
                                          fontSize: 14,
                                          fontWeight: _selectedZone != null ? FontWeight.bold : FontWeight.normal,
                                          color: _selectedZone != null
                                              ? (isDark ? AppColors.white : AppColors.grey900)
                                              : (isDark ? AppColors.grey500 : AppColors.grey400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isLoadingZones)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
                                  const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: AppColors.grey500,
                                    size: 28,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // حقل تسمية الموقع
                        TextFormField(
                          controller: _labelController,
                          textAlign: TextAlign.right,
                          decoration: AppTheme.inputDecoration(
                            context,
                            labelText: "تسمية الموقع (مثال: المنزل الرئيسي)",
                            prefixIcon: const Icon(Icons.label_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // زر حفظ الموقع والتأكيد الإجباري
                        ElevatedButton(
                          onPressed: state is LocationSaveLoading
                              ? null
                              : _submitLocation,
                          style: AppTheme.elevatedButtonStyle(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: state is LocationSaveLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : Text(
                                  "حفظ وتأكيد الموقع",
                                  style: AppTextStyles.style(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
