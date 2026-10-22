import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/auth/registration/logic/register_state.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import 'package:kids_transport/features/parent/addresses/data/datasources/address_remote_data_source.dart';
import 'package:kids_transport/features/terms/presentation/screens/terms_and_conditions_screen.dart';
import 'package:latlong2/latlong.dart';

class DriverLocationScreen extends StatefulWidget {
  const DriverLocationScreen({super.key});

  @override
  State<DriverLocationScreen> createState() => _DriverLocationScreenState();
}

class _DriverLocationScreenState extends State<DriverLocationScreen> {
  final _labelController = TextEditingController(text: "موقع انطلاق الحافلة");
  final MapController _mapController = MapController();

  static const LatLng _tripoliCenter = LatLng(32.8872, 13.1913);
  LatLng _currentCenter = _tripoliCenter;

  List<ZoneModel> _zones = [];
  ZoneModel? _selectedZone;
  bool _isLoadingZones = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    // حفظ مرحلة التسجيل لضمان إجبارية الخطوة حتى لو خرج السائق من التطبيق
    StorageService.saveDriverRegStage('location');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
      _loadZones();
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// جلب قائمة المناطق من الخادم
  Future<void> _loadZones() async {
    setState(() => _isLoadingZones = true);
    try {
      final cubitToken = context.read<RegisterCubit>().driverAccessToken;
      final token = (cubitToken != null && cubitToken.isNotEmpty)
          ? cubitToken
          : (StorageService.getToken() ?? '');
      final zones =
          await AddressRemoteDataSource(ApiClient()).getZones(token: token);
      if (mounted) {
        setState(() {
          _zones = zones;
          _isLoadingZones = false;
        });
      }
    } catch (e) {
      debugPrint("خطأ أثناء جلب قائمة المناطق للسائق: $e");
      if (mounted) {
        setState(() => _isLoadingZones = false);
      }
    }
  }

