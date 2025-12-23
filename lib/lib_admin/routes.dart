import 'package:get/get.dart';
import 'core/class/middleware/middleware.dart';
import 'core/constant/routes.dart';
import 'data/static/team_members_data.dart';
import 'view/screens/Tasks/tasks_Screen.dart';
import 'view/screens/auth/login.dart';
import 'view/screens/onBoarding.dart';
import 'view/screens/splash/splash_screen.dart';
import 'view/screens/projects/project_Screen.dart';
import 'view/screens/projects/project_details_screen.dart';
import 'view/screens/team/team_screen.dart';
import 'view/screens/team/member_detail_screen.dart';
import 'view/screens/team/add_employee_screen.dart';
import 'view/screens/team/edit_employee_screen.dart';
import 'view/screens/Tasks/add_task_screen.dart';
import 'view/screens/Tasks/edit_task_screen.dart';
import 'view/screens/projects/add_project_screen.dart';
import 'view/screens/projects/edit_project_screen.dart';
import 'view/screens/analytics/analytics_Screen.dart';
import 'view/screens/project dashboard/project_dashboard_screen.dart';
import 'view/screens/profile/profile_screen.dart';
import 'view/screens/assignments/assignments_screen.dart';
import 'view/screens/assignments/add_assignment_screen.dart';
import 'view/screens/auth/add_client_screen.dart';
import 'view/screens/ai_assistance/ai_assistance_screen.dart';
import 'data/Models/project_model.dart';
List<GetPage<dynamic>>? routes = [
  GetPage(
    name: AppRoute.splash,
    page: () => const SplashScreen(),
  ),
  GetPage(
    name: AppRoute.onBoarding,
    page: () => const OnBoarding(),
    middlewares: [MyMiddleWare()],
  ),
  GetPage(name: AppRoute.login, page: () => const Login()),
  GetPage(name: AppRoute.team, page: () => const TeamScreen()),
  GetPage(name: AppRoute.tasks, page: () => const TasksScreen()),
  GetPage(name: AppRoute.projects, page: () => const ProjectScreen()),
  GetPage(name: AppRoute.analytics, page: () => const AnalyticsScreen()),
  GetPage(
    name: AppRoute.projectDashboard,
    page: () => const ProjectDashboardScreen(),
  ),
  GetPage(
    name: AppRoute.memberDetail,
    page: () {
      final member = Get.arguments as TeamMember;
      return MemberDetailScreen(member: member);
    },
  ),
  GetPage(
    name: AppRoute.projectDetails,
    page: () {
      final project = Get.arguments as ProjectModel;
      return ProjectDetailsScreen(project: project);
    },
  ),
  GetPage(name: AppRoute.profile, page: () => const ProfileScreen()),
  GetPage(name: AppRoute.addEmployee, page: () => const AddEmployeeScreen()),
  GetPage(
    name: AppRoute.editEmployee,
    page: () {
      final employeeId = Get.arguments as String;
      return EditEmployeeScreen(employeeId: employeeId);
    },
  ),
  GetPage(name: AppRoute.addTask, page: () => const AddTaskScreen()),
  GetPage(
    name: AppRoute.editTask,
    page: () {
      final taskId = Get.arguments as String;
      return EditTaskScreen(taskId: taskId);
    },
  ),
  GetPage(name: AppRoute.addProject, page: () => const AddProjectScreen()),
  GetPage(
    name: AppRoute.editProject,
    page: () {
      final projectId = Get.arguments as String;
      return EditProjectScreen(projectId: projectId);
    },
  ),
  GetPage(name: AppRoute.assignments, page: () => const AssignmentsScreen()),
  GetPage(
    name: AppRoute.addAssignment,
    page: () => const AddAssignmentScreen(),
  ),
  GetPage(name: AppRoute.addClient, page: () => const AddClientScreen()),
  GetPage(name: AppRoute.aiAssistance, page: () => const AiAssistanceScreen()),
];
