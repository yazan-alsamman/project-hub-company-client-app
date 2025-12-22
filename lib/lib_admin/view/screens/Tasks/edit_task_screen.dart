import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/task/edit_task_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/input_fields.dart';
import '../../widgets/common/main_button.dart';
class EditTaskScreen extends StatefulWidget {
  final String taskId;
  const EditTaskScreen({super.key, required this.taskId});
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}
class _EditTaskScreenState extends State<EditTaskScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _previousErrorMessage;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Get.put(EditTaskControllerImp(taskId: widget.taskId));
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Task', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<EditTaskControllerImp>(
          builder: (controller) {
          if (controller.errorMessage != null &&
              controller.errorMessage != _previousErrorMessage) {
            _previousErrorMessage = controller.errorMessage;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          } else if (controller.errorMessage == null) {
            _previousErrorMessage = null;
          }
          if (controller.isLoadingTask) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }
          if (controller.task == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColor.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage ?? 'Failed to load task data',
                    style: TextStyle(fontSize: 16, color: AppColor.textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadTaskData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: Responsive.padding(context),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      title: "Edit Task",
                      subtitle: "Update task information",
                      haveButton: false,
                    ),
                    if (controller.errorMessage != null)
                      _buildErrorMessage(
                        context,
                        controller,
                        controller.errorMessage!,
                      ),
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
                          : controller.updateTask,
                      text: controller.isLoading
                          ? 'Updating...'
                          : 'Update Task',
                      icon: Icons.save,
                      width: double.infinity,
                      height: Responsive.size(context, mobile: 50),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    Container(
                      width: double.infinity,
                      height: Responsive.size(context, mobile: 50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColor.errorColor,
                          width: 1.5,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isLoading
                            ? null
                            : controller.deleteTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: controller.isLoading
                                  ? AppColor.textSecondaryColor
                                  : AppColor.errorColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: Responsive.spacing(context, mobile: 8),
                            ),
                            Text(
                              controller.isLoading
                                  ? 'Deleting...'
                                  : 'Delete Task',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(
                                  context,
                                  mobile: 16,
                                ),
                                fontWeight: FontWeight.w600,
                                color: controller.isLoading
                                    ? AppColor.textSecondaryColor
                                    : AppColor.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 20)),
                  ],
                ),
              ),
            ),
          );
        },
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildPriorityDropdown(
    BuildContext context,
    EditTaskControllerImp controller,
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
              prefixIcon: Icon(
                Icons.flag_outlined,
                color: AppColor.textSecondaryColor,
                size: 20,
              ),
            ),
            items: EditTaskControllerImp.priorityOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(
                  option['label']!,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    fontWeight: FontWeight.w500,
                    color: AppColor.textColor,
                  ),
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
    EditTaskControllerImp controller,
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
              hintText: "Select status",
              hintStyle: TextStyle(
                color: AppColor.textSecondaryColor,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.flag_outlined,
                color: AppColor.textSecondaryColor,
                size: 20,
              ),
            ),
            items: EditTaskControllerImp.taskStatusOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(
                  option['label']!,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    fontWeight: FontWeight.w500,
                    color: AppColor.textColor,
                  ),
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
  Widget _buildErrorMessage(
    BuildContext context,
    EditTaskControllerImp controller,
    String message,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, mobile: 16)),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: AppColor.errorColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    fontWeight: FontWeight.bold,
                    color: AppColor.errorColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 13),
                    color: AppColor.textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: AppColor.textSecondaryColor,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              controller.errorMessage = null;
              controller.update();
            },
          ),
        ],
      ),
    );
  }
}
