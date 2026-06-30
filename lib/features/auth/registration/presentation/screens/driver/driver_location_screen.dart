import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart'; // باقة OpenStreetMap
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/auth/registration/logic/register_state.dart';
import 'package:latlong2/latlong.dart';

class DriverLocationScreen extends StatefulWidget {
  const DriverLocationScreen({super.key});

  @override
  State<DriverLocationScreen> createState() => _DriverLocationScreenState();
}

class _DriverLocationScreenState extends State<DriverLocationScreen> {
  final _labelController = TextEditingController(text: "موقع انطلاق الحافلة");
  final MapController _mapController = MapController();

  // إحداثيات افتراضية لوسط طرابلس (ليبيا) كمثال للنسخة التجريبية
  LatLng _currentCenter = const LatLng(32.8872, 13.1913);
  bool _isDefaultLocation = true;

  @override
  void dispose() {
    _labelController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _submitLocation() {
    // استدعاء دالة حفظ الموقع من الكيوبت للسائق
    context.read<RegisterCubit>().saveLocation(
      label: _labelController.text.trim(),
      lat: _currentCenter.latitude,
      lng: _currentCenter.longitude,
      isDefault: _isDefaultLocation,
    );
  }

  // في ملف DriverLocationScreen.dart

  void _navigateToHome() {
    // نستخدم pushNamedAndRemoveUntil لمسح سجل الشاشات السابقة
    // وضمان عدم عودة السائق لشاشة التسجيل بالضغط على زر الرجوع
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes
          .driverMainWrapper, // هذا هو الروت الخاص بالداشبورد الرئيسي للسائق
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("تحديد موقع انطلاق السائق"),
        centerTitle: true,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          // زر تخطي خاص بالسائق يوجّه لشاشة الانتظار
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
              _navigateToHome(); // الانتقال لشاشة الانتظار بعد نجاح الحفظ
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
                    "يرجى تحديد نقطة انطلاق الحافلة الأساسية (مثل موقع منزلك أو الجراج) لتسهيل حساب المسارات للطلاب.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                // الخريطة (OpenStreetMap) تتبع السائق
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
                            tileProvider: NetworkTileProvider(),
                          ),
                        ],
                      ),
                      // علامة الدبوس في منتصف الشاشة للإشارة للموقع المختار
                      IgnorePointer(
                        child: Icon(
                          Icons.directions_bus,
                          size: 45,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // حقول البيانات والزر المخصص من الأسفل
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
                      // حقل تسمية موقع السائق
                      TextFormField(
                        controller: _labelController,
                        textAlign: TextAlign.right,
                        decoration: AppTheme.inputDecoration(context, 
                          labelText: "تسمية موقع الانطلاق",
                          prefixIcon: Icon(Icons.pin_drop_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // خيار الموقع الأساسي
                      CheckboxListTile(
                        title: Text(
                          "تعيين هذا الموقع كموقع انطلاق أساسي لحافلتي",
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

                      // زر حفظ الموقع
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
                                "حفظ وتأكيد موقع الحافلة",
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
