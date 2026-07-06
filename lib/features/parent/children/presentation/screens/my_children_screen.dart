import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/empty_state_placeholder.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_state.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_step1_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/child_data_details_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/child_pass_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/transport_details_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/child_card_widget.dart';

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
                  child: const Text('حذف', style: TextStyle(color: Colors.white)),
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
      body: BlocBuilder<ChildrenCubit, ChildrenState>(
        builder: (context, state) {
          if (state is ChildrenLoading || state is ChildrenInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            );
          }
          
          if (state is ChildrenError) {
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
                    onPressed: () => context.read<ChildrenCubit>().fetchChildren(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          
          if (state is ChildrenLoaded) {
            final children = state.children;
            return CustomScrollView(
              slivers: [
                // البطاقة العلوية الثابتة
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.isDarkMode ? AppColors.darkCard : AppColors.white,
                        borderRadius: AppTheme.radius(16),
                        border: AppTheme.border(color: AppColors.grey200),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: context.isDarkMode ? 0.3 : 0.05),
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
                            children.isEmpty
                                ? 'ابدأ بإضافة طفلك الأول.'
                                : 'لديك ${children.length} طفل مسجل.',
                            style: AppTextStyles.style(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _openAddChild(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
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

                // محتوى القائمة أو الحالة الفارغة
                if (children.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyStatePlaceholder(
                      icon: Icons.child_care_rounded,
                      title: 'لا يوجد أطفال مسجلون بعد',
                      subtitle:
                          'أضف طفلك الأول للاستفادة من خدمات النقل المدرسي الآمنة والموثوقة.',
                      actionLabel: 'إضافة طفلك الأول',
                      onAction: () => _openAddChild(context),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final child = children[index];
                          return ChildCardWidget(
                            child: child,
                            onPassTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ChildPassScreen(child: child)),
                            ),
                            onDataTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ChildDataDetailsScreen(child: child)),
                            ),
                            onTransportTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TransportDetailsScreen(child: child)),
                            ),
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
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
