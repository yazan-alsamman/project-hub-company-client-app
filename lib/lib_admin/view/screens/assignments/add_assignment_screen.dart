import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/assignment/add_assignment_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/input_fields.dart';
import '../../widgets/common/main_button.dart';
class AddAssignmentScreen extends StatelessWidget {
  const AddAssignmentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(AddAssignmentControllerImp());
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Assignment', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<AddAssignmentControllerImp>(
          builder: (controller) => SingleChildScrollView(
            child: Padding(
              padding: Responsive.padding(context),
              child: Form(
                key: controller.formState,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Header(
                    title: "Add Assignment",
                    subtitle: "Assign tasks to team members",
                    haveButton: false,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 30)),
                  if (controller.errorMessage != null)
                    _buildErrorBanner(context, controller),
                  if (controller.errorMessage != null)
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildTasksMultiSelect(context, controller),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildEmployeeDropdown(context, controller),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildDateField(
                    context,
                    label: "Start Date",
                    controller: controller.startDateController,
                    onTap: () => controller.selectStartDate(context),
                    icon: Icons.calendar_today,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildDateField(
                    context,
                    label: "End Date",
                    controller: controller.endDateController,
                    onTap: () => controller.selectEndDate(context),
                    icon: Icons.event,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildFormField(
                    context,
                    label: "Estimated Hours",
                    hint: "e.g., 8",
                    controller: controller.estimatedHoursController,
                    icon: Icons.access_time,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter estimated hours';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildNotesField(
                    context,
                    label: "Notes (Optional)",
                    hint: "Add any additional notes...",
                    controller: controller.notesController,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 30)),
                  MainButton(
                    onPressed: controller.isLoading
                        ? null
                        : () => controller.assignTasks(),
                    text: controller.isLoading
                        ? "Assigning..."
                        : "Assign Tasks",
                    icon: Icons.assignment,
                    width: double.infinity,
                    height: Responsive.size(context, mobile: 50),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
  Widget _buildTasksMultiSelect(
    BuildContext context,
    AddAssignmentControllerImp controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Tasks",
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 14),
            fontWeight: FontWeight.w500,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 8)),
        InkWell(
          onTap: () {
            _showTasksSelectionDialog(context, controller);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.borderColor, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.selectedTaskIds.isEmpty
                        ? 'Select tasks (you can select multiple)'
                        : '${controller.selectedTaskIds.length} task(s) selected',
                    style: TextStyle(
                      color: controller.selectedTaskIds.isEmpty
                          ? AppColor.textSecondaryColor
                          : AppColor.textColor,
                      fontSize: Responsive.fontSize(context, mobile: 14),
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColor.textColor),
              ],
            ),
          ),
        ),
        if (controller.selectedTaskIds.isNotEmpty) ...[
          SizedBox(height: Responsive.spacing(context, mobile: 8)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.selectedTaskIds.map((taskId) {
              final task = controller.tasks.firstWhere(
                (t) => t.id == taskId,
                orElse: () => controller.tasks.first,
              );
              return Chip(
                label: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 12),
                    color: AppColor.white,
                  ),
                ),
                backgroundColor: AppColor.primaryColor,
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
                onDeleted: () => controller.toggleTaskSelection(taskId),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
  void _showTasksSelectionDialog(
    BuildContext context,
    AddAssignmentControllerImp controller,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Tasks'),
          content: SizedBox(
            width: double.maxFinite,
            child: controller.isLoadingTasks
                ? const Center(child: CircularProgressIndicator())
                : controller.tasks.isEmpty
                ? const Center(child: Text('No tasks available'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.tasks.length,
                    itemBuilder: (context, index) {
                      final task = controller.tasks[index];
                      final isSelected = controller.isTaskSelected(task.id);
                      return CheckboxListTile(
                        title: Text(task.title),
                        subtitle: Text(
                          task.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        value: isSelected,
                        onChanged: (value) {
                          controller.toggleTaskSelection(task.id);
                          setDialogState(() {});
                        },
                        activeColor: AppColor.primaryColor,
                        checkColor: AppColor.white,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEmployeeDropdown(
    BuildContext context,
    AddAssignmentControllerImp controller,
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
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonFormField<String>(
                  initialValue: controller.selectedEmployeeId,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    hintText: "Select an employee",
                    hintStyle: TextStyle(
                      color: AppColor.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  items: controller.employees.map((employee) {
                    return DropdownMenuItem<String>(
                      value: employee.id,
                      child: Text(
                        employee.username,
                        style: TextStyle(
                          color: AppColor.textColor,
                          fontSize: 14,
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
  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    required IconData icon,
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
              border: Border.all(color: AppColor.borderColor, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColor.textSecondaryColor, size: 20),
                SizedBox(width: Responsive.spacing(context, mobile: 12)),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Select $label' : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? AppColor.textSecondaryColor
                          : AppColor.textColor,
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
  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
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
        InputFields(
          controller: controller,
          hintText: hint,
          keyboardType: keyboardType,
          valid: validator ?? (value) => null,
        ),
      ],
    );
  }
  Widget _buildNotesField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
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
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColor.textSecondaryColor,
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildErrorBanner(
    BuildContext context,
    AddAssignmentControllerImp controller,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColor.errorColor, size: 24),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Expanded(
                child: Text(
                  controller.errorMessage ?? 'An error occurred',
                  style: TextStyle(
                    color: AppColor.errorColor,
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColor.errorColor, size: 20),
                onPressed: () {
                  controller.clearErrors();
                },
              ),
            ],
          ),
          if (controller.errorDetails.isNotEmpty) ...[
            SizedBox(height: Responsive.spacing(context, mobile: 12)),
            ...controller.errorDetails.map((detail) {
              return Padding(
                padding: const EdgeInsets.only(left: 36, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      color: AppColor.errorColor,
                      size: 16,
                    ),
                    SizedBox(width: Responsive.spacing(context, mobile: 8)),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          color: AppColor.errorColor,
                          fontSize: Responsive.fontSize(context, mobile: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
