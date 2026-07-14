import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart'; // باقة OpenStreetMap
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/auth/registration/logic/register_state.dart';
import 'package:latlong2/latlong.dart';

class ParentLocationScreen extends StatefulWidget {
  const ParentLocationScreen({super.key});

  @override
  State<ParentLocationScreen> createState() => _ParentLocationScreenState();
}

class _ParentLocationScreenState extends State<ParentLocationScreen> {
  final _labelController = TextEditingController(text: "منزلي");
  final MapController _mapController = MapController();

  // إحداثيات افتراضية لوسط طرابلس (ليبيا) كمثال للنسخة التجريبية
  LatLng _currentCenter = const LatLng(32.8872, 13.1913);
  bool _isDefaultLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
    });
  }

  Future<void> _determinePosition() async {
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      if (mounted) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentCenter, 14.5);
      }
    } catch (e) {
      debugPrint("خطأ أثناء جلب الموقع الحالي: $e");
    }
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
          content: Text("الرجاء إدخال تسمية للموقع أولاً (مثال: منزلي)."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }
    context.read<RegisterCubit>().saveLocation(
      label: labelText,
      lat: _currentCenter.latitude,
      lng: _currentCenter.longitude,
      isDefault: _isDefaultLocation,
    );
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/parentMainWrapper',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("تحديد موقع المنزل"),
        centerTitle: true,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          // زر تخطي من فوق لأن الإدخال اختياري
          TextButton(
            onPressed: _navigateToHome,
            child: Text(
              "تخطي",
              style: AppTextStyles.style(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
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
              // 🌟 تعديل: الانتقال مباشرة للداشبورد الرئيسي بعد نجاح الحفظ
              _navigateToHome();
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
                    "يرجى تحديد موقع المنزل الأساسي على الخريطة لتسهيل عملية التوصيل والربط مع الحافلة.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                // 🌟 الخريطة الحقيقية (OpenStreetMap)
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
                              // تحديث الإحداثيات عند سحب الخريطة من المستخدم
                              _currentCenter = position.center;
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            // استخدم هذا الاسم بالضبط كما هو في ملف الـ build.gradle
                            userAgentPackageName: 'com.example.kids_transport',
                            tileProvider: NetworkTileProvider(),
                          ),
                        ],
                      ),
                      // علامة الدبوس الثابتة في منتصف الشاشة للإشارة للموقع المختار
                      IgnorePointer(
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 45,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // حقول البيانات والزر المخصص من لوطة
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
                      // حقل تسمية الموقع
                      TextFormField(
                        controller: _labelController,
                        textAlign: TextAlign.right,
                        decoration: AppTheme.inputDecoration(context, 
                          labelText: "تسمية الموقع (مثال: منزلي، بيت الجدة)",
                          prefixIcon: Icon(Icons.label_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // خيار الموقع الأساسي
                      CheckboxListTile(
                        title: Text(
                          "تعيين هذا الموقع كموقع منزلي الأساسي",
                        ),
                        value: _isDefaultLocation,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: theme.primaryColor,
                        onChanged: (val) {
                          setState(() {
                            _isDefaultLocation = val ?? true;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // زر حفظ الموقع والارسال للباكيند
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
    );
  }
}
