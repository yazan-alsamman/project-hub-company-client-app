import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/common/customDrawer_controller.dart';
import '../../../controller/delays/delays_controller.dart';
import '../../../core/class/statusrequest.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/main_button.dart';

class DelaysScreen extends StatefulWidget {
  const DelaysScreen({super.key});

  @override
  State<DelaysScreen> createState() => _DelaysScreenState();
}

class _DelaysScreenState extends State<DelaysScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int? _previousTabCount;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeTabController(int tabCount) {
    if (_tabController == null || _previousTabCount != tabCount) {
      _tabController?.dispose();
      _tabController = TabController(length: tabCount, vsync: this);
      _previousTabCount = tabCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
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
        child: FutureBuilder<String?>(
          future: AuthService().getUserRole(),
          builder: (context, snapshot) {
            final role = snapshot.data?.toLowerCase() ?? '';
            final isPm = role == 'pm' || role == 'project manager';
            final tabCount = isPm ? 3 : 4;

            _initializeTabController(tabCount);

            return Column(
              children: [
                Container(
                  color: AppColor.backgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColor.primaryColor,
                    unselectedLabelColor: AppColor.textSecondaryColor,
                    indicatorColor: AppColor.primaryColor,
                    isScrollable: true,
                    tabs: isPm
                        ? const [
                            Tab(text: 'Project Delay Status'),
                            Tab(text: 'Project Task Delays'),
                            Tab(text: 'View Requested Delays'),
                          ]
                        : const [
                            Tab(text: 'Delay Summary'),
                            Tab(text: 'All Projects Delay Status'),
                            Tab(text: 'Project Delay Status'),
                            Tab(text: 'Project Task Delays'),
                          ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: isPm
                        ? [
                            _buildProjectDelayStatusTab(context),
                            _buildProjectTaskDelaysTab(context),
                            _buildViewRequestedDelaysTab(context),
                          ]
                        : [
                            _buildDelaySummaryTab(context),
                            _buildAllProjectsDelayStatusTab(context),
                            _buildProjectDelayStatusTab(context),
                            _buildProjectTaskDelaysTab(context),
                          ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDelaySummaryTab(BuildContext context) {
    return GetBuilder<DelaysController>(
      init: Get.put(DelaysController()),
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () => controller.loadDelaySummary(),
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
                          title: "Delay Summary",
                          subtitle: "Overview of project delays",
                          haveButton: false,
                        ),
                        SizedBox(
                          height: Responsive.spacing(context, mobile: 30),
                        ),
                        MainButton(
                          onPressed: () {
                            controller.loadDelaySummary();
                          },
                          text: "Load Summary",
                          icon: Icons.refresh,
                          width: double.infinity,
                          height: Responsive.size(context, mobile: 50),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildDelaySummaryContent(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDelaySummaryContent(
    BuildContext context,
    DelaysController controller,
  ) {
    if (controller.isLoadingSummary && controller.delaySummary == null) {
      return Padding(
        padding: Responsive.padding(context),
        child: const Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }

    if (controller.summaryStatusRequest != StatusRequest.success &&
        controller.delaySummary == null &&
        !controller.isLoadingSummary) {
      return Padding(
        padding: Responsive.padding(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColor.errorColor),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Text(
                'Failed to load delay summary',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 8)),
              TextButton(
                onPressed: () => controller.loadDelaySummary(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.delaySummary == null) {
      return Padding(
        padding: Responsive.padding(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Text(
                'No delay summary available',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 8)),
              Text(
                'Click "Load Summary" to view delay statistics',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final summary = controller.delaySummary!;
    return Padding(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary Statistics',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 20),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          _buildSummaryCard(
            context,
            'Total Projects',
            summary['totalProjects']?.toString() ?? '0',
            Icons.folder_outlined,
            AppColor.primaryColor,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildSummaryCard(
            context,
            'Projects On Track',
            summary['projectsOnTrack']?.toString() ?? '0',
            Icons.check_circle_outline,
            AppColor.successColor,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildSummaryCard(
            context,
            'Projects Within Safe Delay',
            summary['projectsWithinSafeDelay']?.toString() ?? '0',
            Icons.warning_outlined,
            Colors.orange,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildSummaryCard(
            context,
            'Projects Exceeded Safe Delay',
            summary['projectsExceededSafeDelay']?.toString() ?? '0',
            Icons.error_outline,
            AppColor.errorColor,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildSummaryCard(
            context,
            'Total Delay Days',
            summary['totalDelayDays']?.toString() ?? '0',
            Icons.calendar_today,
            AppColor.textColor,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildSummaryCard(
            context,
            'Average Delay Per Project',
            summary['avgDelayPerProject']?.toString() ?? '0',
            Icons.trending_up,
            AppColor.primaryColor,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildSummaryCard(
            context,
            'Health Score',
            '${summary['healthScore']?.toString() ?? '0'}%',
            Icons.favorite,
            AppColor.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.spacing(context, mobile: 12)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 18),
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllProjectsDelayStatusTab(BuildContext context) {
    return GetBuilder<DelaysController>(
      init: Get.isRegistered<DelaysController>()
          ? Get.find<DelaysController>()
          : Get.put(DelaysController()),
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () => controller.loadAllProjectsDelayStatus(),
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
                          title: "All Projects Delay Status",
                          subtitle: "View delay status for all projects",
                          haveButton: false,
                        ),
                        SizedBox(
                          height: Responsive.spacing(context, mobile: 30),
                        ),
                        MainButton(
                          onPressed: () {
                            controller.loadAllProjectsDelayStatus();
                          },
                          text: "Load Projects",
                          icon: Icons.refresh,
                          width: double.infinity,
                          height: Responsive.size(context, mobile: 50),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildAllProjectsDelayStatusContent(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllProjectsDelayStatusContent(
    BuildContext context,
    DelaysController controller,
  ) {
    if (controller.isLoadingAllProjects &&
        controller.allProjectsDelayStatus.isEmpty) {
      return Padding(
        padding: Responsive.padding(context),
        child: const Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }

    if (controller.allProjectsStatusRequest != StatusRequest.success &&
        controller.allProjectsDelayStatus.isEmpty &&
        !controller.isLoadingAllProjects) {
      return Padding(
        padding: Responsive.padding(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColor.errorColor),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Text(
                'Failed to load projects delay status',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 8)),
              TextButton(
                onPressed: () => controller.loadAllProjectsDelayStatus(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.allProjectsDelayStatus.isEmpty) {
      return Padding(
        padding: Responsive.padding(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Text(
                'No projects found',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 8)),
              Text(
                'Click "Load Projects" to view delay status',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projects (${controller.allProjectsDelayStatus.length})',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 20),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          ...controller.allProjectsDelayStatus.map((projectData) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: Responsive.spacing(context, mobile: 12),
              ),
              child: _buildProjectDelayStatusCard(context, projectData),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProjectDelayStatusCard(
    BuildContext context,
    dynamic projectData,
  ) {
    Map<String, dynamic>? projectMap;
    if (projectData is Map<String, dynamic>) {
      if (projectData['project'] != null) {
        projectMap = projectData['project'] as Map<String, dynamic>?;
      } else {
        projectMap = projectData;
      }
    }

    if (projectMap == null) {
      return Container(
        padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.borderColor),
        ),
        child: Text(
          'Invalid project data',
          style: TextStyle(color: AppColor.textColor),
        ),
      );
    }

    final project = projectMap;
    final code = project['code']?.toString() ?? 'N/A';
    final status = project['status']?.toString() ?? 'N/A';
    final companyId = project['companyId'];
    final companyName = companyId != null && companyId is Map
        ? companyId['name']?.toString() ?? 'N/A'
        : 'N/A';

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 16),
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 4)),
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        color: AppColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.spacing(context, mobile: 12),
                  vertical: Responsive.spacing(context, mobile: 6),
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDelayStatusTab(BuildContext context) {
    return GetBuilder<DelaysController>(
      init: Get.isRegistered<DelaysController>()
          ? Get.find<DelaysController>()
          : Get.put(DelaysController()),
      builder: (controller) {
        return SingleChildScrollView(
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
                        title: "Project Delay Status",
                        subtitle: "View delay status for a specific project",
                        haveButton: false,
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 30)),
                      _buildProjectDropdown(
                        context,
                        controller,
                        onProjectChanged: () {
                          if (controller.selectedProjectId != null) {
                            controller.loadProjectDelayStatus();
                          }
                        },
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 20)),
                      MainButton(
                        onPressed: controller.selectedProjectId != null
                            ? () {
                                controller.loadProjectDelayStatus();
                              }
                            : null,
                        text: "Load Status",
                        icon: Icons.visibility,
                        width: double.infinity,
                        height: Responsive.size(context, mobile: 50),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.selectedProjectId != null)
                _buildProjectDelayStatusContent(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectDropdown(
    BuildContext context,
    DelaysController controller, {
    VoidCallback? onProjectChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(context, mobile: 16),
        vertical: Responsive.spacing(context, mobile: 4),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: controller.isLoadingProjects
            ? Container(
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.spacing(context, mobile: 16),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, mobile: 12)),
                    Text(
                      'Loading projects...',
                      style: TextStyle(
                        color: AppColor.textSecondaryColor,
                        fontSize: Responsive.fontSize(context, mobile: 14),
                      ),
                    ),
                  ],
                ),
              )
            : DropdownButton<String>(
                value: controller.selectedProjectId,
                hint: Text(
                  'Select a project',
                  style: TextStyle(
                    color: AppColor.textSecondaryColor,
                    fontSize: Responsive.fontSize(context, mobile: 16),
                  ),
                ),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColor.textColor),
                items: controller.projects.map((project) {
                  return DropdownMenuItem<String>(
                    value: project.id,
                    child: Text(
                      project.title,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 16),
                        color: AppColor.textColor,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  controller.selectProject(value);
                  if (onProjectChanged != null) {
                    onProjectChanged();
                  }
                },
              ),
      ),
    );
  }

  Widget _buildProjectDelayStatusContent(
    BuildContext context,
    DelaysController controller,
  ) {
    if (controller.isLoadingProjectDelay &&
        controller.projectDelayStatus == null) {
      return Padding(
        padding: Responsive.padding(context),
        child: const Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }

    if (controller.projectDelayStatus == null) {
      return Padding(
        padding: Responsive.padding(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Text(
                'No delay status available',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 8)),
              Text(
                'Select a project and click "Load Status"',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final statusData = controller.projectDelayStatus!;
    return Padding(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectDelayStatusHeader(context, statusData),
          SizedBox(height: Responsive.spacing(context, mobile: 24)),
          _buildProjectInfoCard(context, statusData),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildDelayMetricsCard(context, statusData),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildTaskMetricsCard(context, statusData),
        ],
      ),
    );
  }

  Widget _buildProjectTaskDelaysTab(BuildContext context) {
    return GetBuilder<DelaysController>(
      init: Get.isRegistered<DelaysController>()
          ? Get.find<DelaysController>()
          : Get.put(DelaysController()),
      builder: (controller) {
        return SingleChildScrollView(
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
                        title: "Project Task Delays",
                        subtitle: "View task delays for a specific project",
                        haveButton: false,
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 30)),
                      _buildProjectDropdown(
                        context,
                        controller,
                        onProjectChanged: () {
                          if (controller.selectedProjectId != null) {
                            controller.loadProjectTaskDelays();
                          }
                        },
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 20)),
                      MainButton(
                        onPressed: controller.selectedProjectId != null
                            ? () {
                                controller.loadProjectTaskDelays();
                              }
                            : null,
                        text: "Load Task Delays",
                        icon: Icons.visibility,
                        width: double.infinity,
                        height: Responsive.size(context, mobile: 50),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.selectedProjectId != null)
                _buildProjectTaskDelaysContent(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectTaskDelaysContent(
    BuildContext context,
    DelaysController controller,
  ) {
    if (controller.isLoadingProjectTaskDelays &&
        controller.projectTaskDelays.isEmpty) {
      return Padding(
        padding: Responsive.padding(context),
        child: const Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }

    if (controller.projectTaskDelays.isEmpty) {
      return Padding(
        padding: Responsive.padding(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Text(
                'No task delays found',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 8)),
              Text(
                'Select a project and click "Load Task Delays"',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Delays (${controller.projectTaskDelays.length})',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 20),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          ...controller.projectTaskDelays.map((taskData) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: Responsive.spacing(context, mobile: 12),
              ),
              child: _buildTaskDelayCard(context, taskData, controller),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTaskDelayCard(
    BuildContext context,
    dynamic taskData,
    DelaysController controller,
  ) {
    Map<String, dynamic>? taskMap;
    String? delayRequestId;

    if (taskData is Map<String, dynamic>) {
      delayRequestId =
          taskData['_id']?.toString() ??
          taskData['id']?.toString() ??
          taskData['delayRequestId']?.toString();

      if (taskData['task'] != null) {
        taskMap = taskData['task'] as Map<String, dynamic>?;
      } else {
        taskMap = taskData;
      }
    }

    if (taskMap == null) {
      return Container(
        padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.borderColor),
        ),
        child: Text(
          'Invalid task data',
          style: TextStyle(color: AppColor.textColor),
        ),
      );
    }

    final task = taskMap;
    final taskName =
        task['taskName']?.toString() ?? task['title']?.toString() ?? 'N/A';
    final delayDays = task['delayDays']?.toString() ?? '0';

    return FutureBuilder<String?>(
      future: AuthService().getUserRole(),
      builder: (context, roleSnapshot) {
        final userRole = roleSnapshot.data?.toLowerCase() ?? '';
        final isPm = userRole == 'pm' || userRole == 'project manager';
        final hasDelayRequestId =
            delayRequestId != null && delayRequestId.isNotEmpty;

        return Container(
          padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      taskName,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 16),
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.spacing(context, mobile: 12),
                      vertical: Responsive.spacing(context, mobile: 6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$delayDays days',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 12),
                        fontWeight: FontWeight.bold,
                        color: AppColor.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (isPm && hasDelayRequestId) ...[
                SizedBox(height: Responsive.spacing(context, mobile: 12)),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAcceptDelayDialog(
                            context,
                            controller,
                            delayRequestId!,
                          );
                        },
                        icon: Icon(
                          Icons.check_circle,
                          size: Responsive.iconSize(context, mobile: 16),
                        ),
                        label: Text(
                          'Accept Delay',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, mobile: 12),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.successColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.spacing(context, mobile: 8),
                            horizontal: Responsive.spacing(context, mobile: 8),
                          ),
                          minimumSize: Size(
                            0,
                            Responsive.size(context, mobile: 36),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, mobile: 8)),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showRejectDelayDialog(
                            context,
                            controller,
                            delayRequestId!,
                          );
                        },
                        icon: Icon(
                          Icons.cancel,
                          size: Responsive.iconSize(context, mobile: 16),
                        ),
                        label: Text(
                          'Reject Delay',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, mobile: 12),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.errorColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.spacing(context, mobile: 8),
                            horizontal: Responsive.spacing(context, mobile: 8),
                          ),
                          minimumSize: Size(
                            0,
                            Responsive.size(context, mobile: 36),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAcceptDelayDialog(
    BuildContext context,
    DelaysController controller,
    String delayRequestId,
  ) {
    final reviewNoteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Accept Delay Request',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter a review note:',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 12)),
              TextField(
                controller: reviewNoteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g., Approved. Please ensure the new deadline is met.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColor.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                var reviewNote = reviewNoteController.text.trim();
                if (reviewNote.isEmpty) {
                  reviewNote =
                      'Approved. Please ensure the new deadline is met.';
                }
                Navigator.of(dialogContext).pop();
                controller.acceptDelayRequest(
                  delayRequestId: delayRequestId,
                  reviewNote: reviewNote,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.successColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDelayDialog(
    BuildContext context,
    DelaysController controller,
    String delayRequestId,
  ) {
    final reviewNoteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Reject Delay Request',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter a review note:',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 12)),
              TextField(
                controller: reviewNoteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g., The original deadline must be maintained due to project constraints.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColor.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                var reviewNote = reviewNoteController.text.trim();
                if (reviewNote.isEmpty) {
                  reviewNote =
                      'The original deadline must be maintained due to project constraints.';
                }
                Navigator.of(dialogContext).pop();
                controller.rejectDelayRequest(
                  delayRequestId: delayRequestId,
                  reviewNote: reviewNote,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectDelayStatusHeader(
    BuildContext context,
    Map<String, dynamic> statusData,
  ) {
    final project = statusData['project'] as Map<String, dynamic>?;
    final delayStatus = statusData['delayStatus']?.toString() ?? 'unknown';
    final projectCode = project?['code']?.toString() ?? 'N/A';
    final projectName = project?['name']?.toString() ?? projectCode;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (delayStatus.toLowerCase()) {
      case 'on_track':
        statusColor = AppColor.successColor;
        statusIcon = Icons.check_circle;
        statusText = 'On Track';
        break;
      case 'at_risk':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'At Risk';
        break;
      case 'delayed':
        statusColor = AppColor.errorColor;
        statusIcon = Icons.error;
        statusText = 'Delayed';
        break;
      default:
        statusColor = AppColor.textSecondaryColor;
        statusIcon = Icons.help_outline;
        statusText = delayStatus;
    }

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.spacing(context, mobile: 12)),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 32),
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 20),
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 4)),
                Text(
                  'Code: $projectCode',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.spacing(context, mobile: 16),
              vertical: Responsive.spacing(context, mobile: 8),
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 14),
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard(
    BuildContext context,
    Map<String, dynamic> statusData,
  ) {
    final project = statusData['project'] as Map<String, dynamic>?;
    if (project == null) return const SizedBox.shrink();

    final companyId = project['companyId'] as Map<String, dynamic>?;
    final clientId = project['clientId'] as Map<String, dynamic>?;
    final companyName = companyId?['name']?.toString() ?? 'N/A';
    final clientName =
        clientId?['username']?.toString() ??
        clientId?['email']?.toString() ??
        'N/A';
    final status = project['status']?.toString() ?? 'N/A';
    final startAt = project['startAt']?.toString();
    final estimatedEndAt = project['estimatedEndAt']?.toString();
    final safeDelay = project['safeDelay']?.toString() ?? '0';

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColor.primaryColor, size: 24),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Text(
                'Project Information',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          _buildInfoRow(context, 'Company', companyName, Icons.business),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildInfoRow(context, 'Client', clientName, Icons.person),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildInfoRow(context, 'Status', status.toUpperCase(), Icons.flag),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildInfoRow(
            context,
            'Start Date',
            _formatDate(startAt) ?? 'N/A',
            Icons.calendar_today,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildInfoRow(
            context,
            'Estimated End Date',
            _formatDate(estimatedEndAt) ?? 'N/A',
            Icons.event,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildInfoRow(
            context,
            'Safe Delay',
            '$safeDelay days',
            Icons.schedule,
          ),
        ],
      ),
    );
  }

  Widget _buildDelayMetricsCard(
    BuildContext context,
    Map<String, dynamic> statusData,
  ) {
    final delayMetrics = statusData['delayMetrics'] as Map<String, dynamic>?;
    if (delayMetrics == null) return const SizedBox.shrink();

    final totalDelayDays = delayMetrics['totalDelayDays']?.toString() ?? '0';
    final maxDelayDays = delayMetrics['maxDelayDays']?.toString() ?? '0';
    final avgDelayDays = delayMetrics['avgDelayDays']?.toString() ?? '0';
    final remainingSafeDelay =
        delayMetrics['remainingSafeDelay']?.toString() ?? '0';
    final exceededBy = delayMetrics['exceededBy']?.toString() ?? '0';

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: AppColor.primaryColor, size: 24),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Text(
                'Delay Metrics',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Total Delay',
                  '$totalDelayDays days',
                  Icons.timer_off,
                  AppColor.textColor,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Max Delay',
                  '$maxDelayDays days',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Avg Delay',
                  '$avgDelayDays days',
                  Icons.trending_flat,
                  AppColor.primaryColor,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Remaining Safe',
                  '$remainingSafeDelay days',
                  Icons.schedule,
                  AppColor.successColor,
                ),
              ),
            ],
          ),
          if (int.tryParse(exceededBy) != null &&
              int.parse(exceededBy) > 0) ...[
            SizedBox(height: Responsive.spacing(context, mobile: 16)),
            _buildInfoRow(
              context,
              'Exceeded By',
              '$exceededBy days',
              Icons.warning,
              AppColor.errorColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskMetricsCard(
    BuildContext context,
    Map<String, dynamic> statusData,
  ) {
    final taskMetrics = statusData['taskMetrics'] as Map<String, dynamic>?;
    if (taskMetrics == null) return const SizedBox.shrink();

    final totalTasks = taskMetrics['totalTasks']?.toString() ?? '0';
    final completedTasks = taskMetrics['completedTasks']?.toString() ?? '0';
    final delayedTasks = taskMetrics['delayedTasks']?.toString() ?? '0';
    final overdueTasks = taskMetrics['overdueTasks']?.toString() ?? '0';
    final projectedAdditionalDelay =
        taskMetrics['projectedAdditionalDelay']?.toString() ?? '0';

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: AppColor.primaryColor, size: 24),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Text(
                'Task Metrics',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Total Tasks',
                  totalTasks,
                  Icons.assignment,
                  AppColor.primaryColor,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Completed',
                  completedTasks,
                  Icons.check_circle,
                  AppColor.successColor,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Delayed',
                  delayedTasks,
                  Icons.timer_off,
                  Colors.orange,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Overdue',
                  overdueTasks,
                  Icons.error,
                  AppColor.errorColor,
                ),
              ),
            ],
          ),
          if (int.tryParse(projectedAdditionalDelay) != null &&
              int.parse(projectedAdditionalDelay) > 0) ...[
            SizedBox(height: Responsive.spacing(context, mobile: 16)),
            _buildInfoRow(
              context,
              'Projected Additional Delay',
              '$projectedAdditionalDelay days',
              Icons.trending_up,
              AppColor.errorColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? iconColor,
  ]) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? AppColor.textSecondaryColor, size: 20),
        SizedBox(width: Responsive.spacing(context, mobile: 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 12),
                  color: AppColor.textSecondaryColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColor.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    color: AppColor.textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 20),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String? _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColor.successColor;
      case 'completed':
        return AppColor.successColor;
      case 'pending':
        return Colors.orange;
      default:
        return AppColor.textSecondaryColor;
    }
  }

  Widget _buildViewRequestedDelaysTab(BuildContext context) {
    return GetBuilder<DelaysController>(
      init: Get.isRegistered<DelaysController>()
          ? Get.find<DelaysController>()
          : Get.put(DelaysController()),
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () => controller.loadRequestedDelays(),
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
                          title: "View Requested Delays",
                          subtitle: "View all delay requests",
                          haveButton: false,
                        ),
                        SizedBox(
                          height: Responsive.spacing(context, mobile: 30),
                        ),
                        MainButton(
                          onPressed: () {
                            controller.loadRequestedDelays();
                          },
                          text: "Load Requested Delays",
                          icon: Icons.refresh,
                          width: double.infinity,
                          height: Responsive.size(context, mobile: 50),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildRequestedDelaysContent(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestedDelaysContent(
    BuildContext context,
    DelaysController controller,
  ) {
    if (controller.isLoadingRequestedDelays &&
        controller.requestedDelays.isEmpty) {
      return Padding(
        padding: Responsive.padding(context),
        child: const Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }

    if (controller.requestedDelays.isEmpty) {
      return Padding(
        padding: Responsive.padding(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pending_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Text(
                'No delay requests found',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 18),
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 8)),
              Text(
                'Click "Load Requested Delays" to fetch delay requests',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.requestedDelaysPagination != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: Responsive.spacing(context, mobile: 16),
              ),
              child: Text(
                'Total: ${controller.requestedDelaysPagination!['total'] ?? 0} delay requests',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ),
          ...controller.requestedDelays.map((delayRequest) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: Responsive.spacing(context, mobile: 12),
              ),
              child: _buildRequestedDelayCard(
                context,
                delayRequest,
                controller,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRequestedDelayCard(
    BuildContext context,
    dynamic delayRequest,
    DelaysController controller,
  ) {
    if (delayRequest is! Map<String, dynamic>) {
      return Container(
        padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.borderColor),
        ),
        child: Text(
          'Invalid delay request data',
          style: TextStyle(color: AppColor.textColor),
        ),
      );
    }

    final taskId = delayRequest['taskId'] as Map<String, dynamic>?;
    final task = delayRequest['task'] as Map<String, dynamic>?;

    final taskData = taskId ?? task;

    final projectId = taskData?['projectId'] as Map<String, dynamic>?;
    final projectName = projectId?['name']?.toString() ?? 'N/A';
    final projectCode = projectId?['code']?.toString() ?? '';
    final projectInfo = projectCode.isNotEmpty
        ? '$projectName ($projectCode)'
        : projectName;

    final taskName =
        taskData?['taskName']?.toString() ??
        taskData?['title']?.toString() ??
        'N/A';

    final status = delayRequest['status']?.toString() ?? 'pending';
    final delayRequestId =
        delayRequest['_id']?.toString() ?? delayRequest['id']?.toString() ?? '';
    final requestedDate = delayRequest['createdAt']?.toString() ?? 'N/A';
    final newDueDate =
        delayRequest['requestedDueDate']?.toString() ??
        delayRequest['newDueDate']?.toString() ??
        'N/A';
    final originalDueDate =
        delayRequest['originalDueDate']?.toString() ?? 'N/A';
    final reason = delayRequest['reason']?.toString() ?? 'No reason provided';
    final requestedBy = delayRequest['requestedBy'] as Map<String, dynamic>?;
    final requestedByName =
        requestedBy?['name']?.toString() ??
        requestedBy?['username']?.toString() ??
        'Unknown';
    final isPending = status.toLowerCase() == 'pending';

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskName,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 18),
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 4)),
                    Text(
                      projectInfo,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        color: AppColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.spacing(context, mobile: 12),
                  vertical: Responsive.spacing(context, mobile: 6),
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(status), width: 1),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildInfoRow(
            context,
            'Project',
            projectInfo,
            Icons.business_outlined,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          _buildInfoRow(
            context,
            'Requested by',
            requestedByName,
            Icons.person_outline,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          _buildInfoRow(
            context,
            'Requested date',
            _formatDate(requestedDate) ?? 'N/A',
            Icons.calendar_today_outlined,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          _buildInfoRow(
            context,
            'Original due date',
            _formatDate(originalDueDate) ?? 'N/A',
            Icons.event_busy_outlined,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          _buildInfoRow(
            context,
            'New due date',
            _formatDate(newDueDate) ?? 'N/A',
            Icons.event_outlined,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          _buildInfoRow(context, 'Reason', reason, Icons.info_outline),
          if (isPending && delayRequestId.isNotEmpty) ...[
            SizedBox(height: Responsive.spacing(context, mobile: 16)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAcceptDelayDialog(
                        context,
                        controller,
                        delayRequestId,
                      );
                    },
                    icon: Icon(
                      Icons.check_circle,
                      size: Responsive.iconSize(context, mobile: 16),
                    ),
                    label: Text(
                      'Accept Delay',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 12),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.successColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.spacing(context, mobile: 8),
                        horizontal: Responsive.spacing(context, mobile: 8),
                      ),
                      minimumSize: Size(
                        0,
                        Responsive.size(context, mobile: 36),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, mobile: 8)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showRejectDelayDialog(
                        context,
                        controller,
                        delayRequestId,
                      );
                    },
                    icon: Icon(
                      Icons.cancel,
                      size: Responsive.iconSize(context, mobile: 16),
                    ),
                    label: Text(
                      'Reject Delay',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 12),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.errorColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.spacing(context, mobile: 8),
                        horizontal: Responsive.spacing(context, mobile: 8),
                      ),
                      minimumSize: Size(
                        0,
                        Responsive.size(context, mobile: 36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
