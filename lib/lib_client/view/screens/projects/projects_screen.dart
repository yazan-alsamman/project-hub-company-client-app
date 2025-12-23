import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/controller/common/custom_drawer_controller.dart';
import 'package:project_hub/lib_client/controller/common/filter_button_controller.dart';
import 'package:project_hub/lib_client/core/class/statusrequest.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';
import 'package:project_hub/lib_client/core/constant/responsive.dart';
import 'package:project_hub/lib_client/controller/project/projects_controller.dart';
import 'package:project_hub/lib_client/view/widgets/custom_app_bar.dart';
import 'package:project_hub/lib_client/view/widgets/common/custom_drawer.dart';
import 'package:project_hub/lib_client/view/widgets/common/filter_button.dart';
import 'package:project_hub/lib_client/view/widgets/common/header.dart';
import 'package:project_hub/lib_client/view/widgets/common/project_card.dart';
import 'package:project_hub/lib_client/core/constant/routes.dart';

class _ErrorBanner extends StatefulWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});
  @override
  State<_ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<_ErrorBanner> {
  bool _isVisible = true;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: AppColor.errorColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColor.errorColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(color: AppColor.errorColor, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onRetry();
              setState(() {
                _isVisible = false;
              });
            },
            child: const Text('Retry'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColor.errorColor,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _isVisible = false;
              });
            },
          ),
        ],
      ),
    );
  }
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<ProjectsControllerImp>()) {
      Get.put(ProjectsControllerImp());
    }
    if (!Get.isRegistered<FilterButtonController>()) {
      Get.put(FilterButtonController());
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
        child: GetBuilder<ProjectsControllerImp>(
          builder: (controller) {
            if (controller.statusRequest == StatusRequest.loading &&
                controller.projects.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.primaryColor),
              );
            }

            final hasError =
                !controller.isLoading &&
                (controller.statusRequest == StatusRequest.serverFailure ||
                    controller.statusRequest == StatusRequest.offlineFailure ||
                    controller.statusRequest == StatusRequest.serverException ||
                    controller.statusRequest == StatusRequest.timeoutException);

            if (hasError && controller.projects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColor.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load projects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => controller.refreshProjects(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.refreshProjects(),
              color: AppColor.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      color: AppColor.backgroundColor,
                      child: Padding(
                        padding: Responsive.padding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Header(
                              title: "Projects",
                              subtitle: "Manage and organize all your projects",
                              haveButton: false,
                            ),
                            SizedBox(
                              height: Responsive.spacing(context, mobile: 30),
                            ),
                            GetBuilder<FilterButtonController>(
                              builder: (filterController) =>
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.filter_alt_outlined,
                                          color: AppColor.textSecondaryColor,
                                          size: Responsive.iconSize(
                                            context,
                                            mobile: 20,
                                          ),
                                        ),
                                        SizedBox(
                                          width: Responsive.spacing(
                                            context,
                                            mobile: 12,
                                          ),
                                        ),
                                        FilterButton(
                                          text: "All",
                                          isSelected:
                                              filterController.selectedFilter ==
                                              'All',
                                          onPressed: () {
                                            filterController.selectFilter(
                                              'All',
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          width: Responsive.spacing(
                                            context,
                                            mobile: 8,
                                          ),
                                        ),
                                        FilterButton(
                                          text: "Active",
                                          isSelected:
                                              filterController.selectedFilter ==
                                              'Active',
                                          onPressed: () {
                                            filterController.selectFilter(
                                              'Active',
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          width: Responsive.spacing(
                                            context,
                                            mobile: 8,
                                          ),
                                        ),
                                        FilterButton(
                                          text: "Completed",
                                          isSelected:
                                              filterController.selectedFilter ==
                                              'Completed',
                                          onPressed: () {
                                            filterController.selectFilter(
                                              'Completed',
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          width: Responsive.spacing(
                                            context,
                                            mobile: 8,
                                          ),
                                        ),
                                        FilterButton(
                                          text: "Planned",
                                          isSelected:
                                              filterController.selectedFilter ==
                                              'Planned',
                                          onPressed: () {
                                            filterController.selectFilter(
                                              'Planned',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hasError && controller.projects.isNotEmpty)
                      _ErrorBanner(
                        message:
                            'Failed to refresh projects. Showing cached data.',
                        onRetry: () => controller.refreshProjects(),
                      ),
                    Padding(
                      padding: Responsive.padding(context),
                      child:
                          controller.projects.isEmpty &&
                              !controller.isLoading &&
                              controller.statusRequest == StatusRequest.success
                          ? Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: Responsive.spacing(
                                      context,
                                      mobile: 50,
                                    ),
                                  ),
                                  Icon(
                                    Icons.folder_open_outlined,
                                    size: Responsive.size(context, mobile: 64),
                                    color: AppColor.textSecondaryColor
                                        .withValues(alpha: 0.5),
                                  ),
                                  SizedBox(
                                    height: Responsive.spacing(
                                      context,
                                      mobile: 16,
                                    ),
                                  ),
                                  Text(
                                    'No projects found',
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(
                                        context,
                                        mobile: 18,
                                      ),
                                      color: AppColor.textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.spacing(
                                      context,
                                      mobile: 8,
                                    ),
                                  ),
                                  Text(
                                    'Try selecting a different filter',
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(
                                        context,
                                        mobile: 14,
                                      ),
                                      color: AppColor.textSecondaryColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.projects.length,
                              itemBuilder: (context, index) {
                                final project = controller.projects[index];
                                return ProjectCard(
                                  title: project.title,
                                  company: project.company,
                                  description: project.description,
                                  progress: project.progress,
                                  startDate: project.startDate,
                                  endDate: project.endDate,
                                  teamMembers: project.teamMembers,
                                  status: project.status,
                                  onTap: () {
                                    Get.toNamed(
                                      AppRoute.projectDetails,
                                      arguments: project,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
