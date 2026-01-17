import 'package:flutter/material.dart';
import '../../../controller/common/customDrawer_controller.dart';
import 'package:get/get.dart';
import '../../../controller/project/project_dashboard_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/project_dashboard_card.dart';
import '../../widgets/common/sort_dropdown.dart';
class ProjectDashboardScreen extends StatelessWidget {
  const ProjectDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<ProjectDashboardControllerImp>()) {
      Get.put(ProjectDashboardControllerImp());
    }
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
            final controller = Get.isRegistered<ProjectDashboardControllerImp>()
                ? Get.find<ProjectDashboardControllerImp>()
                : Get.put(ProjectDashboardControllerImp());
            await controller.loadProjects(refresh: true);
          },
          color: AppColor.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              color: AppColor.backgroundColor,
              child: GetBuilder<ProjectDashboardControllerImp>(
                init: Get.isRegistered<ProjectDashboardControllerImp>()
                    ? Get.find<ProjectDashboardControllerImp>()
                    : Get.put(ProjectDashboardControllerImp()),
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
