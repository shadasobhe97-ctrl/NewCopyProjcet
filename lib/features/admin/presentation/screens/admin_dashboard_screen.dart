import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/admin/logic/admin_dashboard_cubit.dart';
import 'package:kids_transport/features/admin/presentation/widgets/add_employee_view.dart';
import 'package:kids_transport/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  title: Text(
                    'لوحة الإدارة',
                    style: AppTextStyles.style(color: AppColors.white),
                  ),
                  backgroundColor: context.primaryColor,
                  iconTheme: const IconThemeData(color: AppColors.white),
                ),
          drawer: isDesktop
              ? null
              : const Drawer(child: AdminSidebar(isDrawer: true)),
          body: Row(
            children: [
              if (isDesktop) const AdminSidebar(isDrawer: false),
              Expanded(
                child: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
                  builder: (context, state) {
                    return _buildDashboardContent(
                      context,
                      state.selectedSidebarIndex,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, int index) {
    switch (index) {
      case 7:
        return const AddEmployeeView();
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
        return Center(
          child: Text(
            'هذا القسم قيد التطوير...',
            style: AppTextStyles.style(fontSize: 24, color: context.textMuted),
          ),
        );
      default:
        return const Center(child: Text('القسم غير موجود'));
    }
  }
}
