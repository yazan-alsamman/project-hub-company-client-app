import 'package:get/get.dart';
import '../../controller/ai_assistance/ai_assistance_controller.dart';
import '../../controller/assignment/add_assignment_controller.dart';
import '../../controller/assignment/assignments_controller.dart';
import '../../controller/assignment/assignments_tabs_controller.dart';
import '../../controller/auth/add_client_controller.dart';
import '../../controller/common/analytics_controller.dart';
import '../../controller/common/customAppBar_controller.dart';
import '../../controller/common/customDrawer_controller.dart';
import '../../controller/common/filter_button_controller.dart';
import '../../controller/common/profile_controller.dart';
import '../../controller/delays/delays_controller.dart';
import '../../controller/employee/add_employee_controller.dart';
import '../../controller/employee/team_controller.dart';
import '../../controller/project/add_project_controller.dart';
import '../../controller/project/project_dashboard_controller.dart';
import '../../controller/project/projects_controller.dart';
import '../../controller/task/add_task_controller.dart';
import '../../controller/task/tasks_controller.dart';

/// Bindings for Team Screen
class TeamScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    if (!Get.isRegistered<TeamControllerImp>()) {
      Get.put(TeamControllerImp());
    }
  }
}

/// Bindings for Tasks Screen
class TasksScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    if (!Get.isRegistered<TasksControllerImp>()) {
      Get.put(TasksControllerImp());
    }
    if (!Get.isRegistered<FilterButtonController>()) {
      Get.put(FilterButtonController());
    }
  }
}

/// Bindings for Projects Screen
class ProjectsScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    if (!Get.isRegistered<ProjectsControllerImp>()) {
      Get.put(ProjectsControllerImp());
    }
    if (!Get.isRegistered<FilterButtonController>()) {
      Get.put(FilterButtonController());
    }
  }
}

/// Bindings for Analytics Screen
class AnalyticsScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    if (!Get.isRegistered<AnalyticsControllerImp>()) {
      Get.put(AnalyticsControllerImp());
    }
  }
}

/// Bindings for Project Dashboard Screen
class ProjectDashboardScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    if (!Get.isRegistered<ProjectDashboardControllerImp>()) {
      Get.put(ProjectDashboardControllerImp());
    }
  }
}

/// Bindings for Add Employee Screen
class AddEmployeeScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddEmployeeControllerImp>()) {
      Get.put(AddEmployeeControllerImp());
    }
  }
}

/// Bindings for Edit Employee Screen
/// Note: EditEmployeeControllerImp requires employeeId, so it's initialized in the screen's initState
class EditEmployeeScreenBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is initialized in EditEmployeeScreen with employeeId from route arguments
  }
}

/// Bindings for Add Task Screen
class AddTaskScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddTaskControllerImp>()) {
      Get.put(AddTaskControllerImp());
    }
  }
}

/// Bindings for Edit Task Screen
/// Note: EditTaskControllerImp requires taskId, so it's initialized in the screen's initState
class EditTaskScreenBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is initialized in EditTaskScreen with taskId from route arguments
  }
}

/// Bindings for Task Detail Screen
/// Note: TaskDetailController requires taskId and task, so it's initialized in the screen's build method
class TaskDetailScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    // TaskDetailController is initialized in TaskDetailScreen with task from Get.arguments
  }
}

/// Bindings for Task Comments Screen
/// Note: TaskDetailController requires taskId and task, so it's initialized in the screen
class TaskCommentsScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    // TaskDetailController is initialized in TaskCommentsScreen with task from Get.arguments
  }
}

/// Bindings for Request Delay Screen
/// Note: RequestDelayController requires taskId and task, so it's initialized in the screen
class RequestDelayScreenBinding extends Bindings {
  @override
  void dependencies() {
    // RequestDelayController is initialized in RequestDelayScreen with task from Get.arguments
  }
}

/// Bindings for Add Project Screen
class AddProjectScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddProjectControllerImp>()) {
      Get.put(AddProjectControllerImp());
    }
  }
}

/// Bindings for Edit Project Screen
/// Note: EditProjectControllerImp requires projectId, so it's initialized in the screen's initState
class EditProjectScreenBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is initialized in EditProjectScreen with projectId from route arguments
  }
}

/// Bindings for Project Details Screen
class ProjectDetailsScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
  }
}

/// Bindings for Project Comments Screen
/// Note: ProjectCommentsController requires projectId and project, so it's initialized in the screen
class ProjectCommentsScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    // ProjectCommentsController is initialized in ProjectCommentsScreen with project from Get.arguments
  }
}

/// Bindings for Profile Screen
class ProfileScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
  }
}

/// Bindings for Assignments Screen
class AssignmentsScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    if (!Get.isRegistered<AssignmentsControllerImp>()) {
      Get.put(AssignmentsControllerImp());
    }
    if (!Get.isRegistered<EmployeeScheduleController>()) {
      Get.put(EmployeeScheduleController());
    }
    if (!Get.isRegistered<TaskAssignmentsController>()) {
      Get.put(TaskAssignmentsController());
    }
  }
}

/// Bindings for Add Assignment Screen
class AddAssignmentScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddAssignmentControllerImp>()) {
      Get.put(AddAssignmentControllerImp());
    }
  }
}

/// Bindings for Reassign Assignment Screen
/// Note: ReassignAssignmentController requires AssignmentModel, so it's initialized in the screen's build method
class ReassignAssignmentScreenBinding extends Bindings {
  @override
  void dependencies() {
    // ReassignAssignmentController is initialized in ReassignAssignmentScreen with assignment from Get.arguments
  }
}

/// Bindings for Add Client Screen
class AddClientScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddClientControllerImp>()) {
      Get.put(AddClientControllerImp());
    }
  }
}

/// Bindings for AI Assistance Screen
class AiAssistanceScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<AiAssistanceControllerImp>()) {
      Get.put(AiAssistanceControllerImp());
    }
  }
}

/// Bindings for Delays Screen
class DelaysScreenBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<CustomappbarControllerImp>()) {
      Get.put(CustomappbarControllerImp());
    }
    if (!Get.isRegistered<DelaysController>()) {
      Get.put(DelaysController());
    }
  }
}

