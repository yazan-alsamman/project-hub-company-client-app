import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';
import 'package:project_hub/lib_client/core/constant/responsive.dart';
import 'package:project_hub/lib_client/controller/project/project_analytics_controller.dart';
import 'package:project_hub/lib_client/data/Models/project_model.dart';
import 'package:project_hub/lib_client/view/widgets/custom_app_bar.dart';
import 'package:project_hub/lib_client/view/widgets/common/custom_drawer.dart';

class ProjectAnalyticsScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectAnalyticsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProjectAnalyticsController>()) {
      Get.put(ProjectAnalyticsController());
    }
    final controller = Get.find<ProjectAnalyticsController>();
    controller.setProject(project);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: const CustomAppBar(showBackButton: false),
      drawer: Responsive.isMobile(context) ? const CustomDrawer() : null,
      body: Row(
        children: [
          if (!Responsive.isMobile(context)) const CustomDrawer(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.spacing(context, mobile: 16),
                  vertical: Responsive.spacing(context, mobile: 24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),

                    // Overview Card
                    _buildOverviewCard(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),

                    // Task Status Chart
                    _buildTaskStatusChart(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),

                    // Priority Distribution
                    _buildPriorityDistribution(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),

                    // Role Distribution
                    _buildRoleDistribution(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),

                    // Timeline Info
                    _buildTimelineInfo(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),

                    // Top Assignees
                    _buildTopAssignees(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 32)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ProjectAnalyticsController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 32),
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 8)),
        Text(
          'Detailed project analytics and insights',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 16),
            color: AppColor.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    ProjectAnalyticsController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Overview',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricBox(
                context,
                'Progress',
                '${(controller.overallProgress.value * 100).round()}%',
                AppColor.primaryColor,
                Icons.trending_up,
              ),
              _buildMetricBox(
                context,
                'Days Left',
                '${controller.daysRemaining.value}',
                AppColor.inProgressColor,
                Icons.calendar_today,
              ),
              _buildMetricBox(
                context,
                'Status',
                controller.projectStatus.value.toUpperCase(),
                _getStatusColor(controller.projectStatus.value),
                Icons.info_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Responsive.spacing(context, mobile: 8),
        ),
        padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 12),
          ),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: Responsive.iconSize(context, mobile: 24),
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 8)),
            Text(
              value,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 18),
                fontWeight: FontWeight.bold,
                color: AppColor.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 4)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 12),
                color: AppColor.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusChart(
    BuildContext context,
    ProjectAnalyticsController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Status Distribution',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          Row(
            children: [
              SizedBox(
                width: Responsive.size(context, mobile: 160),
                height: Responsive.size(context, mobile: 160),
                child: CustomPaint(
                  painter: TaskStatusDonutPainter(
                    completed: controller.completedPercent.value,
                    inProgress: controller.inProgressPercent.value,
                    pending: controller.pendingPercent.value,
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 32)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusLegend(
                    context,
                    AppColor.completedColor,
                    'Completed',
                    '${(controller.completedPercent.value * 100).round()}%',
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 12)),
                  _buildStatusLegend(
                    context,
                    AppColor.inProgressColor,
                    'In Progress',
                    '${(controller.inProgressPercent.value * 100).round()}%',
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 12)),
                  _buildStatusLegend(
                    context,
                    AppColor.pendingColor,
                    'Pending',
                    '${(controller.pendingPercent.value * 100).round()}%',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegend(
    BuildContext context,
    Color color,
    String label,
    String percentage,
  ) {
    return Row(
      children: [
        Container(
          width: Responsive.size(context, mobile: 12),
          height: Responsive.size(context, mobile: 12),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: Responsive.spacing(context, mobile: 8)),
        Text(
          '$label • $percentage',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 14),
            color: AppColor.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDistribution(
    BuildContext context,
    ProjectAnalyticsController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks by Priority',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          Obx(() {
            if (controller.priorityDistribution.isEmpty) {
              return Center(
                child: Text(
                  'No tasks',
                  style: TextStyle(color: AppColor.textSecondaryColor),
                ),
              );
            }

            return Column(
              children: controller.priorityDistribution.entries.map((entry) {
                final priority = entry.key;
                final count = entry.value;
                final percentage = (count / controller.totalTasks.value) * 100;
                final color = _getPriorityColor(priority);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: Responsive.spacing(context, mobile: 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            priority,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(
                                context,
                                mobile: 14,
                              ),
                              color: AppColor.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$count tasks (${percentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(
                                context,
                                mobile: 12,
                              ),
                              color: AppColor.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 8)),
                      Container(
                        width: double.infinity,
                        height: Responsive.size(context, mobile: 8),
                        decoration: BoxDecoration(
                          color: AppColor.backgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRoleDistribution(
    BuildContext context,
    ProjectAnalyticsController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks by Role',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          Row(
            children: [
              Expanded(
                child: _buildRoleCard(
                  context,
                  'Backend',
                  controller.backendTasks.value,
                  AppColor.primaryColor,
                  Icons.code,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 16)),
              Expanded(
                child: _buildRoleCard(
                  context,
                  'Frontend',
                  controller.frontendTasks.value,
                  AppColor.secondaryColor,
                  Icons.palette,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String role,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 12),
        ),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: Responsive.iconSize(context, mobile: 28),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          Text(
            '$count',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 24),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 4)),
          Text(
            role,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 14),
              color: AppColor.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineInfo(
    BuildContext context,
    ProjectAnalyticsController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Timeline',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          _buildTimelineItem(
            context,
            'Start Date',
            controller.startDate.value,
            Icons.flag_outlined,
            AppColor.primaryColor,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildTimelineItem(
            context,
            'End Date',
            controller.endDate.value,
            Icons.flag_outlined,
            AppColor.inProgressColor,
          ),
          if (controller.safeDelay.value > 0) ...[
            SizedBox(height: Responsive.spacing(context, mobile: 16)),
            _buildTimelineItem(
              context,
              'Safe Delay',
              '${controller.safeDelay.value} days',
              Icons.info_outline,
              controller.safeDelay.value > 0
                  ? AppColor.warningColor
                  : AppColor.completedColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.spacing(context, mobile: 12)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(
            icon,
            color: color,
            size: Responsive.iconSize(context, mobile: 20),
          ),
        ),
        SizedBox(width: Responsive.spacing(context, mobile: 16)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 12),
                color: AppColor.textSecondaryColor,
              ),
            ),
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
      ],
    );
  }

  Widget _buildTopAssignees(
    BuildContext context,
    ProjectAnalyticsController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 20)),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Workload',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20)),
          Obx(() {
            if (controller.assignees.isEmpty) {
              return Center(
                child: Text(
                  'No assignments yet',
                  style: TextStyle(color: AppColor.textSecondaryColor),
                ),
              );
            }

            return Column(
              children: controller.assignees.take(5).map((assignee) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: Responsive.spacing(context, mobile: 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            assignee.name,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(
                                context,
                                mobile: 14,
                              ),
                              color: AppColor.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${assignee.taskCount} tasks',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(
                                context,
                                mobile: 12,
                              ),
                              color: AppColor.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 8)),
                      Container(
                        width: double.infinity,
                        height: Responsive.size(context, mobile: 6),
                        decoration: BoxDecoration(
                          color: AppColor.backgroundColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: assignee.percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.primaryColor,
                                    AppColor.secondaryColor,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('critical') || p.contains('high')) {
      return const Color(0xFFEF4444);
    } else if (p.contains('medium high') || p.contains('medium-high')) {
      return const Color(0xFFF59E0B);
    } else if (p.contains('medium')) {
      return const Color(0xFFFBBF24);
    } else if (p.contains('low medium') || p.contains('low-medium')) {
      return const Color(0xFF84CC16);
    } else if (p.contains('low')) {
      return const Color(0xFF10B981);
    }
    return const Color(0xFF6B7280);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColor.completedColor;
      case 'active':
        return AppColor.inProgressColor;
      case 'planned':
        return AppColor.pendingColor;
      default:
        return AppColor.textSecondaryColor;
    }
  }
}

class TaskStatusDonutPainter extends CustomPainter {
  final double completed;
  final double inProgress;
  final double pending;

  TaskStatusDonutPainter({
    required this.completed,
    required this.inProgress,
    required this.pending,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final strokeWidth = 25.0;

    final completedPaint = Paint()
      ..color = AppColor.completedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inProgressPaint = Paint()
      ..color = AppColor.inProgressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final pendingPaint = Paint()
      ..color = AppColor.pendingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -3.14159 / 2;

    if (completed > 0) {
      final completedSweep = 2 * 3.14159 * completed;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        completedSweep,
        false,
        completedPaint,
      );
      startAngle += completedSweep;
    }

    if (inProgress > 0) {
      final inProgressSweep = 2 * 3.14159 * inProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        inProgressSweep,
        false,
        inProgressPaint,
      );
      startAngle += inProgressSweep;
    }

    if (pending > 0) {
      final pendingSweep = 2 * 3.14159 * pending;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        pendingSweep,
        false,
        pendingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is TaskStatusDonutPainter &&
        (oldDelegate.completed != completed ||
            oldDelegate.inProgress != inProgress ||
            oldDelegate.pending != pending);
  }
}
