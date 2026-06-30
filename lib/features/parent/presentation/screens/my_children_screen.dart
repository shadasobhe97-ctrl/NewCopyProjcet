import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/features/parent/data/models/child_model.dart';
import 'package:kids_transport/features/parent/logic/child_cubit/child_cubit.dart';
import 'package:kids_transport/features/parent/logic/child_cubit/child_state.dart';
import 'add_child_screen.dart';
import 'child_detail_screen.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

class MyChildrenScreen extends StatelessWidget {
  const MyChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildCubit, ChildState>(
      builder: (context, state) {
        if (state is ChildLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryLight),
          );
        }
        if (state is ChildLoaded) {
          final children = state.children;
          return _ChildrenContent(children: children);
        }
        if (state is ChildError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: AppTextStyles.style(color: AppColors.error),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<ChildCubit>().loadChildren(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text("إعادة المحاولة"),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _ChildrenContent extends StatelessWidget {
  final List<ChildModel> children;
  const _ChildrenContent({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: children.isEmpty
          ? _buildEmptyState(context)
          : _buildList(context, isDark),
      // زر إضافة طفل عائم
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddChild(context),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          "إضافة طفل",
          style: AppTextStyles.style(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildList(BuildContext context, bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "أطفالي المسجلون 👨‍👧‍👦",
                        style: AppTextStyles.style(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.darkCard,
                        ),
                      ),
                      Text(
                        "${children.length} ${children.length == 1 ? 'طفل مسجل' : 'أطفال مسجلون'}",
                        style: AppTextStyles.style(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _ChildCard(child: children[index], index: index),
              childCount: children.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: AppTheme.boxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.child_care_rounded,
                size: 60,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "لا يوجد أطفال مسجلون بعد",
              style: AppTextStyles.style(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "أضف طفلك الأول للاستفادة من خدمات النقل المدرسي الآمنة والموثوقة.",
              textAlign: TextAlign.center,
              style: AppTextStyles.style(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openAddChild(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                "إضافة طفلك الأول",
                style: AppTextStyles.style(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: AppTheme.elevatedButtonStyle(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddChild(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChildCubit>(),
          child: const AddChildScreen(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// كرت الطفل
// ─────────────────────────────────────────────────────────────────────────────
class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final int index;

  const _ChildCard({required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMale = child.gender == 'MALE';
    final isPresent = child.dailyStatus == DailyStatus.present;

    // ألوان تمييز الجنس
    final avatarColor = isMale ? AppColors.maleBlue : AppColors.femalePink;
    final avatarBg = isMale ? AppColors.maleBlueBg : AppColors.femalePinkBg;

    // ألوان الفترة الزمنية
    final slotColors = {
      PreferredTimeSlot.MORNING: [AppColors.accentAmber, "صباحي ☀️"],
      PreferredTimeSlot.EVENING: [AppColors.accentBlue, "مسائي 🌙"],
      PreferredTimeSlot.BOTH: [AppColors.accentGreen, "صباحي ومسائي 🔄"],
    };
    final slotInfo = slotColors[child.preferredTimeSlot]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(20),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── رأس الكرت ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // صورة الطفل / أفاتار
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: AppTheme.boxDecoration(
                        color: avatarBg,
                        shape: BoxShape.circle,
                        border: AppTheme.border(
                          color: avatarColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: child.photoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                child.photoUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              isMale ? Icons.boy_rounded : Icons.girl_rounded,
                              color: avatarColor,
                              size: 34,
                            ),
                    ),
                    // مؤشر الحضور
                    Positioned(
                      bottom: 2,
                      left: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: AppTheme.boxDecoration(
                          color: isPresent
                              ? AppColors.success
                              : AppColors.error,
                          shape: BoxShape.circle,
                          border: AppTheme.border(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // الاسم والمدرسة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.fullName,
                        style: AppTextStyles.style(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              child.schoolName,
                              style: AppTextStyles.style(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // بيدج الفترة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: AppTheme.boxDecoration(
                    color: (slotInfo[0] as Color).withValues(alpha: 0.12),
                    borderRadius: AppTheme.radius(20),
                  ),
                  child: Text(
                    slotInfo[1] as String,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      color: slotInfo[0] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── فاصل ──────────────────────────────────────────────────
          Divider(
            height: 1,
            color: isDark
                ? AppColors.white.withValues(alpha: 0.07)
                : AppColors.black.withValues(alpha: 0.06),
          ),

          // ─── أزرار الإجراءات ────────────────────────────────────────
          Row(
            children: [
              _ActionButton(
                icon: Icons.visibility_outlined,
                label: "التفاصيل",
                color: AppColors.primaryLight,
                onTap: () => _openDetails(context),
              ),
              _ActionButton(
                icon: Icons.edit_outlined,
                label: "تعديل",
                color: AppColors.accentPurple,
                onTap: () => _openEdit(context),
              ),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                label: "حذف",
                color: AppColors.error,
                onTap: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChildDetailScreen(child: child)),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChildCubit>(),
          child: AddChildScreen(childToEdit: child),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final cubit = context.read<ChildCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: AppTheme.roundedRectangleBorder(borderRadius: AppTheme.radius(20)),
        title: Text("تأكيد الحذف"),
        content: Text(
          "هل أنت متأكد من حذف بيانات \"${child.fullName}\"؟\nلا يمكن التراجع عن هذا الإجراء.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteChild(child.id!);
            },
            style: AppTheme.elevatedButtonStyle(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text("حذف"),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// زر الإجراء الصغير
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radius(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.style(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
