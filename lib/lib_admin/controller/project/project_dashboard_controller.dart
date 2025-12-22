import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../data/Models/project_model.dart';
import '../../data/static/projects_data.dart';
import '../../view/widgets/common/sort_dropdown.dart';
abstract class ProjectDashboardController extends GetxController {
  List<ProjectModel> get projects;
  SortOption get selectedSortOption;
  void changeSortOption(SortOption option);
}
class ProjectDashboardControllerImp extends ProjectDashboardController {
  List<ProjectModel> _projects = [];
  SortOption _selectedSortOption = SortOption.deadline;
  @override
  List<ProjectModel> get projects => _projects;
  @override
  SortOption get selectedSortOption => _selectedSortOption;
  @override
  void onInit() {
    super.onInit();
    _loadProjects();
  }
  void _loadProjects() {
    _projects = ProjectsData.projects;
    print('Loaded ${_projects.length} projects');
    for (var project in _projects) {
      print('Project: ${project.title} - Status: ${project.status}');
    }
    _sortProjects();
  }
  @override
  void changeSortOption(SortOption option) {
    _selectedSortOption = option;
    _sortProjects();
    update();
  }
  void _sortProjects() {
    switch (_selectedSortOption) {
      case SortOption.deadline:
        _projects.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      case SortOption.projectStatus:
        _projects.sort((a, b) => a.status.compareTo(b.status));
        break;
    }
  }
}
