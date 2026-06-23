import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/features/parent/data/models/child_model.dart';
import 'add_child_screen.dart';

class ChildDetailScreen extends StatelessWidget {
  final ChildModel child;
  const ChildDetailScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMale = child.gender == 'MALE';
    final isPresent = child.dailyStatus == DailyStatus.present;
    final avatarColor = isMale ? const Color(0xFF3B82F6) : const Color(0xFFEC4899);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F0F0F) : AppColors.backgroundLight,
        body: CustomScrollView(
          slivers: [
            // ─── هيدر الطفل ───────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primaryLight,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  tooltip: "تعديل البيانات",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddChildScreen(childToEdit: child),
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryLight, Color(0xFF0E78C4)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // أفاتار الطفل
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: child.photoUrl != null
                                ? NetworkImage(child.photoUrl!)
                                : null,
                            child: child.photoUrl == null
                                ? Icon(
                                    isMale
                                        ? Icons.boy_rounded
                                        : Icons.girl_rounded,
                                    color: Colors.white,
                                    size: 48,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          child.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // بيدج حالة الحضور
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: (isPresent
                                    ? AppColors.success
                                    : AppColors.error)
                                .withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPresent
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPresent
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                size: 14,
                                color: isPresent
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isPresent ? "حاضر اليوم" : "غائب اليوم",
                                style: TextStyle(
                                  color: isPresent
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── تفاصيل الطفل ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── بطاقة المعلومات الأساسية ─────────────────────
                  _InfoCard(
                    title: "المعلومات الأساسية",
                    icon: Icons.info_outline_rounded,
                    children: [
                      _InfoRow(
                          icon: Icons.person_outline_rounded,
                          label: "الاسم الكامل",
                          value: child.fullName),
                      _InfoRow(
                          icon: Icons.wc_rounded,
                          label: "الجنس",
                          value: isMale ? "ذكر 👦" : "أنثى 👧"),
                      _InfoRow(
                          icon: Icons.cake_rounded,
                          label: "تاريخ الميلاد",
                          value:
                              "${child.birthDate.year}/${child.birthDate.month}/${child.birthDate.day}"),
                      _InfoRow(
                          icon: Icons.school_outlined,
                          label: "المدرسة",
                          value: child.schoolName),
                      _InfoRow(
                          icon: Icons.home_outlined,
                          label: "عنوان الركوب",
                          value: child.homeAddressTitle),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── بطاقة جدول التوصيل ────────────────────────────
                  _InfoCard(
                    title: "جدول التوصيل",
                    icon: Icons.schedule_rounded,
                    children: [
                      _InfoRow(
                        icon: Icons.wb_sunny_outlined,
                        label: "الفترة المفضلة",
                        value: _slotLabel(child.preferredTimeSlot),
                      ),
                      if (child.departureTime != null)
                        _InfoRow(
                          icon: Icons.arrow_forward_rounded,
                          label: "وقت الذهاب",
                          value: child.departureTime!,
                        ),
                      if (child.returnTime != null)
                        _InfoRow(
                          icon: Icons.arrow_back_rounded,
                          label: "وقت الرجوع",
                          value: child.returnTime!,
                        ),
                      _InfoRow(
                        icon: Icons.notifications_active_outlined,
                        label: "نصف قطر الإشعار",
                        value: "${child.notificationRadius} متر",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── بطاقة الملاحظات الصحية ────────────────────────
                  if (child.medicalNotes != null &&
                      child.medicalNotes!.isNotEmpty)
                    _InfoCard(
                      title: "الملاحظات الصحية",
                      icon: Icons.medical_information_outlined,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          child: Text(
                            child.medicalNotes!,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                                height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // ── رمز QR ────────────────────────────────────────
                  if (child.qrCodeToken != null)
                    _InfoCard(
                      title: "رمز QR للدخول",
                      icon: Icons.qr_code_rounded,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  color: avatarColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: avatarColor.withOpacity(0.2)),
                                ),
                                child: Icon(Icons.qr_code_2_rounded,
                                    size: 90, color: avatarColor),
                              ),
                              Text(
                                child.qrCodeToken!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "يُستخدم لتسجيل الدخول والخروج في الحافلة",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _slotLabel(PreferredTimeSlot slot) {
    switch (slot) {
      case PreferredTimeSlot.MORNING:
        return "صباحي فقط ☀️";
      case PreferredTimeSlot.EVENING:
        return "مسائي فقط 🌙";
      case PreferredTimeSlot.BOTH:
        return "الفترتين (ذهاب وإياب) 🔄";
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// مكونات مساعدة
// ─────────────────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان البطاقة
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon,
                      color: AppColors.primaryLight, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.06)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
