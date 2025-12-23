import 'package:flutter/material.dart';
import '../../../controller/common/customDrawer_controller.dart';
import 'package:get/get.dart';
import '../../../controller/project/project_dashboard_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../../core/constant/routes.dart';
import '../../../data/Models/project_model.dart';
import '../../../data/repository/projects_repository.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/project_dashboard_card.dart';
import '../../widgets/common/project_dashboard_information_card.dart';
import '../../widgets/common/sort_dropdown.dart';
class ProjectDashboardScreen extends StatelessWidget {
  const ProjectDashboardScreen({super.key});
  void _showProjectOptions(BuildContext context, ProjectModel project) {
    final projectsRepository = ProjectsRepository();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Project'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(
                    AppRoute.editProject,
                    arguments: project.id,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Project'),
                onTap: () {
                  Navigator.pop(context);
                  // Share functionality can be added here
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Project',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Delete Project'),
                      content: Text('Are you sure you want to delete "${project.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Get.back();
                            try {
                              final result = await projectsRepository.deleteProject(project.id);
                              result.fold(
                                (error) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to delete project',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                },
                                (success) {
                                  Get.snackbar(
                                    'Success',
                                    'Project deleted successfully',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                  final controller = Get.find<ProjectDashboardControllerImp>();
                                  controller.loadProjects(refresh: true);
                                  controller.loadStats();
                                },
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'An error occurred while deleting project',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final CustomDrawerControllerImp customDrawerController =
        Get.find<CustomDrawerControllerImp>();
    return Scaffold(
      drawer: CustomDrawer(
        onItemTap: (item) {
          customDrawerController.onMenuItemTap(item);
        },
      ),
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final controller = Get.find<ProjectDashboardControllerImp>();
            await controller.loadProjects(refresh: true);
            // Stats will be calculated automatically from projects
          },
          color: AppColor.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              color: AppColor.backgroundColor,
              child: GetBuilder<ProjectDashboardControllerImp>(
                builder: (controller) => Padding(
                  padding: Responsive.padding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Projects",
                              style: TextStyle(
                                fontSize: Responsive.fontSize(
                                  context,
                                  mobile: 24,
                                ),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          SortDropdown(
                            selectedOption: controller.selectedSortOption,
                            onChanged: (option) {
                              controller.changeSortOption(option);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 20)),
                      Responsive.isTablet(context) ||
                              Responsive.isDesktop(context)
                          ? GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: Responsive.columnCount(context),
                              crossAxisSpacing: Responsive.spacing(
                                context,
                                mobile: 16,
                              ),
                              mainAxisSpacing: Responsive.spacing(
                                context,
                                mobile: 16,
                              ),
                              childAspectRatio: 2.5,
                              children: [
                                ProjectDashboardCard(
                                  title: "Active Projects",
                                  value: controller.isLoadingStats
                                      ? "..."
                                      : "${controller.activeProjectsCount}",
                                  icon: Icons.folder,
                                  backgroundColor: const Color(0xFF3B82F6),
                                  iconBackgroundColor: const Color(0xFF60A5FA),
                                ),
                                ProjectDashboardCard(
                                  title: "Total Tasks",
                                  value: controller.isLoadingStats
                                      ? "..."
                                      : "${controller.totalTasksCount}",
                                  icon: Icons.check_box,
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  iconBackgroundColor: const Color(0xFFA78BFA),
                                ),
                                ProjectDashboardCard(
                                  title: "Team Members",
                                  value: controller.isLoadingStats
                                      ? "..."
                                      : "${controller.teamMembersCount}",
                                  icon: Icons.people,
                                  backgroundColor: const Color(0xFF10B981),
                                  iconBackgroundColor: const Color(0xFF34D399),
                                ),
                                ProjectDashboardCard(
                                  title: "Completion Rate",
                                  value: controller.isLoadingStats
                                      ? "..."
                                      : "${controller.completionRate.toStringAsFixed(0)}%",
                                  icon: Icons.emoji_events,
                                  backgroundColor: const Color(0xFFF59E0B),
                                  iconBackgroundColor: const Color(0xFFFBBF24),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: Responsive.containerHeight(
                                    context,
                                    mobile: 120,
                                  ),
                                  child: ProjectDashboardCard(
                                    title: "Active Projects",
                                    value: controller.isLoadingStats
                                        ? "..."
                                        : "${controller.activeProjectsCount}",
                                    icon: Icons.folder,
                                    backgroundColor: const Color(0xFF3B82F6),
                                    iconBackgroundColor: const Color(
                                      0xFF60A5FA,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.spacing(
                                    context,
                                    mobile: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: Responsive.containerHeight(
                                    context,
                                    mobile: 120,
                                  ),
                                  child: ProjectDashboardCard(
                                    title: "Total Tasks",
                                    value: controller.isLoadingStats
                                        ? "..."
                                        : "${controller.totalTasksCount}",
                                    icon: Icons.check_box,
                                    backgroundColor: const Color(0xFF8B5CF6),
                                    iconBackgroundColor: const Color(
                                      0xFFA78BFA,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.spacing(
                                    context,
                                    mobile: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: Responsive.containerHeight(
                                    context,
                                    mobile: 120,
                                  ),
                                  child: ProjectDashboardCard(
                                    title: "Team Members",
                                    value: controller.isLoadingStats
                                        ? "..."
                                        : "${controller.teamMembersCount}",
                                    icon: Icons.people,
                                    backgroundColor: const Color(0xFF10B981),
                                    iconBackgroundColor: const Color(
                                      0xFF34D399,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.spacing(
                                    context,
                                    mobile: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: Responsive.containerHeight(
                                    context,
                                    mobile: 120,
                                  ),
                                  child: ProjectDashboardCard(
                                    title: "Completion Rate",
                                    value: controller.isLoadingStats
                                        ? "..."
                                        : "${controller.completionRate.toStringAsFixed(0)}%",
                                    icon: Icons.emoji_events,
                                    backgroundColor: const Color(0xFFF59E0B),
                                    iconBackgroundColor: const Color(
                                      0xFFFBBF24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: Responsive.spacing(context, mobile: 24)),
                      Text(
                        "Project Details",
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 20),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                      if (controller.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (controller.projects.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'No projects found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      else
                        ...controller.projects.map(
                          (project) => ProjectDashboardInformationCard(
                            project: project,
                            onTap: () {
                              Get.toNamed(
                                AppRoute.projectDetails,
                                arguments: project,
                              );
                            },
                            onMoreTap: () {
                              _showProjectOptions(context, project);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
