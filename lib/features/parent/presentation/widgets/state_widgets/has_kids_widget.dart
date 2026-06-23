import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/features/parent/data/models/child_model.dart';

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
        // تحية وعدد الأطفال
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "أهلاً 👋",
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "لديكِ ${kids.length} ${kids.length == 1 ? 'طفل مسجل' : 'أطفال مسجلون'} في التطبيق",
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // كروت الأطفال
        ...kids.map((child) => _buildChildCard(child, isDark)),
        const SizedBox(height: 20),

        // بلوك البحث عن سائق
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.08),
                AppColors.primaryLight.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.primaryLight.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 36,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "لا يوجد اشتراك نشط حالياً",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                "ابحثي الآن عن سائق مناسب ومتوفر في منطقتكِ لتأمين مقاعد أطفالكِ.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: التحويل لتبويب البحث
                },
                icon: const Icon(Icons.search_rounded),
                label: const Text("البحث عن سائق مناسب",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildChildCard(ChildModel child, bool isDark) {
    final isMale = child.gender == 'MALE';
    final avatarColor =
        isMale ? const Color(0xFF3B82F6) : const Color(0xFFEC4899);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor.withOpacity(0.1),
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
                  child.fullName,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  child.schoolName,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.pending.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "بدون اشتراك",
              style: TextStyle(
                color: AppColors.pending,
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