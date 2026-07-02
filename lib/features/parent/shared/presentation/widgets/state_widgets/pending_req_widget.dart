import 'package:flutter/material.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class PendingReqWidget extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  const PendingReqWidget({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // عنوان قسم الطلبات المعلقة
        Text(
          "الطلبات بانتظار المراجعة",
          style: AppTextStyles.style(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),

        // عنوان القسم
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: AppTheme.boxDecoration(
                color: context.pendingColor.withValues(alpha: 0.12),
                borderRadius: AppTheme.radius(9),
              ),
              child: Icon(
                Icons.pending_actions_rounded,
                color: context.pendingColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "الإجراءات والطلبات المعلقة",
              style: AppTextStyles.style(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // كروت الطلبات
        ...requests.map((req) => _buildRequestCard(context, req, isDark)),
        const SizedBox(height: 24),

        // تنبيه
        Container(
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.boxDecoration(
            color: context.primaryColor.withValues(alpha: 0.06),
            borderRadius: AppTheme.radius(14),
            border: AppTheme.border(
              color: context.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: context.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "سيتم إخطارك فور استجابة السائق لطلبكِ",
                  style: AppTextStyles.style(fontSize: 13, color: context.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    Map<String, dynamic> req,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(18),
        border: AppTheme.border(color: context.pendingColor.withValues(alpha: 0.3)),
        boxShadow: [
          AppTheme.boxShadow(
            color: context.pendingColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // رأس الكرت
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: AppTheme.boxDecoration(
              color: context.pendingColor.withValues(alpha: 0.06),
              borderRadius: AppTheme.verticalRadius(
                top: AppTheme.cornerRadius(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  req['type'] ?? '',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: AppTheme.boxDecoration(
                    color: context.pendingColor.withValues(alpha: 0.15),
                    borderRadius: AppTheme.radius(20),
                  ),
                  child: Text(
                    req['status'] ?? '',
                    style: AppTextStyles.style(
                      color: context.pendingColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // محتوى الكرت
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _reqRow(
                  context,
                  Icons.child_care_rounded,
                  "الأطفال",
                  req['children'] ?? '',
                  context.primaryColor,
                ),
                const SizedBox(height: 10),
                _reqRow(
                  context,
                  Icons.person_outline_rounded,
                  "السائق",
                  req['driver_name'] ?? '',
                  context.accentPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reqRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: AppTextStyles.style(
            color: context.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.style(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
