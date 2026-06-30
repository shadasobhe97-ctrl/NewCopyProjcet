import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart'; // باقة OpenStreetMap
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/auth/registration/logic/register_state.dart';
import 'package:latlong2/latlong.dart';
// استيراد ملف الـ Routes لضمان الوصول لـ Routes.parentMainWrapper

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
  void dispose() {
    _labelController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _submitLocation() {
    context.read<RegisterCubit>().saveLocation(
      label: _labelController.text.trim(),
      lat: _currentCenter.latitude,
      lng: _currentCenter.longitude,
      isDefault: _isDefaultLocation,
    );
  }

  void _navigateToHome() {
    // 🌟 تعديل: التوجيه النهائي للداشبورد الرئيسي ومسح فلو الـ Register بالكامل دون مشاكل
    Navigator.pushNamedAndRemoveUntil(context, '/parentMainWrapper', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("تحديد موقع المنزل"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // زر تخطي من فوق لأن الإدخال اختياري
          TextButton(
            onPressed: _navigateToHome,
            child: Text(
              "تخطي",
              style: TextStyle(
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
                  backgroundColor: Colors.green,
                ),
              );
              // 🌟 تعديل: الانتقال مباشرة للداشبورد الرئيسي بعد نجاح الحفظ
              _navigateToHome();
            } else if (state is LocationSaveError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
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
                      color: Colors.grey,
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
                            if (hasGesture && position.center != null) {
                              // تحديث الإحداثيات عند سحب الخريطة من المستخدم
                              _currentCenter = position.center!;
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
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[950] : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                        decoration: const InputDecoration(
                          labelText: "تسمية الموقع (مثال: منزلي، بيت الجدة)",
                          prefixIcon: Icon(Icons.label_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // خيار الموقع الأساسي
                      CheckboxListTile(
                        title: const Text(
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
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: state is LocationSaveLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "حفظ وتأكيد الموقع",
                                style: TextStyle(
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