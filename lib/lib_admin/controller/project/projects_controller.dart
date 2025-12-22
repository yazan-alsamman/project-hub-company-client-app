import 'package:flutter/foundation.dart';
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
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;
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
    debugPrint('🔵 ProjectsControllerImp.onInit() called');
    loadProjects();
  }
  @override
  Future<void> loadProjects({bool refresh = false}) async {
    if (_isLoading && !refresh) {
      debugPrint('🟡 Already loading, returning.');
      return;
    }
    List<ProjectModel>? backupProjects;
    if (refresh && _projects.isNotEmpty) {
      backupProjects = List.from(_projects);
      debugPrint('💾 Saved backup of ${backupProjects.length} projects');
    }
    _isLoading = true;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _statusRequest = StatusRequest.loading;
      debugPrint('🔄 Refreshing projects with filter: $_selectedFilter...');
    } else if (_projects.isEmpty) {
      _statusRequest = StatusRequest.loading;
      debugPrint('⏳ Initial load of projects...');
    }
    update();
    String? companyId = await _getCompanyId();
    // التحقق من وجود companyId قبل الإرسال
    if (companyId == null || companyId.isEmpty) {
      debugPrint('🔴 CompanyId is required but not found');
      _isLoading = false;
      _statusRequest = StatusRequest.serverFailure;
      update();
      return;
    }
    debugPrint('🔵 Loading projects...');
    debugPrint('Page: $_currentPage, Limit: $_limit');
    debugPrint('CompanyId: $companyId, Filter: $_selectedFilter');
    String? apiStatus;
    if (_selectedFilter != 'All') {
      switch (_selectedFilter.toLowerCase()) {
        case 'active':
          apiStatus =
              'in_progress'; // API uses 'in_progress' for active projects
          debugPrint('🔵 Mapped filter "Active" to API status: $apiStatus');
          break;
        case 'completed':
          apiStatus = 'completed';
          debugPrint('🔵 Mapped filter "Completed" to API status: $apiStatus');
          break;
        case 'planned':
          apiStatus = 'pending'; // API uses 'pending' for planned projects
          debugPrint('🔵 Mapped filter "Planned" to API status: $apiStatus');
          break;
        default:
          apiStatus = null;
          debugPrint(
            '⚠️ Unknown filter: $_selectedFilter, not sending status parameter',
          );
      }
    } else {
      debugPrint('🔵 Filter is "All", not sending status parameter');
    }
    debugPrint('🔵 Final API status value to send: $apiStatus');
    final result = await _repository.getProjects(
      page: _currentPage,
      limit: _limit,
      companyId: companyId,
      status: apiStatus,
    );
    _isLoading = false;
    result.fold(
      (error) {
        debugPrint('🔴 Error loading projects: $error');
        _statusRequest = error;
        if (refresh && backupProjects != null) {
          debugPrint(
            '⚠️ Refresh failed, restoring backup of ${backupProjects.length} projects',
          );
          _projects = List.from(backupProjects);
          _applyLocalFilter();
        } else if (!refresh) {
          _projects = [];
        }
        update();
      },
      (projects) {
        debugPrint('✅ Loaded ${projects.length} projects');
        for (var project in projects) {
          debugPrint(
            '  - Project: ${project.title}, Status: ${project.status}',
          );
        }
        if (refresh) {
          _projects = projects;
        } else {
          _projects.addAll(projects);
        }
        _hasMore = projects.length >= _limit;
        if (_hasMore) {
          _currentPage++;
        }
        _statusRequest = StatusRequest.success;
        update();
        debugPrint('✅ Total projects: ${_projects.length}');
      },
    );
  }
  Future<String?> _getCompanyId() async {
    try {
      final authService = AuthService();
      // جلب companyId من AuthService في كل مرة
      final savedCompanyId = await authService.getCompanyId();
      if (savedCompanyId != null && savedCompanyId.isNotEmpty) {
        debugPrint('✅ Got companyId from AuthService: $savedCompanyId');
        return savedCompanyId;
      }
      // محاولة جلب companyId من بيانات employee
      final userId = await authService.getUserId();
      if (userId != null && userId.isNotEmpty) {
        debugPrint(
          '🔵 Getting companyId from employee data for userId: $userId',
        );
        try {
          final teamRepository = TeamRepository();
          final employeeResult = await teamRepository.getEmployeeById(userId);
          String? companyIdFromEmployee;
          employeeResult.fold(
            (error) {
              debugPrint('⚠️ Could not get employee data: $error');
            },
            (employee) {
              if (employee.companyId != null) {
                final companyIdStr = employee.companyId!['_id']?.toString();
                if (companyIdStr != null && companyIdStr.isNotEmpty) {
                  debugPrint(
                    '✅ Got companyId from employee data: $companyIdStr',
                  );
                  authService.saveCompanyId(companyIdStr);
                  companyIdFromEmployee = companyIdStr;
                }
              }
            },
          );
          if (companyIdFromEmployee != null) {
            return companyIdFromEmployee;
          }
        } catch (e) {
          debugPrint('⚠️ Error getting employee data: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not get companyId: $e');
    }
    debugPrint('🔴 CompanyId not found. User must login again.');
    return null;
  }
  @override
  void selectFilter(String filter) {
    debugPrint(
      '🔵 selectFilter called with: $filter (current: $_selectedFilter)',
    );
    if (_selectedFilter == filter) {
      debugPrint('🟡 Filter already selected, skipping');
      return;
    }
    _selectedFilter = filter;
    _currentPage = 1;
    _hasMore = true;
    loadProjects(refresh: true);
  }
  @override
  Future<void> refreshProjects() async {
    await loadProjects(refresh: true);
  }
  void _applyLocalFilter() {
    if (_selectedFilter == 'All') {
      return; // No filtering needed for 'All'
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
        return; // Unknown filter, show all
    }
    final filtered = _projects
        .where((project) => project.status.toLowerCase() == targetStatus)
        .toList();
    _projects = filtered;
    debugPrint(
      '🔍 Applied local filter "$_selectedFilter": ${_projects.length} projects match',
    );
  }
  @override
  List<ProjectModel> get filteredProjects {
    return _projects;
  }
}
