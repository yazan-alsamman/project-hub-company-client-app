import 'package:dartz/dartz.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/project_model.dart';
import '../../data/repository/projects_repository.dart';
import '../../data/repository/team_repository.dart';

abstract class ProjectsController extends GetxController {
  List<ProjectModel> get projects;
  String get selectedFilter;
  StatusRequest get statusRequest;
  bool get isLoading;
  void selectFilter(String filter);
  Future<void> loadProjects({bool refresh = false});
  Future<void> refreshProjects();
  List<ProjectModel> get filteredProjects;
}

class ProjectsControllerImp extends ProjectsController {
  final ProjectsRepository _repository = ProjectsRepository();
  List<ProjectModel> _projects = [];
  String _selectedFilter = 'All';
  StatusRequest _statusRequest = StatusRequest.none;
  bool _isLoading = false;
  @override
  List<ProjectModel> get projects => _projects;
  @override
  String get selectedFilter => _selectedFilter;
  @override
  StatusRequest get statusRequest => _statusRequest;
  @override
  bool get isLoading => _isLoading;
  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  @override
  Future<void> loadProjects({bool refresh = false}) async {
    if (_isLoading && !refresh) {
      return;
    }
    List<ProjectModel>? backupProjects;
    if (refresh && _projects.isNotEmpty) {
      backupProjects = List.from(_projects);
    }
    _isLoading = true;
    if (refresh) {
      _statusRequest = StatusRequest.loading;
    } else if (_projects.isEmpty) {
      _statusRequest = StatusRequest.loading;
    }
    update();
    final authService = AuthService();
    final userRole = await authService.getUserRole();
    final isDeveloper = userRole?.toLowerCase() == 'developer';

    String? companyId;
    if (!isDeveloper) {
      companyId = await _getCompanyId();
      if (companyId == null || companyId.isEmpty) {
        _isLoading = false;
        _statusRequest = StatusRequest.serverFailure;
        update();
        return;
      }
    }
    String? apiStatus;
    if (_selectedFilter != 'All') {
      switch (_selectedFilter.toLowerCase()) {
        case 'active':
          apiStatus = 'in_progress';
          break;
        case 'completed':
          apiStatus = 'completed';
          break;
        case 'planned':
          apiStatus = 'pending';
          break;
        default:
          apiStatus = null;
      }
    }
    final result = await _loadAllProjects(
      companyId: companyId,
      status: apiStatus,
    );
    _isLoading = false;
    result.fold(
      (error) {
        _statusRequest = error;
        if (refresh && backupProjects != null) {
          _projects = List.from(backupProjects);
          _applyLocalFilter();
        } else if (!refresh) {
          _projects = [];
        }
        update();
      },
      (projects) {
        _projects = projects;
        _statusRequest = StatusRequest.success;
        update();
      },
    );
  }

  Future<String?> _getCompanyId() async {
    try {
      final authService = AuthService();
      final userRole = await authService.getUserRole();
      final isDeveloper = userRole?.toLowerCase() == 'developer';

      final savedCompanyId = await authService.getCompanyId();
      if (savedCompanyId != null && savedCompanyId.isNotEmpty) {
        if (isDeveloper) {
          return savedCompanyId;
        }
        return savedCompanyId;
      }

      if (!isDeveloper) {
        final userId = await authService.getUserId();
        if (userId != null && userId.isNotEmpty) {
          try {
            final teamRepository = TeamRepository();
            final employeeResult = await teamRepository.getEmployeeById(userId);
            String? companyIdFromEmployee;
            employeeResult.fold((error) {}, (employee) {
              if (employee.companyId != null) {
                final companyIdStr = employee.companyId!['_id']?.toString();
                if (companyIdStr != null && companyIdStr.isNotEmpty) {
                  authService.saveCompanyId(companyIdStr);
                  companyIdFromEmployee = companyIdStr;
                }
              }
            });
            if (companyIdFromEmployee != null) {
              return companyIdFromEmployee;
            }
          } catch (e) {}
        }
      }
    } catch (e) {}
    return null;
  }

  @override
  void selectFilter(String filter) {
    if (_selectedFilter == filter) {
      return;
    }
    _selectedFilter = filter;
    loadProjects(refresh: true);
  }

  @override
  Future<void> refreshProjects() async {
    await loadProjects(refresh: true);
  }

  void _applyLocalFilter() {
    if (_selectedFilter == 'All') {
      return;
    }
    String targetStatus;
    switch (_selectedFilter.toLowerCase()) {
      case 'active':
        targetStatus = 'active';
        break;
      case 'completed':
        targetStatus = 'completed';
        break;
      case 'planned':
        targetStatus = 'planned';
        break;
      default:
        return;
    }
    final filtered = _projects
        .where((project) => project.status.toLowerCase() == targetStatus)
        .toList();
    _projects = filtered;
  }

  Future<Either<StatusRequest, List<ProjectModel>>> _loadAllProjects({
    String? companyId,
    String? status,
  }) async {
    List<ProjectModel> allProjects = [];
    int currentPage = 1;
    const int maxLimit = 100;

    while (true) {
      final result = await _repository.getProjects(
        page: currentPage,
        limit: maxLimit,
        companyId: companyId,
        status: status,
      );

      final shouldContinue = result.fold(
        (error) {
          if (allProjects.isNotEmpty) {
            return false;
          }
          return false;
        },
        (projects) {
          allProjects.addAll(projects);
          return projects.length >= maxLimit;
        },
      );

      if (!shouldContinue) {
        return result.fold((error) {
          if (allProjects.isNotEmpty) {
            return Right<StatusRequest, List<ProjectModel>>(allProjects);
          }
          return Left<StatusRequest, List<ProjectModel>>(error);
        }, (projects) => Right<StatusRequest, List<ProjectModel>>(allProjects));
      }

      currentPage++;
    }
  }

  @override
  List<ProjectModel> get filteredProjects {
    return _projects;
  }
}
