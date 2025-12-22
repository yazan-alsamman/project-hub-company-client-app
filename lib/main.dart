import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_admin/core/constant/routes.dart';
import 'package:project_hub/core/services/services.dart';
import 'package:project_hub/lib_admin/routes.dart';
import 'package:project_hub/lib_admin/controller/auth/login_controller.dart';
import 'package:project_hub/lib_admin/controller/auth/onBoarding_controller.dart';
import 'package:project_hub/lib_client/view/screens/tasks_page.dart';
import 'package:project_hub/lib_client/view/screens/comments_page.dart';
import 'package:project_hub/lib_client/view/screens/analytics/analytics_screen.dart';
import 'package:project_hub/lib_client/view/screens/settings/settings.dart';
import 'package:project_hub/lib_client/view/screens/profile/profile_screen.dart';
import 'package:project_hub/lib_client/view/screens/projects/projects_screen.dart';
import 'package:project_hub/lib_client/view/screens/projects/project_details_screen.dart';
import 'package:project_hub/lib_client/controller/theme_controller.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();

  // Initialize only essential controllers at app start
  Get.put(LoginControllerImpl(), permanent: true);
  Get.put(OnBoardingControllerImp(), permanent: true);
  // Other controllers will be initialized after successful login based on role

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
          initialRoute: AppRoute.splash,
          getPages: [
            // Admin app routes
            ...routes ?? [],
            // Client app routes
            GetPage(name: '/client/tasks-page', page: () => const TasksPage()),
            GetPage(
              name: '/client/comments-page',
              page: () => const CommentsPage(),
            ),
            GetPage(
              name: '/client/analytics',
              page: () => const AnalyticsScreen(),
            ),
            GetPage(
              name: '/client/settings',
              page: () => const SettingsScreen(),
            ),
            GetPage(name: '/client/profile', page: () => const ProfileScreen()),
            GetPage(
              name: '/client/projects',
              page: () => const ProjectsScreen(),
            ),
            GetPage(
              name: '/client/project-details',
              page: () => const ProjectDetailsScreen(),
            ),
          ],
        );
      },
    );
  }
}
