import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

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
        const Text(
          "الطلبات بانتظار المراجعة",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),

        // عنوان القسم
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.pending.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.pending_actions_rounded,
                  color: AppColors.pending, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "الإجراءات والطلبات المعلقة",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // كروت الطلبات
        ...requests.map((req) => _buildRequestCard(req, isDark)),
        const SizedBox(height: 24),

        // تنبيه
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.primaryLight, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "سيتم إخطارك فور استجابة السائق لطلبكِ",
                  style: TextStyle(
                      fontSize: 13, color: AppColors.primaryLight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.pending.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.pending.withOpacity(0.06),
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
            decoration: BoxDecoration(
              color: AppColors.pending.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  req['type'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pending.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    req['status'] ?? '',
                    style: const TextStyle(
                      color: AppColors.pending,
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
                _reqRow(Icons.child_care_rounded, "الأطفال",
                    req['children'] ?? '', AppColors.primaryLight),
                const SizedBox(height: 10),
                _reqRow(Icons.person_outline_rounded, "السائق",
                    req['driver_name'] ?? '', const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reqRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}