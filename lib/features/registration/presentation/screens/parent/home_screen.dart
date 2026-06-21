import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/registration/logic/register_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<RegisterCubit>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // أيقونة النجاح الكبيرة والتفاعلية
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 100,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // عنوان الترحيب
              Text(
                "أهلاً بك في دربي! 👋",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "تم إنشاء حسابك وتحديد موقعك بنجاح. التطبيق جاهز الآن للاستخدام والربط الكامل مع اللوحة الخلفية.",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // بطاقة البيانات المسجلة للمراجعة والتأكد
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ملخص البيانات المسجلة محلياً:",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow("الاسم الكامل:", cubit.fullName ?? "غير متوفر"),
                      _buildInfoRow("البريد الإلكتروني:", cubit.email ?? "غير متوفر"),
                      _buildInfoRow("رقم الهاتف الأساسي:", cubit.phoneNumber ?? "غير متوفر"),
                      _buildInfoRow("الهاتف البديل:", cubit.alternativePhone ?? "لم يُدخل (تم التخطي)"),
                      _buildInfoRow("صورة الملف الشخصي:", cubit.avatarFile != null ? "تم الرفع 📸" : "لم تُرفع (تم التخطي)"),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),

              // زر إعادة تجربة التسجيل من الصفر
              OutlinedButton.icon(
                onPressed: () async {
                  // مسح الجلسة وإعادة تعيين البيانات الأساسية
                  await StorageService.clearSession();
                  // مسح الأونبوردينق عشان نقدروا نشوفوها ثاني لو نبي
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('is_first_time');
                  
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("إعادة تجربة الفلو بالكامل"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
// إضافة استيراد لـ SharedPreferences
