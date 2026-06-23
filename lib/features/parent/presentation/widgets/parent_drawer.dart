import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class ParentDrawer extends StatelessWidget {
  const ParentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ─── هيدر الدروار ───────────────────────────────────────────
          _DrawerHeader(isDark: isDark, theme: theme),

          // ─── قائمة العناصر ──────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.primaryLight,
                  label: "الملف الشخصي",
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.people_alt_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  label: "أطفالي",
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.success,
                  label: "إدارة العناوين المحفوظة",
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: التوجيه لصفحة العناوين
                  },
                ),
                _DrawerItem(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.pending,
                  label: "عقودي واشتراكاتي",
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.credit_card_rounded,
                  iconColor: const Color(0xFFEC4899),
                  label: "المحفظة والفواتير",
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(height: 24, indent: 16, endIndent: 16),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  iconColor: AppColors.textMuted,
                  label: "الإعدادات",
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.textMuted,
                  label: "ميزات داربي",
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.support_agent_rounded,
                  iconColor: AppColors.textMuted,
                  label: "التواصل مع الدعم",
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(height: 24, indent: 16, endIndent: 16),
                _DrawerItem(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  label: "تسجيل الخروج",
                  labelColor: AppColors.error,
                  onTap: () {
                    // TODO: منطق تسجيل الخروج
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // ─── Footer ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "داربي v1.0.0 - نسخة تجريبية",
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── هيدر الدروار المنفصل ────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;

  const _DrawerHeader({required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A2332), const Color(0xFF0F172A)]
              : [AppColors.primaryLight, const Color(0xFF0E78C4)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // أفاتار المستخدم
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 3),
                    ),
                    child: const CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person_rounded,
                          color: Colors.white, size: 36),
                    ),
                  ),
                  // زر تغيير الثيم
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isDark
                            ? Icons.wb_sunny_rounded
                            : Icons.brightness_3_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: تبديل الثيم
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "أسماء الفرجاني",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone_rounded,
                      color: Colors.white60, size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    "+218 92 318 1690",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const Spacer(),
                  // شارة ولي الأمر
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "👩‍👧 ولي أمر",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── عنصر قائمة الدروار المُعاد استخدامه ─────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}