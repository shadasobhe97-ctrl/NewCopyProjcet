import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/features/parent/data/models/child_model.dart';
import 'package:kids_transport/features/parent/logic/child_cubit/child_cubit.dart';
import 'package:kids_transport/features/parent/logic/child_cubit/child_state.dart';
import 'add_child_screen.dart';
import 'child_detail_screen.dart';

class MyChildrenScreen extends StatelessWidget {
  const MyChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildCubit, ChildState>(
      builder: (context, state) {
        if (state is ChildLoading) {
          return const Center(
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
                const Icon(Icons.error_outline_rounded,
                    size: 60, color: AppColors.error),
                const SizedBox(height: 12),
                Text(state.message,
                    style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<ChildCubit>().loadChildren(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("إعادة المحاولة"),
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
      backgroundColor:
          isDark ? const Color(0xFF0F0F0F) : AppColors.backgroundLight,
      body: children.isEmpty
          ? _buildEmptyState(context)
          : _buildList(context, isDark),
      // زر إضافة طفل عائم
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddChild(context),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text("إضافة طفل",
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        "${children.length} ${children.length == 1 ? 'طفل مسجل' : 'أطفال مسجلون'}",
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13),
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
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.child_care_rounded,
                size: 60,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "لا يوجد أطفال مسجلون بعد",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "أضف طفلك الأول للاستفادة من خدمات النقل المدرسي الآمنة والموثوقة.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openAddChild(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text("إضافة طفلك الأول",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
    final avatarColor = isMale
        ? const Color(0xFF3B82F6)
        : const Color(0xFFEC4899);
    final avatarBg = isMale
        ? const Color(0xFFEFF6FF)
        : const Color(0xFFFDF2F8);

    // ألوان الفترة الزمنية
    final slotColors = {
      PreferredTimeSlot.MORNING: [const Color(0xFFF59E0B), "صباحي ☀️"],
      PreferredTimeSlot.EVENING: [const Color(0xFF6366F1), "مسائي 🌙"],
      PreferredTimeSlot.BOTH: [const Color(0xFF10B981), "صباحي ومسائي 🔄"],
    };
    final slotInfo = slotColors[child.preferredTimeSlot]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
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
                      decoration: BoxDecoration(
                        color: avatarBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: avatarColor.withOpacity(0.3), width: 2),
                      ),
                      child: child.photoUrl != null
                          ? ClipOval(
                              child: Image.network(child.photoUrl!,
                                  fit: BoxFit.cover))
                          : Icon(
                              isMale
                                  ? Icons.boy_rounded
                                  : Icons.girl_rounded,
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
                        decoration: BoxDecoration(
                          color: isPresent
                              ? AppColors.success
                              : AppColors.error,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2),
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
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.school_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              child.schoolName,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
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
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (slotInfo[0] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    slotInfo[1] as String,
                    style: TextStyle(
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
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.06)),

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
                color: const Color(0xFF8B5CF6),
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
      MaterialPageRoute(
        builder: (_) => ChildDetailScreen(child: child),
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تأكيد الحذف"),
        content: Text(
          "هل أنت متأكد من حذف بيانات \"${child.fullName}\"؟\nلا يمكن التراجع عن هذا الإجراء.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteChild(child.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text("حذف"),
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
