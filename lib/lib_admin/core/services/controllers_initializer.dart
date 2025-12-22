import 'package:get/get.dart';
import '../../controller/auth/onBoarding_controller.dart';
import '../../controller/employee/team_controller.dart';
import '../../controller/task/tasks_controller.dart';
import '../../controller/common/settings_controller.dart';
import '../../controller/common/filter_button_controller.dart';
import '../../controller/common/customAppBar_controller.dart';
import '../../controller/common/customDrawer_controller.dart';
import '../../controller/project/projects_controller.dart';
import '../../controller/common/analytics_controller.dart';
import '../../controller/project/project_dashboard_controller.dart';
import '../../controller/employee/add_employee_controller.dart';
import '../../controller/project/add_project_controller.dart';
import '../../controller/auth/add_client_controller.dart';

class ControllersInitializer {
  /// Initialize all controllers after successful login
  static void initializeControllers() {
    // Check if controllers are already initialized to avoid duplicates
    if (!Get.isRegistered<OnBoardingControllerImp>()) {
      Get.put(OnBoardingControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<TeamControllerImp>()) {
      Get.put(TeamControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<TasksControllerImp>()) {
      Get.put(TasksControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<SettingsControllerImp>()) {
      Get.put(SettingsControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<FilterButtonController>()) {
      Get.put(FilterButtonController(), permanent: true);
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<ProjectsControllerImp>()) {
      Get.put(ProjectsControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<AnalyticsControllerImp>()) {
      Get.put(AnalyticsControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<ProjectDashboardControllerImp>()) {
      Get.put(ProjectDashboardControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<AddEmployeeControllerImp>()) {
      Get.put(AddEmployeeControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<AddProjectControllerImp>()) {
      Get.put(AddProjectControllerImp(), permanent: true);
    }
    if (!Get.isRegistered<AddClientControllerImp>()) {
      Get.put(AddClientControllerImp(), permanent: true);
    }
  }
}
