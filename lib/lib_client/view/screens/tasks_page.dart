import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';
import 'package:project_hub/lib_client/core/constant/responsive.dart';
import 'package:project_hub/lib_client/core/constant/routes.dart';
import 'package:project_hub/lib_client/controller/tasks_page_controller.dart';
import 'package:project_hub/lib_client/controller/custom_app_bar_controller.dart';
import 'package:project_hub/lib_client/controller/theme_controller.dart';
import 'package:project_hub/lib_client/data/Models/task_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/common/custom_drawer.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ClientCustomappbarControllerImp>()) {
      Get.put(ClientCustomappbarControllerImp());
    }
    Get.put(TasksPageController());
    Get.put(ThemeController());

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return Scaffold(
          backgroundColor: AppColor.backgroundColor,
          appBar: const CustomAppBar(showBackButton: false),
          drawer: Responsive.isMobile(context) ? const CustomDrawer() : null,
          body: Row(
            children: [
              if (!Responsive.isMobile(context)) const CustomDrawer(),
              Expanded(
                child: GetBuilder<TasksPageController>(
                  builder: (controller) {
                    return Obx(() {
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
                            _buildTasksHeader(context),
                            SizedBox(
                              height: Responsive.spacing(context, mobile: 24),
                            ),
                            _buildProjectSelector(context, controller),
                            SizedBox(
                              height: Responsive.spacing(context, mobile: 16),
                            ),
                            _buildStatusFilters(context, controller),
                            SizedBox(
                              height: Responsive.spacing(context, mobile: 24),
                            ),
                            _buildProgressBar(context, controller),
                            SizedBox(
                              height: Responsive.spacing(context, mobile: 24),
                            ),
                            _buildDonutChartSection(context, controller),
                            SizedBox(
                              height: Responsive.spacing(context, mobile: 32),
                            ),
                            _buildTaskList(context, controller),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasks',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 32),
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 8)),
        Text(
          'Track and manage all your project tasks',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 16),
            color: AppColor.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectSelector(
    BuildContext context,
    TasksPageController controller,
  ) {
    return Obx(() {
      if (controller.projects.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.spacing(context, mobile: 16),
          vertical: Responsive.spacing(context, mobile: 12),
        ),
        decoration: BoxDecoration(
          color: AppColor.cardBackgroundColor,
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 12),
          ),
          border: Border.all(color: AppColor.borderColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.folder_outlined,
              color: AppColor.textSecondaryColor,
              size: Responsive.iconSize(context, mobile: 20),
            ),
            SizedBox(width: Responsive.spacing(context, mobile: 12)),
            Expanded(
              child: DropdownButton<String?>(
                value: controller.selectedProjectId.value ?? 'All',
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(
                  'All Projects',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    color: AppColor.textColor,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: 'All',
                    child: Text('All Projects'),
                  ),
                  ...controller.projects.map((project) {
                    return DropdownMenuItem<String>(
                      value: project.id,
                      child: Text(
                        project.title,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 14),
                          color: AppColor.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (String? projectId) {
                  controller.selectProject(projectId ?? 'All');
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusFilters(
    BuildContext context,
    TasksPageController controller,
  ) {
    return Row(
      children: [
        Icon(
          Icons.filter_list,
          color: AppColor.textSecondaryColor,
          size: Responsive.iconSize(context, mobile: 24),
        ),
        SizedBox(width: Responsive.spacing(context, mobile: 12)),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.statusFilters.map((status) {
                final isSelected = controller.selectedStatus.value == status;
                return Padding(
                  padding: EdgeInsets.only(
                    right: Responsive.spacing(context, mobile: 8),
                  ),
                  child: GestureDetector(
                    onTap: () => controller.selectStatus(status),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(context, mobile: 16),
                        vertical: Responsive.spacing(context, mobile: 8),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primaryColor
                            : AppColor.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          Responsive.borderRadius(context, mobile: 20),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 14),
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColor.darkTextColor
                              : AppColor.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    TasksPageController controller,
  ) {
    return Obx(() {
      final completionPercent = (controller.projectCompletionPercent.value * 100).round();
      final incompletePercent = 100 - completionPercent;

      return Container(
        padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
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
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Progress',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 14),
                fontWeight: FontWeight.w600,
                color: AppColor.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 12)),
            Container(
              height: Responsive.size(context, mobile: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Responsive.borderRadius(context, mobile: 16),
                ),
                color: AppColor.backgroundColor,
              ),
              child: Row(
                children: [
                  Flexible(
                    flex: completionPercent > 0 ? completionPercent : 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.completedColor, // Green
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            Responsive.borderRadius(context, mobile: 16),
                          ),
                          bottomLeft: Radius.circular(
                            Responsive.borderRadius(context, mobile: 16),
                          ),
                          topRight: incompletePercent == 0
                              ? Radius.circular(
                                  Responsive.borderRadius(context, mobile: 16),
                                )
                              : Radius.zero,
                          bottomRight: incompletePercent == 0
                              ? Radius.circular(
                                  Responsive.borderRadius(context, mobile: 16),
                                )
                              : Radius.zero,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$completionPercent%',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, mobile: 12),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  if (incompletePercent > 0)
                    Flexible(
                      flex: incompletePercent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.backgroundColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(
                              Responsive.borderRadius(context, mobile: 16),
                            ),
                            bottomRight: Radius.circular(
                              Responsive.borderRadius(context, mobile: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDonutChartSection(
    BuildContext context,
    TasksPageController controller,
  ) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(Responsive.spacing(context, mobile: 24)),
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
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: Responsive.size(context, mobile: 180),
              height: Responsive.size(context, mobile: 180),
              child: CustomPaint(
                size: Size(
                  Responsive.size(context, mobile: 180),
                  Responsive.size(context, mobile: 180),
                ),
                painter: DonutChartPainter(
                  completed: controller.completedPercent.value,
                  inProgress: controller.inProgressPercent.value,
                  pending: controller.pendingPercent.value,
                ),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, mobile: 32)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, AppColor.completedColor, 'Completed'),
                SizedBox(height: Responsive.spacing(context, mobile: 12)),
                _buildLegendItem(context, AppColor.inProgressColor, 'In Progress'),
                SizedBox(height: Responsive.spacing(context, mobile: 12)),
                _buildLegendItem(context, AppColor.pendingColor, 'Pending'),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: Responsive.size(context, mobile: 12),
          height: Responsive.size(context, mobile: 12),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: Responsive.spacing(context, mobile: 8)),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 14),
            color: AppColor.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context, TasksPageController controller) {
    if (controller.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.spacing(context, mobile: 32)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Text(
                controller.errorMessage.value.isNotEmpty
                    ? controller.errorMessage.value
                    : 'No tasks found',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 16),
                  color: AppColor.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (controller.errorMessage.value.isEmpty)
                SizedBox(height: Responsive.spacing(context, mobile: 8)),
              if (controller.errorMessage.value.isEmpty)
                Text(
                  'Tasks will appear here once they are assigned to your projects',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    color: AppColor.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: Responsive.spacing(context, mobile: 16),
          ),
          child: Text(
            '${controller.tasks.length} ${controller.tasks.length == 1 ? 'task' : 'tasks'}',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 14),
              color: AppColor.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...controller.tasks.map(
          (task) => Padding(
            padding: EdgeInsets.only(
              bottom: Responsive.spacing(context, mobile: 16),
            ),
            child: _buildTaskCard(context, task),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);

    return GestureDetector(
      onTap: () {
        if (task.id != null) {
          Get.toNamed(AppRoute.commentsPage, arguments: task.id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
        decoration: BoxDecoration(
          color: AppColor.cardBackgroundColor,
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 12),
          ),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, mobile: 8)),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 16),
                      fontWeight: FontWeight.w600,
                      color: AppColor.textColor,
                    ),
                  ),
                ),
                if (task.status != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.spacing(context, mobile: 8),
                      vertical: Responsive.spacing(context, mobile: 4),
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        Responsive.borderRadius(context, mobile: 8),
                      ),
                    ),
                    child: Text(
                      task.status!,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 10),
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 8)),
            Text(
              task.description,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 14),
                color: AppColor.textSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 12)),
            Row(
              children: [
                if (task.tag.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.spacing(context, mobile: 12),
                      vertical: Responsive.spacing(context, mobile: 6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.tagBackgroundColor,
                      borderRadius: BorderRadius.circular(
                        Responsive.borderRadius(context, mobile: 12),
                      ),
                    ),
                    child: Text(
                      task.tag,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 12),
                        color: AppColor.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (task.tag.isNotEmpty)
                  SizedBox(width: Responsive.spacing(context, mobile: 8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context, mobile: 12),
                    vertical: Responsive.spacing(context, mobile: 6),
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(
                      Responsive.borderRadius(context, mobile: 12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPriorityIcon(task.priority),
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        task.priority,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 12),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (task.date.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColor.textSecondaryColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        task.date,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 12),
                          color: AppColor.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                if (task.date.isNotEmpty)
                  SizedBox(width: Responsive.spacing(context, mobile: 8)),
                if (task.assignee.isNotEmpty)
                  CircleAvatar(
                    radius: Responsive.size(context, mobile: 16),
                    backgroundColor: Color(
                      task.assigneeColor,
                    ).withValues(alpha: 0.2),
                    child: Text(
                      task.assignee.length > 2
                          ? task.assignee.substring(0, 2).toUpperCase()
                          : task.assignee.toUpperCase(),
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 10),
                        color: Color(task.assigneeColor),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('critical') || p.contains('high')) {
      return const Color(0xFFEF4444); // Red
    } else if (p.contains('medium high') || p.contains('medium-high')) {
      return const Color(0xFFF59E0B); // Orange
    } else if (p.contains('medium')) {
      return const Color(0xFFFBBF24); // Yellow
    } else if (p.contains('low medium') || p.contains('low-medium')) {
      return const Color(0xFF84CC16); // Light Green
    } else if (p.contains('low')) {
      return const Color(0xFF10B981); // Green
    }
    return const Color(0xFF6B7280);
  }

  Color _getStatusColor(String? status) {
    if (status == null) return AppColor.textSecondaryColor;
    final s = status.toLowerCase();
    if (s.contains('completed')) {
      return AppColor.completedColor;
    } else if (s.contains('progress')) {
      return AppColor.inProgressColor;
    } else if (s.contains('pending')) {
      return AppColor.pendingColor;
    } else if (s.contains('cancelled')) {
      return AppColor.errorColor;
    }
    return AppColor.textSecondaryColor;
  }

  IconData _getPriorityIcon(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('critical')) {
      return Icons.priority_high;
    } else if (p.contains('high')) {
      return Icons.arrow_upward;
    } else if (p.contains('medium')) {
      return Icons.remove;
    } else if (p.contains('low')) {
      return Icons.arrow_downward;
    }
    return Icons.circle;
  }
}

class DonutChartPainter extends CustomPainter {
  final double completed;
  final double inProgress;
  final double pending;

  DonutChartPainter({
    required this.completed,
    required this.inProgress,
    required this.pending,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 25;
    final strokeWidth = 30.0;

    final completedPaint = Paint()
      ..color = AppColor.completedColor // Green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inProgressPaint = Paint()
      ..color = AppColor.inProgressColor // Blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final pendingPaint = Paint()
      ..color = AppColor.pendingColor // Orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -3.14159 / 2; // Start from top

    final completedSweep = 2 * 3.14159 * completed;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      completedSweep,
      false,
      completedPaint,
    );
    startAngle += completedSweep;

    final inProgressSweep = 2 * 3.14159 * inProgress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      inProgressSweep,
      false,
      inProgressPaint,
    );
    startAngle += inProgressSweep;

    final pendingSweep = 2 * 3.14159 * pending;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      pendingSweep,
      false,
      pendingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is DonutChartPainter &&
        (oldDelegate.completed != completed ||
            oldDelegate.inProgress != inProgress ||
            oldDelegate.pending != pending);
  }
}
  