  /// طلب الصلاحية وجلب الموقع الحالي الحقيقي عبر GPS
  Future<void> _determinePosition({bool isUserAction = false}) async {
    if (!mounted) return;
    setState(() => _isLocating = true);

    try {
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

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _currentCenter = _tripoliCenter);
            _mapController.move(_tripoliCenter, 14.5);
            if (isUserAction) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم رفض إذن الوصول للموقع، تم استخدام موقع افتراضي."),
                  backgroundColor: AppColors.orange,
                ),
              );
            }
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _currentCenter = _tripoliCenter);
          _mapController.move(_tripoliCenter, 14.5);
          if (isUserAction) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "تم رفض إذن الموقع بشكل دائم. يمكنك تحديده يدوياً من الخريطة.",
                ),
                backgroundColor: AppColors.orange,
              ),
            );
          }
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        final newCenter = LatLng(position.latitude, position.longitude);
        setState(() => _currentCenter = newCenter);
        _mapController.move(newCenter, 15.5);
      }
    } catch (e) {
      debugPrint("فشل جلب الموقع عبر GPS: $e");
      if (mounted) {
        setState(() => _currentCenter = _tripoliCenter);
        _mapController.move(_tripoliCenter, 14.5);
        if (isUserAction) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تعذر تحديد موقعك الحالي بدقة، تم تعيين موقع افتراضي."),
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
                    "اختر المنطقة السكنية لنقطة الانطلاق",
                    style: AppTextStyles.style(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    textAlign: TextAlign.right,
                    style: AppTextStyles.inputTextStyle(
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
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
                                          ? "لا توجد مناطق متاحة حالياً."
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
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
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

  void _submitLocation() {
    final labelText = _labelController.text.trim();
    if (labelText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء إدخال مسمى لنقطة الانطلاق (مثل: المنزل، الموقف الرئيسي)."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    if (_zones.isNotEmpty && _selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء اختيار المنطقة السكنية لنقطة الانطلاق."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    context.read<RegisterCubit>().saveDriverLocation(
          label: labelText,
          lat: _currentCenter.latitude,
          lng: _currentCenter.longitude,
          zoneId: _selectedZone?.id,
        );
  }

  void _navigateToNextStep() {
    StorageService.saveDriverRegStage('terms');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const TermsAndConditionsScreen(
          audience: 'driver',
          isRegistrationFlow: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false, // 🛑 منع الرجوع بالكامل لجعل الخطوة إجبارية
      child: Scaffold(
        appBar: AppBar(
          title: const Text("نقطة انطلاق السائق"),
          centerTitle: true,
          automaticallyImplyLeading: false, // 🛑 إخفاء زر الرجوع
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
                      horizontal: 20.0,
                      vertical: 6.0,
                    ),
                    child: Text(
                      "يرجى تحديد نقطة انطلاق الحافلة الأساسية (مثل موقع منزلك أو الجراج) والمنطقة لتسهيل حساب المسارات وقبول اشتراكات الطلاب.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  // الخريطة التفاعلية
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
                              userAgentPackageName:
                                  'com.example.kids_transport',
                              tileProvider: NetworkTileProvider(),
                            ),
                          ],
                        ),

                        // مؤشر الدبوس الثابت في منتصف الخريطة
                        IgnorePointer(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.directions_bus_filled_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "نقطة الانطلاق",
                                      style: AppTextStyles.style(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Icon(
                                Icons.location_on_rounded,
                                size: 44,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 38), // لضبط رأس الدبوس في المنتصف
                            ],
                          ),
                        ),

                        // زر جلب موقع الـ GPS الحالي
                        Positioned(
                          top: 16,
                          left: 16,
                          child: FloatingActionButton.small(
                            heroTag: "driver_locate_gps_btn",
                            onPressed: _isLocating
                                ? null
                                : () => _determinePosition(isUserAction: true),
                            backgroundColor: isDark
                                ? AppColors.grey900
                                : AppColors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 4,
                            child: _isLocating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // لوحة الإدخال السفلية
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.boxDecoration(
                      color: isDark ? AppColors.grey950 : AppColors.white,
                      borderRadius: AppTheme.onlyRadius(
                        topLeft: AppTheme.cornerRadius(24),
                        topRight: AppTheme.cornerRadius(24),
                      ),
                      boxShadow: [
                        AppTheme.boxShadow(
                          color: AppColors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // زر اختيار المنطقة السكنية
                        InkWell(
                          onTap: _isLoadingZones
                              ? null
                              : _showSearchableZonePicker,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.grey900
                                  : AppColors.grey50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedZone != null
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.grey800
                                        : AppColors.grey300),
                                width: _selectedZone != null ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_city_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "المنطقة التابعة لها *",
                                        style: AppTextStyles.style(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.grey400
                                              : AppColors.grey600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedZone?.name ??
                                            (_isLoadingZones
                                                ? "جاري تحميل المناطق..."
                                                : "اضغط لاختيار المنطقة السكنية"),
                                        style: AppTextStyles.style(
                                          fontSize: 14,
                                          fontWeight: _selectedZone != null
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _selectedZone != null
                                              ? (isDark
                                                  ? AppColors.white
                                                  : AppColors.textPrimary)
                                              : AppColors.grey500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isLoadingZones)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: AppColors.grey,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // حقل مسمى موقع الانطلاق
                        TextFormField(
                          controller: _labelController,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.inputTextStyle(
                            color: isDark
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                          decoration: AppTheme.inputDecoration(
                            context,
                            labelText: "مسمى نقطة الانطلاق (مثل: المنزل، الموقف الرئيسي) *",
                            prefixIcon: const Icon(Icons.pin_drop_outlined),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // زر حفظ وتأكيد الموقع
                        ElevatedButton(
                          onPressed: state is LocationSaveLoading
                              ? null
                              : _submitLocation,
                          style: AppTheme.elevatedButtonStyle(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
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
                                  "تأكيد وحفظ نقطة الانطلاق ومتابعة",
                                  style: AppTextStyles.style(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
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
