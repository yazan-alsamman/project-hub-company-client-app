import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/assignment_model.dart';
import '../../data/Models/employee_model.dart';
import '../../data/repository/assignments_repository.dart';
import '../../data/repository/team_repository.dart';
abstract class AssignmentsController extends GetxController {
  List<AssignmentModel> get assignments;
  List<EmployeeModel> get employees;
  StatusRequest get statusRequest;
  bool get isLoading;
  String? get selectedEmployeeId;
  String? get selectedEmployeeName;
  Future<void> loadEmployees();
  Future<void> loadAssignments(String employeeId);
  void selectEmployee(String? employeeId, String? employeeName);
  Future<void> refreshAssignments();
}
class AssignmentsControllerImp extends AssignmentsController {
  final AssignmentsRepository _assignmentsRepository = AssignmentsRepository();
  final TeamRepository _teamRepository = TeamRepository();
  final AuthService _authService = AuthService();
  List<AssignmentModel> _assignments = [];
  List<EmployeeModel> _employees = [];
  StatusRequest _statusRequest = StatusRequest.none;
  bool _isLoading = false;
  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  @override
  List<AssignmentModel> get assignments => _assignments;
  @override
  List<EmployeeModel> get employees => _employees;
  @override
  StatusRequest get statusRequest => _statusRequest;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get selectedEmployeeId => _selectedEmployeeId;
  @override
  String? get selectedEmployeeName => _selectedEmployeeName;
  @override
  void onInit() {
    super.onInit();
    debugPrint('🔵 AssignmentsControllerImp.onInit() called');
    loadEmployees();
  }
  @override
  Future<void> loadEmployees() async {
    debugPrint('🔵 Loading employees...');
    try {
      final companyId = await _authService.getCompanyId();
      debugPrint('🔵 Using companyId from AuthService: $companyId');
      final result = await _teamRepository.getEmployees(
        page: 1,
        limit: 100, // Get all employees for dropdown
        companyId: companyId,
        status: null, // Get all employees
      );
      result.fold(
        (error) {
          debugPrint('🔴 Error loading employees: $error');
        },
        (employees) {
          debugPrint('✅ Loaded ${employees.length} employees');
          _employees = employees;
          update();
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading employees: $e');
    }
  }
  @override
  void selectEmployee(String? employeeId, String? employeeName) {
    _selectedEmployeeId = employeeId;
    _selectedEmployeeName = employeeName;
    debugPrint('🔵 Selected employee: $employeeName (ID: $employeeId)');
    update();
  }
  @override
  Future<void> loadAssignments(String employeeId) async {
    if (_isLoading) {
      debugPrint('🟡 Already loading assignments, returning.');
      return;
    }
    _isLoading = true;
    _statusRequest = StatusRequest.loading;
    _assignments = [];
    update();
    debugPrint('🔵 Loading assignments for employee: $employeeId');
    final result = await _assignmentsRepository.getAssignmentsByEmployee(
      employeeId: employeeId,
      page: 1,
      limit: 10,
    );
    _isLoading = false;
    result.fold(
      (error) {
        debugPrint('🔴 Error loading assignments: $error');
        _statusRequest = error;
        update();
      },
      (assignments) {
        debugPrint('✅ Loaded ${assignments.length} assignments');
        _assignments = assignments;
        _statusRequest = StatusRequest.success;
        update();
      },
    );
  }
  @override
  Future<void> refreshAssignments() async {
    if (_selectedEmployeeId != null) {
      await loadAssignments(_selectedEmployeeId!);
    }
  }
}
