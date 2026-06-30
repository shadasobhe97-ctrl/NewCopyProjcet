import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/admin/data/models/employee_model.dart';
import 'admin_dashboard_state.dart';

export 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit() : super(const AdminDashboardState());

  int get selectedSidebarIndex => state.selectedSidebarIndex;
  bool get isSidebarCollapsed => state.isSidebarCollapsed;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  List<EmployeeModel> get employees => state.employees;

  void setSidebarIndex(int index) {
    emit(state.copyWith(selectedSidebarIndex: index));
  }

  void toggleSidebar() {
    emit(state.copyWith(isSidebarCollapsed: !state.isSidebarCollapsed));
  }

  Future<void> fetchEmployees() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(
        state.copyWith(
          isLoading: false,
          clearError: true,
          employees: [
            EmployeeModel(
              id: '101',
              name: 'ط£ط­ظ…ط¯ ط³ط§ظ„ظ…',
              email: 'ahmed@copyproject.com',
              phone: '0912345678',
              role: 'ظ…ط´ط±ظپ ط¥ط¯ط§ط±ط©',
            ),
            EmployeeModel(
              id: '102',
              name: 'ط³ط§ط±ط© ط®ط§ظ„ط¯',
              email: 'sara@copyproject.com',
              phone: '0923456789',
              role: 'ط¯ط¹ظ… ظپظ†ظٹ',
            ),
          ],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage:
              'ط­ط¯ط« ط®ط·ط£ ط£ط«ظ†ط§ط، ط¬ظ„ط¨ ط¨ظٹط§ظ†ط§طھ ط§ظ„ظ…ظˆط¸ظپظٹظ†',
        ),
      );
    }
  }

  Future<bool> addEmployee({
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await Future.delayed(const Duration(seconds: 1));
      final newEmployee = EmployeeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        role: role,
      );

      emit(
        state.copyWith(
          isLoading: false,
          clearError: true,
          employees: [...state.employees, newEmployee],
        ),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'ط­ط¯ط« ط®ط·ط£ ط؛ظٹط± ظ…طھظˆظ‚ط¹',
        ),
      );
      return false;
    }
  }
}
