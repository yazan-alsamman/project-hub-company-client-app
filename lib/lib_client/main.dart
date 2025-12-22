import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/core/constant/routes.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';
import 'package:project_hub/core/services/services.dart';
import 'package:project_hub/lib_client/controller/theme_controller.dart';
import 'package:project_hub/lib_client/controller/auth_controller.dart';
import 'package:project_hub/lib_client/view/screens/tasks_page.dart';
import 'package:project_hub/lib_client/view/screens/comments_page.dart';
import 'package:project_hub/lib_client/view/screens/analytics/analytics_screen.dart';
import 'package:project_hub/lib_client/view/screens/settings/settings.dart';
import 'package:project_hub/lib_client/view/screens/profile/profile_screen.dart';
import 'package:project_hub/lib_client/view/screens/projects/projects_screen.dart';
import 'package:project_hub/lib_client/view/screens/projects/project_details_screen.dart';
import 'package:project_hub/lib_client/controller/common/analytics_controller.dart';
import 'package:project_hub/lib_client/controller/common/settings_controller.dart';
import 'package:project_hub/lib_client/controller/common/custom_drawer_controller.dart';
import 'package:project_hub/lib_client/controller/project/projects_controller.dart';
import 'package:project_hub/lib_client/controller/common/filter_button_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialServices();

  Get.put(AuthController());
  Get.put(AnalyticsControllerImp(), );
  Get.put(SettingsControllerImp());
  Get.put(CustomDrawerControllerImp());
  Get.put(ProjectsControllerImp(),permanent: true);
  Get.put(FilterButtonController());

  final authController = Get.find<AuthController>();
  authController.login('Fadi29el', 'Fadi@123');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize theme controller
    Get.put(ThemeController());

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'ProjectHub',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            fontFamily: 'Arial',
            scaffoldBackgroundColor: AppColor.backgroundColor,
            colorScheme: ColorScheme.light(
              primary: AppColor.primaryColor,
              secondary: AppColor.secondaryColor,
              surface: AppColor.cardBackgroundColor,
              onSurface: AppColor.textColor,
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            fontFamily: 'Arial',
            scaffoldBackgroundColor: AppColor.darkBackgroundColor,
            colorScheme: ColorScheme.dark(
              primary: AppColor.primaryColor,
              secondary: AppColor.secondaryColor,
              surface: AppColor.darkCardBackgroundColor,
              onSurface: AppColor.darkTextColor,
            ),
          ),
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: AppRoute.tasksPage,
          getPages: [
            GetPage(name: AppRoute.tasksPage, page: () => const TasksPage()),
            GetPage(
              name: AppRoute.commentsPage,
              page: () => const CommentsPage(),
            ),
            GetPage(
              name: AppRoute.analytics,
              page: () => const AnalyticsScreen(),
            ),
            GetPage(
              name: AppRoute.settings,
              page: () => const SettingsScreen(),
            ),
            GetPage(name: AppRoute.profile, page: () => const ProfileScreen()),
            GetPage(
              name: AppRoute.projects,
              page: () => const ProjectsScreen(),
            ),
            GetPage(
              name: AppRoute.projectDetails,
              page: () => const ProjectDetailsScreen(),
            ),
          ],
        );
      },
    );
  }
}
