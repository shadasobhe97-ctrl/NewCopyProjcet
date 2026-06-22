import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/features/admin/logic/admin_dashboard_provider.dart';

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
  final List<String> _roles = ['مشرف إدارة', 'دعم فني', 'مسؤول مالي'];

  @override
  void initState() {
    super.initState();
    // جلب الموظفين عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardProvider>(context, listen: false).fetchEmployees();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AdminDashboardProvider>(context, listen: false);
      
      final success = await provider.addEmployee(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الموظف بنجاح'), backgroundColor: Colors.green),
        );
        // تفريغ الحقول بعد الإضافة
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        setState(() {
          _selectedRole = _roles.first;
        });
      } else if (mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!), backgroundColor: AppColors.errorLight),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إضافة موظف جديد',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 24),
          
          // نموذج إدخال الموظف
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'اسم الموظف', prefixIcon: Icon(Icons.person)),
                      validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال الاسم' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email)),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
                        if (!value.contains('@')) return 'بريد إلكتروني غير صالح';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)),
                      validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(labelText: 'الصلاحية', prefixIcon: Icon(Icons.security)),
                      items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Consumer<AdminDashboardProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _submitForm,
                            child: provider.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
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
          const Text(
            'قائمة الموظفين',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // جدول الموظفين
          Card(
            child: SizedBox(
              width: double.infinity,
              child: Consumer<AdminDashboardProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.employees.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (provider.employees.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: Text('لا يوجد موظفين حالياً')),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      // توزيع العرض: الاسم 22%، البريد 35%، الهاتف 20%، الصلاحية 23%
                      final nameWidth    = totalWidth * 0.22;
                      final emailWidth   = totalWidth * 0.35;
                      final phoneWidth   = totalWidth * 0.20;
                      final roleWidth    = totalWidth * 0.23;

                      final isDark = Theme.of(context).brightness == Brightness.dark;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // رأس الجدول
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
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
                          // صفوف الجدول
                          ...provider.employees.asMap().entries.map((entry) {
                            final i        = entry.key;
                            final employee = entry.value;
                            final isEven   = i.isEven;
                            final rowColor = isEven
                                ? Colors.transparent
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.03)
                                    : Colors.grey.withValues(alpha: 0.04));

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
                                        style: const TextStyle(fontWeight: FontWeight.w500),
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
                                        style: TextStyle(
                                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
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
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: AppColors.primaryLight.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Text(
                                          employee.role,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.primaryLight,
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

  // خلية رأس الجدول
  Widget _headerCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // خلية بيانات الجدول
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
