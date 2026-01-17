import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/assignment_model.dart';
import '../../data/Models/employee_model.dart';
import '../../data/repository/assignments_repository.dart';
import '../../data/repository/team_repository.dart';

abstract class ReassignAssignmentController extends GetxController {
  void reassignAssignment();
  void loadEmployees();
  void selectEmployee(String? employeeId);
}

class ReassignAssignmentControllerImp extends ReassignAssignmentController {
  final AssignmentsRepository _assignmentsRepository = AssignmentsRepository();
  final TeamRepository _teamRepository = TeamRepository();
  final AuthService _authService = AuthService();

  late AssignmentModel assignment;
  List<EmployeeModel> employees = [];
  String? selectedEmployeeId;
  bool isLoadingEmployees = false;
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is AssignmentModel) {
      assignment = args;
      selectedEmployeeId = assignment.employeeId; // Default to current employee
    } else {
      throw ArgumentError('AssignmentModel is required as argument');
    }
    loadEmployees();
  }

  @override
  Future<void> loadEmployees() async {
    isLoadingEmployees = true;
    update();
    try {
      final companyId = await _authService.getCompanyId();
      final result = await _teamRepository.getEmployees(
        page: 1,
        limit: 100,
        companyId: companyId,
        status: 'active',
      );
      isLoadingEmployees = false;
      result.fold(
        (error) {
          errorMessage = 'Failed to load employees';
          update();
        },
        (loadedEmployees) {
          employees = loadedEmployees;
          update();
        },
      );
    } catch (e) {
      isLoadingEmployees = false;
      errorMessage = 'An error occurred while loading employees';
      update();
    }
  }

  @override
  void selectEmployee(String? employeeId) {
    selectedEmployeeId = employeeId;
    update();
  }

  @override
  Future<void> reassignAssignment() async {
    if (selectedEmployeeId == null || selectedEmployeeId!.isEmpty) {
      errorMessage = 'Please select an employee';
      Get.snackbar(
        'Error',
        errorMessage!,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      update();
      return;
    }

    if (selectedEmployeeId == assignment.employeeId) {
      errorMessage = 'Please select a different employee';
      Get.snackbar(
        'Error',
        errorMessage!,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      update();
      return;
    }

    isLoading = true;
    errorMessage = null;
    update();

    final result = await _assignmentsRepository.reassignAssignment(
      assignmentId: assignment.id,
      newEmployeeId: selectedEmployeeId!,
    );

    isLoading = false;

    result.fold(
      (error) {
        String errorMsg = 'Failed to reassign assignment';
        if (error is Map<String, dynamic>) {
          errorMsg = error['message']?.toString() ?? errorMsg;
        } else if (error is String) {
          errorMsg = error;
        }
        errorMessage = errorMsg;
        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        update();
      },
      (updatedAssignment) {
        assignment = updatedAssignment;
        Get.snackbar(
          'Success',
          'Assignment reassigned successfully!',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        Get.back();
      },
    );
  }
}

