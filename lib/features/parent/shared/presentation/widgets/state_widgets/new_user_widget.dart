import 'package:flutter/material.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class NewUserWidget extends StatelessWidget {
  const NewUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
            decoration: AppTheme.boxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.linearGradient(
                colors: [
                  context.primaryColor.withValues(alpha: 0.15),
                  context.primaryColor.withValues(alpha: 0.5),
                ],
              ),
              border: AppTheme.border(
                color: context.primaryColor.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.child_care_rounded,
              size: 65,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "مرحباً بكِ في داربي 👋",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "ابدأي بإضافة طفلكِ الأول للاستفادة من خدمات النقل المدرسي الآمنة والموثوقة.",
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              color: context.textMuted,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),

          // زر إضافة الطفل
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addChild);
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(
              "إضافة طفلكِ الأول",
              style: AppTextStyles.style(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: AppTheme.elevatedButtonStyle(
              backgroundColor: context.primaryColor,
              foregroundColor: AppColors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: AppTheme.roundedRectangleBorder(
                borderRadius: AppTheme.radius(16),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // خطوات الاستخدام
          _buildStepsGuide(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepsGuide(BuildContext context) {
    final steps = [
      (
        "1",
        "أضيفي طفلكِ وبيانات مدرسته",
        Icons.child_care_rounded,
        context.genderMaleColor,
      ),
      (
        "2",
        "ابحثي عن سائق يغطي منطقتكِ",
        Icons.search_rounded,
        context.accentPurple,
      ),
      (
        "3",
        "أرسلي طلب اشتراك مخصص للأبناء",
        Icons.send_rounded,
        context.primaryColor,
      ),
      (
        "4",
        "أكملي التعاقد الإلكتروني الآمن",
        Icons.verified_rounded,
        context.successColor,
      ),
      (
        "5",
        "تابعي رحلاتهم خطوة بخطوة",
        Icons.gps_fixed_rounded,
        context.pendingColor,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.boxDecoration(
        color: context.cardSurface,
        borderRadius: AppTheme.radius(20),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(
              alpha: context.isDarkMode ? 0.2 : 0.05,
            ),
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
                decoration: AppTheme.boxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: AppTheme.radius(9),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: context.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "كيف يعمل داربي؟",
                style: AppTextStyles.style(fontSize: 15, fontWeight: FontWeight.bold),
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
                    decoration: AppTheme.boxDecoration(
                      color: step.$4.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step.$1,
                        style: AppTextStyles.style(
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
                      style: AppTextStyles.style(fontSize: 14, height: 1.4),
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
