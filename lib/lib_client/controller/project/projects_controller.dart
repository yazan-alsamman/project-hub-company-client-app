import 'package:get/get.dart';
import 'package:project_hub/lib_client/core/class/statusrequest.dart';
import 'package:project_hub/lib_client/core/services/auth_service.dart';
import 'package:project_hub/lib_client/data/Models/project_model.dart';
import 'package:project_hub/lib_client/data/repository/project_repository.dart';

abstract class ProjectsController extends GetxController {
  List<ProjectModel> get projects;
  String get selectedFilter;
  StatusRequest get statusRequest;
  bool get isLoading;
  void selectFilter(String filter);
  Future<void> loadProjects({bool refresh = false});
  Future<void> refreshProjects();
}

class ProjectsControllerImp extends ProjectsController {
  final ProjectRepository _repository = ProjectRepository();
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

    _isLoading = true;
    if (refresh || _projects.isEmpty) {
      _statusRequest = StatusRequest.loading;
    }
    update();

    try {
      final authService = AuthService();
      final clientId = await authService.getUserId();

      if (clientId == null || clientId.isEmpty) {
        _isLoading = false;
        _statusRequest = StatusRequest.serverFailure;
        update();
        return;
      }

      final result = await _repository.getProjectsByClientId(clientId);

      _isLoading = false;

      result.fold(
        (error) {
          _statusRequest = StatusRequest.serverFailure;
          if (refresh) {
            // Keep existing projects on refresh error
          } else {
            _projects = [];
          }
          update();
        },
        (projects) {

          // Apply filter if not "All"
          if (_selectedFilter != 'All') {
            _projects = _filterProjects(projects);
          } else {
            _projects = projects;
          }

          _statusRequest = StatusRequest.success;
          update();
        },
      );
    } catch (e) {
      _isLoading = false;
      _statusRequest = StatusRequest.serverException;
      if (!refresh) {
        _projects = [];
      }
      update();
    }
  }

  List<ProjectModel> _filterProjects(List<ProjectModel> projects) {
    switch (_selectedFilter.toLowerCase()) {
      case 'active':
        return projects
            .where((p) => p.status.toLowerCase() == 'active')
            .toList();
      case 'completed':
        return projects
            .where((p) => p.status.toLowerCase() == 'completed')
            .toList();
      case 'planned':
        return projects
            .where((p) => p.status.toLowerCase() == 'planned')
            .toList();
      default:
        return projects;
    }
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
}

