import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/task/add_task_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/input_fields.dart';
import '../../widgets/common/main_button.dart';
class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(AddTaskControllerImp());
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add New Task', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<AddTaskControllerImp>(
          builder: (controller) => SingleChildScrollView(
          child: Padding(
            padding: Responsive.padding(context),
            child: Form(
              key: controller.formState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header(
                    title: "Add New Task",
                    subtitle: "Fill in the details to create a new task",
                    haveButton: false,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 30)),
                  _buildProjectDropdown(context, controller),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildFormField(
                    context,
                    label: "Task Name",
                    hint: "e.g., Implement user authentication",
                    controller: controller.taskNameController,
                    icon: Icons.task_alt,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildDescriptionField(
                    context,
                    label: "Task Description",
                    hint: "Describe the task in detail",
                    controller: controller.taskDescriptionController,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildPriorityDropdown(context, controller),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildTaskStatusDropdown(context, controller),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildFormField(
                    context,
                    label: "Minimum Estimated Hours",
                    hint: "e.g., 4",
                    controller: controller.minEstimatedHourController,
                    icon: Icons.access_time,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildFormField(
                    context,
                    label: "Maximum Estimated Hours",
                    hint: "e.g., 8",
                    controller: controller.maxEstimatedHourController,
                    icon: Icons.access_time,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildFormField(
                    context,
                    label: "Target Role",
                    hint: "e.g., backend, frontend, admin",
                    controller: controller.targetRoleController,
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 30)),
                  MainButton(
                    onPressed: controller.isLoading
                        ? null
                        : controller.createTask,
                    text: controller.isLoading ? 'Creating...' : 'Create Task',
                    icon: Icons.add_task,
                    width: double.infinity,
                    height: Responsive.size(context, mobile: 50),
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 20)),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
          valid: (value) => null,
        ),
      ],
    );
  }
  Widget _buildDescriptionField(
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
          keyboardType: TextInputType.multiline,
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
  Widget _buildProjectDropdown(
    BuildContext context,
    AddTaskControllerImp controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Project",
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
          child: controller.isLoadingProjects
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
                        'Loading projects...',
                        style: TextStyle(
                          color: AppColor.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonFormField<String>(
                  initialValue: controller.selectedProjectId,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    hintText: "Select a project",
                    hintStyle: TextStyle(
                      color: AppColor.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  items: controller.projects.map((project) {
                    return DropdownMenuItem<String>(
                      value: project.id,
                      child: Text(
                        project.title,
                        style: TextStyle(
                          color: AppColor.textColor,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedProjectId = value;
                    controller.update();
                  },
                ),
        ),
      ],
    );
  }
  Widget _buildPriorityDropdown(
    BuildContext context,
    AddTaskControllerImp controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Priority",
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
          child: DropdownButtonFormField<String>(
            initialValue: controller.selectedPriority,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              hintText: "Select priority",
              hintStyle: TextStyle(
                color: AppColor.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            items: AddTaskControllerImp.priorityOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(
                  option['label']!,
                  style: TextStyle(color: AppColor.textColor, fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              controller.selectedPriority = value;
              controller.update();
            },
          ),
        ),
      ],
    );
  }
  Widget _buildTaskStatusDropdown(
    BuildContext context,
    AddTaskControllerImp controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Task Status",
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
          child: DropdownButtonFormField<String>(
            initialValue: controller.selectedTaskStatus,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              hintText: "Select task status",
              hintStyle: TextStyle(
                color: AppColor.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            items: AddTaskControllerImp.taskStatusOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(
                  option['label']!,
                  style: TextStyle(color: AppColor.textColor, fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              controller.selectedTaskStatus = value;
              controller.update();
            },
          ),
        ),
      ],
    );
  }
}
