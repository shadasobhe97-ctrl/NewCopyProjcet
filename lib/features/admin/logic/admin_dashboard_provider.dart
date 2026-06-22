import 'package:flutter/material.dart';
import 'package:kids_transport/features/admin/data/models/employee_model.dart';
// import 'package:dio/dio.dart'; // للاتصال بالخادم

class AdminDashboardProvider with ChangeNotifier {
  // حالة التحكم بالـ Sidebar والتصغير
  int _selectedSidebarIndex = 7; // نجعله يبدأ عند "إضافة موظف جديد" حسب الطلب
  bool _isSidebarCollapsed = false;

  int get selectedSidebarIndex => _selectedSidebarIndex;
  bool get isSidebarCollapsed => _isSidebarCollapsed;

  void setSidebarIndex(int index) {
    _selectedSidebarIndex = index;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  // حالة التحكم بالموظفين
  bool _isLoading = false;
  String? _errorMessage;
  final List<EmployeeModel> _employees = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EmployeeModel> get employees => _employees;

  // دالة لجلب الموظفين عند بدء تشغيل اللوحة
  Future<void> fetchEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ---------------------------------------------------------
      // الكود الفعلي للربط مع السيرفر (API)
      // ---------------------------------------------------------
      /*
      final dio = Dio();
      final response = await dio.get('https://api.copyproject.com/admin/employees');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['employees'];
        _employees.clear();
        for (var json in data) {
          _employees.add(EmployeeModel.fromJson(json));
        }
      }
      */

      // ---------------------------------------------------------
      // بيانات تجريبية (Mocking)
      // ---------------------------------------------------------
      await Future.delayed(const Duration(seconds: 1));
      _employees.clear();
      _employees.addAll([
        EmployeeModel(id: '101', name: 'أحمد سالم', email: 'ahmed@copyproject.com', phone: '0912345678', role: 'مشرف إدارة'),
        EmployeeModel(id: '102', name: 'سارة خالد', email: 'sara@copyproject.com', phone: '0923456789', role: 'دعم فني'),
      ]);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء جلب بيانات الموظفين';
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة لإضافة موظف جديد
  Future<bool> addEmployee({
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ---------------------------------------------------------
      // الكود الفعلي للإرسال إلى السيرفر (API)
      // ---------------------------------------------------------
      /*
      final dio = Dio();
      final response = await dio.post(
        'https://api.copyproject.com/admin/employees/add',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'role': role,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // إذا كان السيرفر يرجع بيانات الموظف الجديد:
        // final newEmployee = EmployeeModel.fromJson(response.data['employee']);
        // _employees.add(newEmployee);
      } else {
        _errorMessage = 'فشل إضافة الموظف في السيرفر';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      */

      // ---------------------------------------------------------
      // تحديث الحالة محلياً للمحاكاة
      // ---------------------------------------------------------
      await Future.delayed(const Duration(seconds: 1));
      final newEmployee = EmployeeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // توليد ID عشوائي
        name: name,
        email: email,
        phone: phone,
        role: role,
      );
      
      // إدراج الموظف في القائمة محلياً لتحديث الجدول فوراً
      _employees.add(newEmployee);
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
