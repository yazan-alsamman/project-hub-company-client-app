import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/assignment/assignments_controller.dart';
import '../../../controller/assignment/assignments_tabs_controller.dart';
import '../../../controller/common/customDrawer_controller.dart';
import '../../../core/class/statusrequest.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../../core/constant/routes.dart';
import '../../../data/Models/assignment_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/main_button.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        child: Column(
          children: [
            Container(
              color: AppColor.backgroundColor,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColor.primaryColor,
                unselectedLabelColor: AppColor.textSecondaryColor,
                indicatorColor: AppColor.primaryColor,
                tabs: const [
                  Tab(text: 'Employee Assignments'),
                  Tab(text: 'Employee Schedule'),
                  Tab(text: 'Assignments by Task'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEmployeeAssignmentsTab(context),
                  _buildEmployeeScheduleTab(context),
                  _buildAssignmentsByTaskTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeAssignmentsTab(BuildContext context) {
    return GetBuilder<AssignmentsControllerImp>(
      init: Get.put(AssignmentsControllerImp()),
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () => controller.refreshAssignments(),
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
                          title: "Assignments",
                          subtitle: "View and manage task assignments",
                          haveButton: false,
                        ),
                        SizedBox(
                          height: Responsive.spacing(context, mobile: 30),
                        ),
                        _buildEmployeeDropdown(context, controller),
                        SizedBox(
                          height: Responsive.spacing(context, mobile: 20),
                        ),
                        MainButton(
                          onPressed: controller.selectedEmployeeId != null
                              ? () {
                                  controller.loadAssignments(
                                    controller.selectedEmployeeId!,
                                  );
                                }
                              : null,
                          text: "View Assignments",
                          icon: Icons.visibility,
                          width: double.infinity,
                          height: Responsive.size(context, mobile: 50),
                        ),
                        SizedBox(
                          height: Responsive.spacing(context, mobile: 20),
                        ),
                        MainButton(
                          onPressed: () {
                            Get.toNamed(AppRoute.addAssignment);
                          },
                          text: "Add Assignment",
                          icon: Icons.add,
                          width: double.infinity,
                          height: Responsive.size(context, mobile: 50),
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.selectedEmployeeId != null)
                  _buildAssignmentsList(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmployeeScheduleTab(BuildContext context) {
    return GetBuilder<EmployeeScheduleController>(
      init: Get.put(EmployeeScheduleController()),
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
                        title: "Employee Schedule",
                        subtitle: "View employee schedule by date range",
                        haveButton: false,
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 30)),
                      _buildScheduleEmployeeDropdown(context, controller),
                      SizedBox(height: Responsive.spacing(context, mobile: 20)),
                      _buildScheduleDateField(
                        context,
                        label: "Start Date",
                        date: controller.startDate,
                        onTap: () => controller.selectStartDate(context),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 20)),
                      _buildScheduleDateField(
                        context,
                        label: "End Date",
                        date: controller.endDate,
                        onTap: () => controller.selectEndDate(context),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 20)),
                      MainButton(
                        onPressed:
                            controller.selectedEmployeeId != null &&
                                controller.startDate != null &&
                                controller.endDate != null
                            ? () {
                                controller.loadEmployeeSchedule();
                              }
                            : null,
                        text: "View Employee Schedule",
                        icon: Icons.calendar_view_week,
                        width: double.infinity,
                        height: Responsive.size(context, mobile: 50),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 20)),
                      MainButton(
                        onPressed: () {
                          Get.toNamed(AppRoute.addAssignment);
                        },
                        text: "Add Assignment",
                        icon: Icons.add,
                        width: double.infinity,
                        height: Responsive.size(context, mobile: 50),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.selectedEmployeeId != null &&
                  controller.startDate != null &&
                  controller.endDate != null)
                _buildScheduleList(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignmentsByTaskTab(BuildContext context) {
    return GetBuilder<TaskAssignmentsController>(
      init: Get.put(TaskAssignmentsController()),
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
                        title: "Assignments by Task",
                        subtitle: "View all assignments for a specific task",
                        haveButton: false,
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 30)),
                      _buildTaskDropdown(context, controller),
                      SizedBox(height: Responsive.spacing(context, mobile: 20)),
                      MainButton(
                        onPressed: controller.selectedTaskId != null
                            ? () {
                                controller.loadTaskAssignments();
                              }
                            : null,
                        text: "View Task Assignments",
                        icon: Icons.visibility,
                        width: double.infinity,
                        height: Responsive.size(context, mobile: 50),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 20)),
                      MainButton(
                        onPressed: () {
                          Get.toNamed(AppRoute.addAssignment);
                        },
                        text: "Add Assignment",
                        icon: Icons.add,
                        width: double.infinity,
                        height: Responsive.size(context, mobile: 50),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.selectedTaskId != null)
                _buildTaskAssignmentsList(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmployeeDropdown(
    BuildContext context,
    AssignmentsControllerImp controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedEmployeeId,
          hint: Text(
            'Select an employee',
            style: TextStyle(
              color: AppColor.textSecondaryColor,
              fontSize: Responsive.fontSize(context, mobile: 16),
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: AppColor.textColor),
          items: controller.employees.map((employee) {
            return DropdownMenuItem<String>(
              value: employee.id,
              child: Text(
                employee.username,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 16),
                  color: AppColor.textColor,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              final employee = controller.employees.firstWhere(
                (emp) => emp.id == value,
              );
              controller.selectEmployee(value, employee.username);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAssignmentsList(
    BuildContext context,
    AssignmentsControllerImp controller,
  ) {
    if (controller.isLoading && controller.assignments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }
    if (controller.statusRequest != StatusRequest.success &&
        controller.assignments.isEmpty &&
        !controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No assignments found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select an employee and click "View Assignments"',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (controller.assignments.isEmpty && !controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No assignments found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This employee has no assignments yet',
                style: TextStyle(
                  fontSize: 14,
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
            'Assignments for ${controller.selectedEmployeeName ?? "Selected Employee"}',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          ...controller.assignments.map((assignment) {
            return _buildAssignmentCard(context, assignment);
          }),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    AssignmentModel assignment,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  assignment.taskName,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 16),
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: assignment.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  assignment.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    fontWeight: FontWeight.bold,
                    color: assignment.statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (assignment.taskDescription != null &&
              assignment.taskDescription!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              assignment.taskDescription!,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 14),
                color: AppColor.textSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColor.borderColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  'Start Date',
                  assignment.formattedStartDate,
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  'End Date',
                  assignment.formattedEndDate,
                  Icons.event,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  'Estimated Hours',
                  '${assignment.estimatedHours}h',
                  Icons.access_time,
                ),
              ),
              if (assignment.actualHours != null)
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Actual Hours',
                    '${assignment.actualHours}h',
                    Icons.timer,
                  ),
                ),
            ],
          ),
          if (assignment.assignedByName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppColor.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assigned by: ${assignment.assignedByName}',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColor.textSecondaryColor),
        const SizedBox(width: 8),
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
              Text(
                value,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
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

  Widget _buildScheduleEmployeeDropdown(
    BuildContext context,
    EmployeeScheduleController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: controller.isLoadingEmployees
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                      'Loading employees...',
                      style: TextStyle(
                        color: AppColor.textSecondaryColor,
                        fontSize: Responsive.fontSize(context, mobile: 14),
                      ),
                    ),
                  ],
                ),
              )
            : DropdownButton<String>(
                value: controller.selectedEmployeeId,
                hint: Text(
                  'Select an employee',
                  style: TextStyle(
                    color: AppColor.textSecondaryColor,
                    fontSize: Responsive.fontSize(context, mobile: 16),
                  ),
                ),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColor.textColor),
                items: controller.employees.map((employee) {
                  return DropdownMenuItem<String>(
                    value: employee.id,
                    child: Text(
                      employee.username,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 16),
                        color: AppColor.textColor,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  controller.selectEmployee(value);
                },
              ),
      ),
    );
  }

  Widget _buildScheduleDateField(
    BuildContext context, {
    required String label,
    DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 14),
            fontWeight: FontWeight.w500,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 8)),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColor.textSecondaryColor,
                  size: 20,
                ),
                SizedBox(width: Responsive.spacing(context, mobile: 12)),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                        : 'Select $label',
                    style: TextStyle(
                      color: date != null
                          ? AppColor.textColor
                          : AppColor.textSecondaryColor,
                      fontSize: Responsive.fontSize(context, mobile: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleList(
    BuildContext context,
    EmployeeScheduleController controller,
  ) {
    if (controller.isLoading && controller.scheduleAssignments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }
    if (controller.statusRequest != StatusRequest.success &&
        controller.scheduleAssignments.isEmpty &&
        !controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No schedule found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select dates and click "View Employee Schedule"',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (controller.scheduleAssignments.isEmpty && !controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No assignments in this date range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
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
            'Schedule (${controller.scheduleAssignments.length} assignments)',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          ...controller.scheduleAssignments.map((assignment) {
            return _buildAssignmentCard(context, assignment);
          }),
        ],
      ),
    );
  }

  Widget _buildTaskDropdown(
    BuildContext context,
    TaskAssignmentsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: controller.isLoadingTasks
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                      'Loading tasks...',
                      style: TextStyle(
                        color: AppColor.textSecondaryColor,
                        fontSize: Responsive.fontSize(context, mobile: 14),
                      ),
                    ),
                  ],
                ),
              )
            : DropdownButton<String>(
                value: controller.selectedTaskId,
                hint: Text(
                  'Select a task',
                  style: TextStyle(
                    color: AppColor.textSecondaryColor,
                    fontSize: Responsive.fontSize(context, mobile: 16),
                  ),
                ),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColor.textColor),
                items: controller.tasks.map((task) {
                  return DropdownMenuItem<String>(
                    value: task.id,
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 16),
                        color: AppColor.textColor,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  controller.selectTask(value);
                },
              ),
      ),
    );
  }

  Widget _buildTaskAssignmentsList(
    BuildContext context,
    TaskAssignmentsController controller,
  ) {
    if (controller.isLoading && controller.taskAssignments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }
    if (controller.statusRequest != StatusRequest.success &&
        controller.taskAssignments.isEmpty &&
        !controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No assignments found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a task and click "View Task Assignments"',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (controller.taskAssignments.isEmpty && !controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: AppColor.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No assignments for this task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final selectedTask = controller.tasks.firstWhere(
      (task) => task.id == controller.selectedTaskId,
      orElse: () => controller.tasks.first,
    );
    return Padding(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assignments for "${selectedTask.title}" (${controller.taskAssignments.length})',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, mobile: 18),
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          ...controller.taskAssignments.map((assignment) {
            return _buildTaskAssignmentCard(context, assignment);
          }),
        ],
      ),
    );
  }

  Widget _buildTaskAssignmentCard(
    BuildContext context,
    AssignmentModel assignment,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.employeeName,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 16),
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                    if (assignment.employeeEmail != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        assignment.employeeEmail!,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 12),
                          color: AppColor.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: assignment.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  assignment.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    fontWeight: FontWeight.bold,
                    color: assignment.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColor.borderColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  'Start Date',
                  assignment.formattedStartDate,
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  'End Date',
                  assignment.formattedEndDate,
                  Icons.event,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  'Estimated Hours',
                  '${assignment.estimatedHours}h',
                  Icons.access_time,
                ),
              ),
              if (assignment.actualHours != null)
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Actual Hours',
                    '${assignment.actualHours}h',
                    Icons.timer,
                  ),
                ),
            ],
          ),
          if (assignment.assignedByName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppColor.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assigned by: ${assignment.assignedByName}',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
          if (assignment.notes != null && assignment.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColor.borderColor),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 16,
                  color: AppColor.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    assignment.notes!,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 12),
                      color: AppColor.textSecondaryColor,
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
