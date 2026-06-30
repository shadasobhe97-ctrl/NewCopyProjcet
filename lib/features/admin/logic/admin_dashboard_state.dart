import 'package:kids_transport/features/admin/data/models/employee_model.dart';

class AdminDashboardState {
  final int selectedSidebarIndex;
  final bool isSidebarCollapsed;
  final bool isLoading;
  final String? errorMessage;
  final List<EmployeeModel> employees;

  const AdminDashboardState({
    this.selectedSidebarIndex = 7,
    this.isSidebarCollapsed = false,
    this.isLoading = false,
    this.errorMessage,
    this.employees = const [],
  });

  AdminDashboardState copyWith({
    int? selectedSidebarIndex,
    bool? isSidebarCollapsed,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<EmployeeModel>? employees,
  }) {
    return AdminDashboardState(
      selectedSidebarIndex: selectedSidebarIndex ?? this.selectedSidebarIndex,
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      employees: employees ?? this.employees,
    );
  }
}
