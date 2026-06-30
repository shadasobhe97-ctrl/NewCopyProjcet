import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/admin/logic/admin_dashboard_cubit.dart';

class AddEmployeeView extends StatefulWidget {
  const AddEmployeeView({super.key});

  @override
  State<AddEmployeeView> createState() => _AddEmployeeViewState();
}

class _AddEmployeeViewState extends State<AddEmployeeView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'مشرف إدارة';
  final List<String> _roles = const ['مشرف إدارة', 'دعم فني', 'مسؤول مالي'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardCubit>().fetchEmployees();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dashboardCubit = context.read<AdminDashboardCubit>();
    final success = await dashboardCubit.addEmployee(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إضافة الموظف بنجاح'),
          backgroundColor: context.successColor,
        ),
      );
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      setState(() {
        _selectedRole = _roles.first;
      });
      return;
    }

    final errorMessage = dashboardCubit.errorMessage;
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: context.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إضافة موظف جديد',
            style: AppTextStyles.style(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: 'اسم الموظف',
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'الرجاء إدخال الاسم'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'بريد إلكتروني غير صالح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: 'رقم الهاتف',
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'الرجاء إدخال رقم الهاتف'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: 'الصلاحية',
                        prefixIcon: const Icon(Icons.security),
                      ),
                      items: _roles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : _submitForm,
                            child: state.isLoading
                                ? const CircularProgressIndicator(
                                    color: AppColors.white,
                                  )
                                : const Text('حفظ الموظف'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'قائمة الموظفين',
            style: AppTextStyles.style(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
                builder: (context, state) {
                  if (state.isLoading && state.employees.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state.employees.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: Text('لا يوجد موظفين حالياً')),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      final nameWidth = totalWidth * 0.22;
                      final emailWidth = totalWidth * 0.35;
                      final phoneWidth = totalWidth * 0.20;
                      final roleWidth = totalWidth * 0.23;
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: AppTheme.boxDecoration(
                              color: isDark
                                  ? AppColors.grey800
                                  : AppColors.grey100,
                              borderRadius: AppTheme.onlyRadius(
                                topLeft: AppTheme.cornerRadius(12),
                                topRight: AppTheme.cornerRadius(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                _headerCell('الاسم', nameWidth),
                                _headerCell('البريد الإلكتروني', emailWidth),
                                _headerCell('رقم الهاتف', phoneWidth),
                                _headerCell('الصلاحية', roleWidth),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          ...state.employees.asMap().entries.map((entry) {
                            final i = entry.key;
                            final employee = entry.value;
                            final rowColor = i.isEven
                                ? AppColors.transparent
                                : (isDark
                                      ? AppColors.white.withValues(alpha: 0.03)
                                      : AppColors.grey.withValues(alpha: 0.04));

                            return Container(
                              color: rowColor,
                              child: Row(
                                children: [
                                  _dataCell(
                                    SizedBox(
                                      width: nameWidth - 32,
                                      child: Text(
                                        employee.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.style(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    nameWidth,
                                  ),
                                  _dataCell(
                                    SizedBox(
                                      width: emailWidth - 32,
                                      child: Text(
                                        employee.email,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.style(
                                          color: isDark
                                              ? AppColors.grey300
                                              : AppColors.grey700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    emailWidth,
                                  ),
                                  _dataCell(
                                    Text(
                                      employee.phone,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    phoneWidth,
                                  ),
                                  _dataCell(
                                    SizedBox(
                                      width: roleWidth - 32,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: AppTheme.boxDecoration(
                                          color: context.primaryColor
                                              .withValues(alpha: 0.12),
                                          borderRadius: AppTheme.radius(20),
                                          border: AppTheme.border(
                                            color: context.primaryColor
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Text(
                                          employee.role,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.style(
                                            color: context.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    roleWidth,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          label,
          style: AppTextStyles.style(fontWeight: FontWeight.bold, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _dataCell(Widget child, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }
}
