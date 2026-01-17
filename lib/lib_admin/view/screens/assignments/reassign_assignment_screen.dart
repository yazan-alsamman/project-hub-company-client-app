import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/assignment/reassign_assignment_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/main_button.dart';

class ReassignAssignmentScreen extends StatelessWidget {
  const ReassignAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ReassignAssignmentControllerImp>()) {
      Get.put(ReassignAssignmentControllerImp());
    }
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Assign', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<ReassignAssignmentControllerImp>(
          init: Get.isRegistered<ReassignAssignmentControllerImp>()
              ? Get.find<ReassignAssignmentControllerImp>()
              : Get.put(ReassignAssignmentControllerImp()),
          builder: (controller) {
            if (controller.isLoadingEmployees) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.primaryColor),
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: Responsive.padding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Header(
                      title: "Edit Assign",
                      subtitle: "Reassign task to a different employee",
                      haveButton: false,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 30)),
                    _buildTaskInfo(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),
                    _buildEmployeeDropdown(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 32)),
                    if (controller.errorMessage != null)
                      _buildErrorMessage(context, controller),
                    if (controller.errorMessage != null)
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    MainButton(
                      onPressed: controller.isLoading
                          ? null
                          : () => controller.reassignAssignment(),
                      text: controller.isLoading ? 'Reassigning...' : 'Edit',
                      icon: Icons.edit,
                      width: double.infinity,
                      height: Responsive.size(context, mobile: 50),
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

  String _getCurrentEmployeeName(ReassignAssignmentControllerImp controller) {
    final assignment = controller.assignment;
    
    // If employeeName is not 'Unknown', return it
    if (assignment.employeeName.isNotEmpty && 
        assignment.employeeName.toLowerCase() != 'unknown') {
      return assignment.employeeName;
    }
    
    // Otherwise, try to find the employee in the loaded employees list
    if (controller.employees.isNotEmpty && assignment.employeeId.isNotEmpty) {
      try {
        final employee = controller.employees.firstWhere(
          (emp) => emp.id == assignment.employeeId,
        );
        return employee.username;
      } catch (e) {
        // Employee not found in the list, fallback to employeeId or Unknown
      }
    }
    
    // Final fallback
    return assignment.employeeId.isNotEmpty 
        ? assignment.employeeId 
        : 'Unknown';
  }

  Widget _buildTaskInfo(
    BuildContext context,
    ReassignAssignmentControllerImp controller,
  ) {
    final assignment = controller.assignment;
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 12),
        ),
        border: Border.all(color: AppColor.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.task_alt,
                color: AppColor.primaryColor,
                size: Responsive.iconSize(context, mobile: 20),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Expanded(
                child: Text(
                  'Task Information',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 18),
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildInfoRow(
            context,
            Icons.title,
            'Task Name',
            assignment.taskName,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          if (assignment.taskDescription != null &&
              assignment.taskDescription!.isNotEmpty)
            _buildInfoRow(
              context,
              Icons.description,
              'Description',
              assignment.taskDescription!,
            ),
          if (assignment.taskDescription != null &&
              assignment.taskDescription!.isNotEmpty)
            SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildInfoRow(
            context,
            Icons.person,
            'Current Employee',
            _getCurrentEmployeeName(controller),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildInfoRow(
            context,
            Icons.calendar_today,
            'Start Date',
            assignment.formattedStartDate,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildInfoRow(
            context,
            Icons.event,
            'End Date',
            assignment.formattedEndDate,
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          _buildInfoRow(
            context,
            Icons.access_time,
            'Estimated Hours',
            '${assignment.estimatedHours} hours',
          ),
          if (assignment.status.isNotEmpty) ...[
            SizedBox(height: Responsive.spacing(context, mobile: 12)),
            _buildInfoRow(
              context,
              Icons.info_outline,
              'Status',
              assignment.status,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: Responsive.iconSize(context, mobile: 18),
          color: AppColor.textSecondaryColor,
        ),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeDropdown(
    BuildContext context,
    ReassignAssignmentControllerImp controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Employee",
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 14),
            fontWeight: FontWeight.w500,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 8)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.borderColor, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: controller.isLoadingEmployees
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
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
                        'Loading employees...',
                        style: TextStyle(
                          color: AppColor.textSecondaryColor,
                          fontSize: Responsive.fontSize(context, mobile: 14),
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: controller.selectedEmployeeId != null &&
                          controller.employees.any(
                            (emp) => emp.id == controller.selectedEmployeeId,
                          )
                      ? controller.selectedEmployeeId
                      : null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    hintText: "Select an employee",
                    hintStyle: TextStyle(
                      color: AppColor.textSecondaryColor,
                      fontSize: Responsive.fontSize(context, mobile: 14),
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColor.textSecondaryColor,
                      size: 20,
                    ),
                  ),
                  items: controller.employees.map((employee) {
                    return DropdownMenuItem<String>(
                      value: employee.id,
                      child: Text(
                        employee.username,
                        style: TextStyle(
                          color: AppColor.textColor,
                          fontSize: Responsive.fontSize(context, mobile: 14),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectEmployee(value);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    ReassignAssignmentControllerImp controller,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 12)),
      decoration: BoxDecoration(
        color: AppColor.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.errorColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColor.errorColor,
            size: Responsive.iconSize(context, mobile: 20),
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 12)),
          Expanded(
            child: Text(
              controller.errorMessage ?? '',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 14),
                color: AppColor.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

