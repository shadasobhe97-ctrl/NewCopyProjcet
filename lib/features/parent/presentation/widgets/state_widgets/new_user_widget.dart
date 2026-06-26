import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/routes/app_router.dart';

class NewUserWidget extends StatelessWidget {
  const NewUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // أيقونة ترحيبية مع تأثير
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight.withValues(alpha: 0.15),
                  AppColors.primaryLight.withValues(alpha: 0.5)                ],
              ),
              border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.2), width: 2),
            ),
            child: const Icon(
              Icons.child_care_rounded,
              size: 65,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "مرحباً بكِ في داربي 👋",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "ابدأي بإضافة طفلكِ الأول للاستفادة من خدمات النقل المدرسي الآمنة والموثوقة.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 32),

          // زر إضافة الطفل
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addChild);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              "إضافة طفلكِ الأول",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 36),

          // خطوات الاستخدام
          _buildStepsGuide(isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepsGuide(bool isDark) {
    const steps = [
      ("1", "أضيفي طفلكِ وبيانات مدرسته", Icons.child_care_rounded, Color(0xFF3B82F6)),
      ("2", "ابحثي عن سائق يغطي منطقتكِ", Icons.search_rounded, Color(0xFF8B5CF6)),
      ("3", "أرسلي طلب اشتراك مخصص للأبناء", Icons.send_rounded, AppColors.primaryLight),
      ("4", "أكملي التعاقد الإلكتروني الآمن", Icons.verified_rounded, AppColors.success),
      ("5", "تابعي رحلاتهم خطوة بخطوة", Icons.gps_fixed_rounded, AppColors.pending),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.help_outline_rounded,
                    color: AppColors.primaryLight, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                "كيف يعمل داربي؟",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: step.$4.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step.$1,
                        style: TextStyle(
                          color: step.$4,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.$2,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}