import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/empty_state_placeholder.dart';
import '../../data/models/child_model.dart';
import '../../logic/children_cubit/children_cubit.dart';
import 'add_child_step1_screen.dart';
import 'child_data_details_screen.dart';
import 'child_pass_screen.dart';
import 'transport_details_screen.dart';
import '../widgets/child_card_widget.dart';

class MyChildrenScreen extends StatefulWidget {
  const MyChildrenScreen({super.key});

  @override
  State<MyChildrenScreen> createState() => _MyChildrenScreenState();
}

class _MyChildrenScreenState extends State<MyChildrenScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChildrenCubit>().fetchChildren();
  }

  void _openAddChild(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddChildStep1Screen()),
    );
  }

  void _confirmDelete(BuildContext context, ChildModel child) {
    final cubit = context.read<ChildrenCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف بيانات "${child.name}"؟\nلا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    cubit.deleteChild(child.id!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'حذف',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('إلغاء'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: BlocConsumer<ChildrenCubit, ChildrenState>(
        listener: (context, state) {
          if (state is ChildrenActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ChildrenActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final List<ChildModel> children = state is ChildrenLoaded
              ? state.children
              : const [];
          final bool isActionLoading = state is ChildrenActionLoading;
          final bool isFullLoading =
              state is ChildrenLoading || state is ChildrenInitial;

          String subtitle = 'ابدأ بإضافة طفلك الأول.';
          if (isFullLoading) {
            subtitle = 'جاري تحميل قائمة الأطفال...';
          } else if (state is ChildrenError) {
            subtitle = 'تعذر الاتصال بالسيرفر لتحميل الأطفال.';
          } else if (children.isNotEmpty) {
            subtitle = 'لديك ${children.length} طفل مسجل.';
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // البطاقة العلوية الثابتة - تظهر دائماً حتى أثناء التحميل أو حدوث خطأ
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? AppColors.darkCard
                              : AppColors.white,
                          borderRadius: AppTheme.radius(16),
                          border: AppTheme.border(color: AppColors.grey200),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(
                                alpha: context.isDarkMode ? 0.3 : 0.05,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أطفالي',
                              style: AppTextStyles.style(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: AppTextStyles.style(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                // يظل الزر متاحاً للإضافة طالما لا توجد عملية حذف/تعديل جارية
                                onPressed: isActionLoading
                                    ? null
                                    : () => _openAddChild(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryLight,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.radius(12),
                                  ),
                                ),
                                child: Text(
                                  'إضافة طفل جديد',
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // محتوى الشاشة بناءً على الحالة
                  if (isFullLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 64),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    )
                  else if (state is ChildrenError)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 48,
                          horizontal: 24,
                        ),
                        child: InkWell(
                          onTap: () =>
                              context.read<ChildrenCubit>().fetchChildren(),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.refresh_rounded,
                                size: 48,
                                color: AppColors.errorLight,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'إعادة المحاولة',
                                style: AppTextStyles.style(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.errorLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.style(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (children.isEmpty)
                    SliverToBoxAdapter(
                      child: EmptyStatePlaceholder(
                        icon: Icons.child_care_rounded,
                        title: 'لا يوجد أطفال مسجلون بعد',
                        subtitle:
                            'أضف طفلك الأول للاستفادة من خدمات النقل المدرسي الآمنة والموثوقة.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final child = children[index];
                          return ChildCardWidget(
                            child: child,
                            onPassTap: isActionLoading
                                ? () {}
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChildPassScreen(child: child),
                                    ),
                                  ),
                            onDataTap: isActionLoading
                                ? () {}
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChildDataDetailsScreen(child: child),
                                    ),
                                  ),
                            onTransportTap: isActionLoading
                                ? () {}
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TransportDetailsScreen(child: child),
                                    ),
                                  ),
                            onDelete: isActionLoading
                                ? () {}
                                : () => _confirmDelete(context, child),
                          );
                        }, childCount: children.length),
                      ),
                    ),
                ],
              ),
              if (isActionLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33000000),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
