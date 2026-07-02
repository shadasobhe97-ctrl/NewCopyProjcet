import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/empty_state_placeholder.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/logic/child_cubit/child_cubit.dart';
import 'package:kids_transport/features/parent/children/logic/child_cubit/child_state.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/child_detail_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/child_card.dart';

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
          return _ChildrenBody(children: state.children);
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
                  label: const Text('إعادة المحاولة'),
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

// ─── هيكل شاشة الأطفال ──────────────────────────────────────────────────────
class _ChildrenBody extends StatelessWidget {
  final List<ChildModel> children;
  const _ChildrenBody({required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: children.isEmpty
          ? EmptyStatePlaceholder(
              icon: Icons.child_care_rounded,
              title: 'لا يوجد أطفال مسجلون بعد',
              subtitle:
                  'أضف طفلك الأول للاستفادة من خدمات النقل المدرسي الآمنة والموثوقة.',
              actionLabel: 'إضافة طفلك الأول',
              onAction: () => _openAddChild(context),
            )
          : _buildChildrenList(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddChild(context),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'إضافة طفل',
          style: AppTextStyles.style(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildChildrenList(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أطفالي المسجلون 👨‍👧‍👦',
                  style: AppTextStyles.style(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${children.length} ${children.length == 1 ? 'طفل مسجل' : 'أطفال مسجلون'}',
                  style: AppTextStyles.style(
                    color: AppColors.textMuted,
                    fontSize: 13,
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
              (context, index) {
                final child = children[index];
                return ChildCard(
                  child: child,
                  onViewDetails: () => _openDetails(context, child),
                  onEdit: () => _openEdit(context, child),
                  onDelete: () => _confirmDelete(context, child),
                );
              },
              childCount: children.length,
            ),
          ),
        ),
      ],
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

  void _openDetails(BuildContext context, ChildModel child) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChildDetailScreen(child: child)),
    );
  }

  void _openEdit(BuildContext context, ChildModel child) {
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

  void _confirmDelete(BuildContext context, ChildModel child) {
    final cubit = context.read<ChildCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف بيانات "${child.fullName}"؟\nلا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteChild(child.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
