import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/employee_model.dart';
import '../../data/repository/projects_repository.dart';
import '../../data/repository/team_repository.dart';
import '../../data/static/team_members_data.dart';
abstract class TeamController extends GetxController {}
class TeamControllerImp extends TeamController {
  final TeamRepository _teamRepository = TeamRepository();
  final ProjectsRepository _projectsRepository = ProjectsRepository();
  final AuthService _authService = AuthService();
  List<TeamMember> _teamMembers = [];
  StatusRequest _statusRequest = StatusRequest.none;
  bool _isLoading = false;
  int _departmentsCount = 0;
  int _projectsCount = 0;
  bool _isLoadingStats = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;
  List<TeamMember> get teamMembers => _teamMembers;
  StatusRequest get statusRequest => _statusRequest;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get departmentsCount => _departmentsCount;
  int get projectsCount => _projectsCount;
  bool get isLoadingStats => _isLoadingStats;
  @override
  void onInit() async {
    super.onInit();
    final companyId = await _authService.getCompanyId();
    loadTeamMembers(companyId: companyId, status: null);
    loadStatistics();
  }
  Future<void> loadStatistics() async {
    _isLoadingStats = true;
    update();
    try {
      final companyId = await _authService.getCompanyId();
      final departmentsCountResult = await _teamRepository
          .getDepartmentsCount();
      departmentsCountResult.fold(
        (error) {
          _departmentsCount = 0;
        },
        (count) {
          _departmentsCount = count;
        },
      );
      final projectsCountResult = await _projectsRepository.getProjectsCount(
        companyId: companyId,
      );
      projectsCountResult.fold(
        (error) {
          _projectsCount = 0;
        },
        (count) {
          _projectsCount = count;
        },
      );
    } catch (e) {
      _departmentsCount = 0;
      _projectsCount = 0;
    }
    _isLoadingStats = false;
    update();
  }
  Future<void> loadTeamMembers({
    String? companyId,
    String? status,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _teamMembers = [];
      _hasMore = true;
    }
    if (!_hasMore && !refresh) {
      return;
    }
    _isLoading = true;
    _statusRequest = StatusRequest.loading;
    update();
    String? finalCompanyId = await _authService.getCompanyId();
    if (finalCompanyId == null || finalCompanyId.isEmpty) {
      _isLoading = false;
      _statusRequest = StatusRequest.serverFailure;
      update();
      return;
    }
    final result = await _loadAllTeamMembers(
      companyId: finalCompanyId,
      status: status,
    );
    _isLoading = false;
    result.fold(
      (error) {
        _statusRequest = error;
        update();
      },
      (employees) {
        final newMembers = employees.map((e) {
          final member = e.toTeamMember();
          return member;
        }).toList();
        _teamMembers = newMembers;
        _statusRequest = StatusRequest.success;
        update();
      },
    );
  }
  Future<void> refreshTeamMembers({String? companyId, String? status}) async {
    await loadTeamMembers(companyId: companyId, status: status, refresh: true);
  }
  Future<void> loadMore({String? companyId, String? status}) async {
    if (!_hasMore || _isLoading) {
      return;
    }
    await loadTeamMembers(companyId: companyId, status: status, refresh: false);
  }
  Future<Either<StatusRequest, List<EmployeeModel>>> _loadAllTeamMembers({
    required String companyId,
    String? status,
  }) async {
    List<EmployeeModel> allEmployees = [];
    int currentPage = 1;
    const int maxLimit = 100;

    while (true) {
      final result = await _teamRepository.getEmployees(
        page: currentPage,
        limit: maxLimit,
        companyId: companyId,
        status: status,
      );

      final shouldContinue = result.fold(
        (error) {
          if (allEmployees.isNotEmpty) {
            return false;
          }
          return false;
        },
        (employees) {
          allEmployees.addAll(employees);
          return employees.length >= maxLimit;
        },
      );

      if (!shouldContinue) {
        return result.fold(
          (error) {
            if (allEmployees.isNotEmpty) {
              return Right<StatusRequest, List<EmployeeModel>>(allEmployees);
            }
            return Left<StatusRequest, List<EmployeeModel>>(error);
          },
          (employees) => Right<StatusRequest, List<EmployeeModel>>(allEmployees),
        );
      }

      currentPage++;
    }
  }

  Map<String, int> getTeamStats() {
    final total = _teamMembers.length;
    final active = _teamMembers.where((m) => m.status == 'Active').length;
    final away = _teamMembers
        .where((m) => m.status == 'Away' || m.status == 'On Leave')
        .length;
    final terminated = _teamMembers
        .where((m) => m.status == 'Terminated')
        .length;
    return {
      'total': total,
      'active': active,
      'busy': terminated,
      'away': away,
      'terminated': terminated,
    };
  }
}
