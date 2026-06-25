import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:kids_transport/features/admin/presentation/widgets/add_employee_view.dart';
import 'package:kids_transport/features/admin/logic/admin_dashboard_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد ما إذا كانت الشاشة كبيرة (Desktop/Tablet) أو صغيرة (Mobile)
        final bool isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          appBar: isDesktop
              ? null // لا يوجد AppBar في الشاشات الكبيرة لوجود الشريط الجانبي الثابت
              : AppBar(
                  title: const Text('لوحة الإدارة', style: TextStyle(color: Colors.white)),
                  backgroundColor: AppColors.primaryLight,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
          drawer: isDesktop
              ? null
              : const Drawer(
                  child: AdminSidebar(isDrawer: true), // الشريط الجانبي كـ Drawer
                ),
          body: Row(
            children: [
              // الشريط الجانبي الثابت للشاشات الكبيرة
              if (isDesktop) 
                const AdminSidebar(isDrawer: false),
                
              // المحتوى المتغير بناءً على الاختيار
              Expanded(
                child: Consumer<AdminDashboardProvider>(
                  builder: (context, provider, child) {
                    return _buildDashboardContent(provider.selectedSidebarIndex);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة لعرض المحتوى بناءً على الاختيار في الشريط الجانبي
  Widget _buildDashboardContent(int index) {
    switch (index) {
      case 7: // إضافة موظف جديد
        return const AddEmployeeView();
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
        // شاشات وهمية مؤقتة لباقي الأقسام
        return Center(
          child: Text(
            'هذا القسم قيد التطوير...',
            style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
          ),
        );
      default:
        return const Center(child: Text('القسم غير موجود'));
    }
  }
}
