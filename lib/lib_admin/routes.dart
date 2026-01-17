import 'package:get/get.dart';
import 'core/class/middleware/middleware.dart';
import 'core/constant/routes.dart';
import 'core/bindings/page_bindings.dart';
import 'data/static/team_members_data.dart';
import 'view/screens/Tasks/tasks_Screen.dart';
import 'view/screens/auth/login.dart';
import 'view/screens/onBoarding.dart';
import 'view/screens/splash/splash_screen.dart';
import 'view/screens/projects/project_Screen.dart';
import 'view/screens/projects/project_details_screen.dart';
import 'view/screens/projects/project_comments_screen.dart';
import 'view/screens/team/team_screen.dart';
import 'view/screens/team/member_detail_screen.dart';
import 'view/screens/team/add_employee_screen.dart';
import 'view/screens/team/edit_employee_screen.dart';
import 'view/screens/Tasks/add_task_screen.dart';
import 'view/screens/Tasks/edit_task_screen.dart';
import 'view/screens/Tasks/task_detail_screen.dart';
import 'view/screens/Tasks/task_comments_screen.dart';
import 'view/screens/Tasks/request_delay_screen.dart';
import 'view/screens/projects/add_project_screen.dart';
import 'view/screens/projects/edit_project_screen.dart';
import 'view/screens/analytics/analytics_Screen.dart';
import 'view/screens/project dashboard/project_dashboard_screen.dart';
import 'view/screens/profile/profile_screen.dart';
import 'view/screens/assignments/assignments_screen.dart';
import 'view/screens/assignments/add_assignment_screen.dart';
import 'view/screens/assignments/reassign_assignment_screen.dart';
import 'view/screens/auth/add_client_screen.dart';
import 'view/screens/ai_assistance/ai_assistance_screen.dart';
import 'view/screens/delays/delays_screen.dart';
import 'data/Models/project_model.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(name: AppRoute.splash, page: () => const SplashScreen()),
  GetPage(
    name: AppRoute.onBoarding,
    page: () => const OnBoarding(),
    middlewares: [MyMiddleWare()],
  ),
  GetPage(name: AppRoute.login, page: () => const Login()),
  GetPage(
    name: AppRoute.team,
    page: () => const TeamScreen(),
    binding: TeamScreenBinding(),
  ),
  GetPage(
    name: AppRoute.tasks,
    page: () => const TasksScreen(),
    binding: TasksScreenBinding(),
  ),
  GetPage(
    name: AppRoute.projects,
    page: () => const ProjectScreen(),
    binding: ProjectsScreenBinding(),
  ),
  GetPage(
    name: AppRoute.analytics,
    page: () => const AnalyticsScreen(),
    binding: AnalyticsScreenBinding(),
  ),
  GetPage(
    name: AppRoute.projectDashboard,
    page: () => const ProjectDashboardScreen(),
    binding: ProjectDashboardScreenBinding(),
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
    binding: ProjectDetailsScreenBinding(),
  ),
  GetPage(
    name: AppRoute.projectComments,
    page: () {
      return const ProjectCommentsScreen();
    },
    binding: ProjectCommentsScreenBinding(),
  ),
  GetPage(
    name: AppRoute.profile,
    page: () => const ProfileScreen(),
    binding: ProfileScreenBinding(),
  ),
  GetPage(
    name: AppRoute.addEmployee,
    page: () => const AddEmployeeScreen(),
    binding: AddEmployeeScreenBinding(),
  ),
  GetPage(
    name: AppRoute.editEmployee,
    page: () {
      final employeeId = Get.arguments as String;
      return EditEmployeeScreen(employeeId: employeeId);
    },
    binding: EditEmployeeScreenBinding(),
  ),
  GetPage(
    name: AppRoute.addTask,
    page: () => const AddTaskScreen(),
    binding: AddTaskScreenBinding(),
  ),
  GetPage(
    name: AppRoute.editTask,
    page: () {
      final taskId = Get.arguments as String;
      return EditTaskScreen(taskId: taskId);
    },
    binding: EditTaskScreenBinding(),
  ),
  GetPage(
    name: AppRoute.taskDetail,
    page: () {
      return const TaskDetailScreen();
    },
    binding: TaskDetailScreenBinding(),
  ),
  GetPage(
    name: AppRoute.taskComments,
    page: () {
      return const TaskCommentsScreen();
    },
    binding: TaskCommentsScreenBinding(),
  ),
  GetPage(
    name: AppRoute.requestDelay,
    page: () {
      return const RequestDelayScreen();
    },
    binding: RequestDelayScreenBinding(),
  ),
  GetPage(
    name: AppRoute.addProject,
    page: () => const AddProjectScreen(),
    binding: AddProjectScreenBinding(),
  ),
  GetPage(
    name: AppRoute.editProject,
    page: () {
      final projectId = Get.arguments as String;
      return EditProjectScreen(projectId: projectId);
    },
    binding: EditProjectScreenBinding(),
  ),
  GetPage(
    name: AppRoute.assignments,
    page: () => const AssignmentsScreen(),
    binding: AssignmentsScreenBinding(),
  ),
  GetPage(
    name: AppRoute.addAssignment,
    page: () => const AddAssignmentScreen(),
    binding: AddAssignmentScreenBinding(),
  ),
  GetPage(
    name: AppRoute.reassignAssignment,
    page: () => const ReassignAssignmentScreen(),
    binding: ReassignAssignmentScreenBinding(),
  ),
  GetPage(
    name: AppRoute.addClient,
    page: () => const AddClientScreen(),
    binding: AddClientScreenBinding(),
  ),
  GetPage(
    name: AppRoute.aiAssistance,
    page: () => const AiAssistanceScreen(),
    binding: AiAssistanceScreenBinding(),
  ),
  GetPage(
    name: AppRoute.delays,
    page: () => const DelaysScreen(),
    binding: DelaysScreenBinding(),
  ),
];
