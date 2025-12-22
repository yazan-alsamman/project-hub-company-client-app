import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/project/edit_project_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/input_fields.dart';
import '../../widgets/common/main_button.dart';
class EditProjectScreen extends StatefulWidget {
  final String projectId;
  const EditProjectScreen({super.key, required this.projectId});
  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}
class _EditProjectScreenState extends State<EditProjectScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _previousErrorMessage;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Get.put(EditProjectControllerImp(projectId: widget.projectId));
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Project', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<EditProjectControllerImp>(
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
          if (controller.isLoadingProject) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }
          if (controller.project == null) {
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
                    controller.errorMessage ?? 'Failed to load project data',
                    style: TextStyle(fontSize: 16, color: AppColor.textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadProjectData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final project = controller.project!;
          return SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: Responsive.padding(context),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      title: "Edit Project",
                      subtitle: "Update project information",
                      haveButton: false,
                    ),
                    if (controller.errorMessage != null)
                      _buildErrorMessage(
                        context,
                        controller,
                        controller.errorMessage!,
                      ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    Text(
                      "Project Information",
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 18),
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Project Name",
                      value: project.title,
                      icon: Icons.folder_outlined,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Company",
                      value: project.company,
                      icon: Icons.business_outlined,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Description",
                      value: project.description,
                      icon: Icons.description_outlined,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Start Date",
                      value: project.startDate,
                      icon: Icons.calendar_today_outlined,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Estimated End Date",
                      value: project.endDate,
                      icon: Icons.event_outlined,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 30)),
                    Text(
                      "Editable Information",
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 18),
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    Text(
                      "Status",
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 8)),
                    _buildStatusDropdown(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildFormField(
                      context,
                      label: "Project Code",
                      hint: "e.g., PROJ001",
                      controller: controller.codeController,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildFormField(
                      context,
                      label: "Safe Delay (days)",
                      hint: "e.g., 7",
                      controller: controller.safeDelayController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 30)),
                    MainButton(
                      onPressed: controller.isLoading
                          ? null
                          : controller.updateProject,
                      text: controller.isLoading
                          ? 'Updating...'
                          : 'Update Project',
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
                            : controller.deleteProject,
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
                                  : 'Delete Project',
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
  Widget _buildReadOnlyField(
    BuildContext context, {
    required String label,
    required String value,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColor.backgroundColor,
            border: Border.all(color: AppColor.borderColor, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColor.textSecondaryColor, size: 20),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
              ),
            ],
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
  Widget _buildStatusDropdown(
    BuildContext context,
    EditProjectControllerImp controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: controller.selectedStatus,
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
        items: const [
          DropdownMenuItem(value: 'pending', child: Text('Pending')),
          DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
          DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
          DropdownMenuItem(value: 'completed', child: Text('Completed')),
          DropdownMenuItem(value: 'cancelled', child: Text('Canceled')),
        ],
        onChanged: (value) {
          controller.selectedStatus = value;
          controller.update();
        },
      ),
    );
  }
  Widget _buildErrorMessage(
    BuildContext context,
    EditProjectControllerImp controller,
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
