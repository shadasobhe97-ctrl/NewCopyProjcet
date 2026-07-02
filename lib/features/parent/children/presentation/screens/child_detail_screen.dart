import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/custom_card.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/child_detail_header.dart';
import 'package:kids_transport/features/parent/shared/presentation/widgets/info_card.dart';

class ChildDetailScreen extends StatelessWidget {
  final ChildModel child;
  const ChildDetailScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMale = child.gender == 'MALE';
    final avatarColor = isMale ? AppColors.maleBlue : AppColors.femalePink;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // ─── هيدر قابل للتمدد ────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primaryLight,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.white),
                  tooltip: 'تعديل البيانات',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddChildScreen(childToEdit: child),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: ChildDetailHeader(child: child),
              ),
            ),

            // ─── تفاصيل الطفل ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  InfoCard(
                    title: 'المعلومات الأساسية',
                    icon: Icons.info_outline_rounded,
                    children: [
                      InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'الاسم الكامل',
                        value: child.fullName,
                      ),
                      InfoRow(
                        icon: Icons.wc_rounded,
                        label: 'الجنس',
                        value: isMale ? 'ذكر 👦' : 'أنثى 👧',
                      ),
                      InfoRow(
                        icon: Icons.cake_rounded,
                        label: 'تاريخ الميلاد',
                        value:
                            '${child.birthDate.year}/${child.birthDate.month}/${child.birthDate.day}',
                      ),
                      InfoRow(
                        icon: Icons.school_outlined,
                        label: 'المدرسة',
                        value: child.schoolName,
                      ),
                      InfoRow(
                        icon: Icons.home_outlined,
                        label: 'عنوان الركوب',
                        value: child.homeAddressTitle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  InfoCard(
                    title: 'جدول التوصيل',
                    icon: Icons.schedule_rounded,
                    children: [
                      InfoRow(
                        icon: Icons.wb_sunny_outlined,
                        label: 'الفترة المفضلة',
                        value: _slotLabel(child.preferredTimeSlot),
                      ),
                      if (child.departureTime != null)
                        InfoRow(
                          icon: Icons.arrow_forward_rounded,
                          label: 'وقت الذهاب',
                          value: child.departureTime!,
                        ),
                      if (child.returnTime != null)
                        InfoRow(
                          icon: Icons.arrow_back_rounded,
                          label: 'وقت الرجوع',
                          value: child.returnTime!,
                        ),
                      InfoRow(
                        icon: Icons.notifications_active_outlined,
                        label: 'نصف قطر الإشعار',
                        value: '${child.notificationRadius} متر',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (child.medicalNotes?.isNotEmpty == true)
                    InfoCard(
                      title: 'الملاحظات الصحية',
                      icon: Icons.medical_information_outlined,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Text(
                            child.medicalNotes!,
                            style: AppTextStyles.style(
                              fontSize: 14,
                              color: AppColors.textMuted,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  if (child.qrCodeToken != null)
                    InfoCard(
                      title: 'رمز QR للدخول',
                      icon: Icons.qr_code_rounded,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                margin: const EdgeInsets.symmetric(vertical: 12),
                                decoration: AppTheme.boxDecoration(
                                  color: avatarColor.withValues(alpha: 0.05),
                                  borderRadius: AppTheme.radius(16),
                                  border: AppTheme.border(
                                    color: avatarColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 90,
                                  color: avatarColor,
                                ),
                              ),
                              Text(
                                child.qrCodeToken!,
                                style: AppTextStyles.style(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'يُستخدم لتسجيل الدخول والخروج في الحافلة',
                                style: AppTextStyles.style(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
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
        return 'صباحي فقط ☀️';
      case PreferredTimeSlot.EVENING:
        return 'مسائي فقط 🌙';
      case PreferredTimeSlot.BOTH:
        return 'الفترتين (ذهاب وإياب) 🔄';
    }
  }
}
