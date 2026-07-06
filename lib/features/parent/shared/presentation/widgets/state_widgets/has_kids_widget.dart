import 'package:flutter/material.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class HasKidsWidget extends StatelessWidget {
  final List<ChildModel> kids;
  const HasKidsWidget({super.key, required this.kids});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // عنوان قسم الأطفال المسجلين
        Text(
          "أطفالي المسجلين",
          style: AppTextStyles.style(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),

        // كروت الأطفال
        ...kids.map((child) => _buildChildCard(context, child, isDark)),
        const SizedBox(height: 20),

        // بلوك البحث عن سائق
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.boxDecoration(
            gradient: AppTheme.linearGradient(
              colors: [
                context.primaryColor.withValues(alpha: 0.08),
                context.primaryColor.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: AppTheme.radius(20),
            border: AppTheme.border(
              color: context.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.boxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_rounded,
                  size: 36,
                  color: context.primaryColor,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "لا يوجد اشتراك نشط حالياً",
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "ابحثي الآن عن سائق مناسب ومتوفر في منطقتكِ لتأمين مقاعد أطفالكِ.",
                textAlign: TextAlign.center,
                style: AppTextStyles.style(
                  color: context.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: التحويل لتبويب البحث
                },
                icon: const Icon(Icons.search_rounded),
                label: Text(
                  "البحث عن سائق مناسب",
                  style: AppTextStyles.style(fontWeight: FontWeight.bold),
                ),
                style: AppTheme.elevatedButtonStyle(
                  backgroundColor: context.primaryColor,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: AppTheme.roundedRectangleBorder(
                    borderRadius: AppTheme.radius(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildChildCard(BuildContext context, ChildModel child, bool isDark) {
    final isMale = child.gender.toLowerCase() == 'male';
    final avatarColor = isMale
        ? context.genderMaleColor
        : context.genderFemaleColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor.withValues(alpha: 0.1),
            child: Icon(
              isMale ? Icons.boy_rounded : Icons.girl_rounded,
              color: avatarColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: AppTextStyles.style(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  child.schoolName,
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: context.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: AppTheme.boxDecoration(
              color: context.pendingColor.withValues(alpha: 0.1),
              borderRadius: AppTheme.radius(10),
            ),
            child: Text(
              "بدون اشتراك",
              style: AppTextStyles.style(
                color: context.pendingColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
