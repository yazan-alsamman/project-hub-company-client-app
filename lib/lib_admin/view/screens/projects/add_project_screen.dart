import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/project/add_project_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/input_fields.dart';
import '../../widgets/common/main_button.dart';
class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});
  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}
class _AddProjectScreenState extends State<AddProjectScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _previousErrorMessage;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Get.put(AddProjectControllerImp());
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Project', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<AddProjectControllerImp>(
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
          return SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: Responsive.padding(context),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      title: "Add New Project",
                      subtitle: "Fill in the details to create a new project",
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
                    _buildFormField(
                      context,
                      label: "Project Name",
                      hint: "e.g., E-commerce Platform",
                      controller: controller.nameController,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildFormField(
                      context,
                      label: "Project Code",
                      hint: "e.g., PROJ001",
                      controller: controller.codeController,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    Text(
                      "Client",
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 8)),
                    _buildClientDropdown(context, controller),
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
                    Text(
                      "Start Date",
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 8)),
                    GestureDetector(
                      onTap: () => _selectDate(
                        context,
                        controller,
                        controller.startDateController,
                      ),
                      child: AbsorbPointer(
                        child: InputFields(
                          controller: controller.startDateController,
                          hintText: "Select start date (YYYY-MM-DD)",
                          keyboardType: TextInputType.text,
                          valid: (value) => null,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    Text(
                      "Estimated End Date",
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 8)),
                    GestureDetector(
                      onTap: () => _selectDate(
                        context,
                        controller,
                        controller.estimatedEndDateController,
                      ),
                      child: AbsorbPointer(
                        child: InputFields(
                          controller: controller.estimatedEndDateController,
                          hintText: "Select estimated end date (YYYY-MM-DD)",
                          keyboardType: TextInputType.text,
                          valid: (value) => null,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildFormField(
                      context,
                      label: "Safe Delay (Days)",
                      hint: "e.g., 7",
                      controller: controller.safeDelayController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 30)),
                    MainButton(
                      onPressed: controller.isLoading
                          ? null
                          : controller.createProject,
                      text: controller.isLoading
                          ? 'Creating...'
                          : 'Create Project',
                      icon: Icons.add_task,
                      width: double.infinity,
                      height: Responsive.size(context, mobile: 50),
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
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
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
          obscureText: obscureText,
        ),
      ],
    );
  }
  Widget _buildClientDropdown(
    BuildContext context,
    AddProjectControllerImp controller,
  ) {
    debugPrint(
      '🟡 _buildClientDropdown - isLoadingClients: ${controller.isLoadingClients}',
    );
    debugPrint(
      '🟡 _buildClientDropdown - clients.length: ${controller.clients.length}',
    );
    debugPrint(
      '🟡 _buildClientDropdown - errorMessage: ${controller.errorMessage}',
    );
    if (controller.isLoadingClients) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.clients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person_off_outlined,
              color: AppColor.textSecondaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No clients available',
              style: TextStyle(
                color: AppColor.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            if (controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.errorMessage!,
                  style: TextStyle(color: AppColor.errorColor, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: controller.selectedClientId,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          hintText: "Select client",
          hintStyle: TextStyle(
            color: AppColor.textSecondaryColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.person_outline,
            color: AppColor.textSecondaryColor,
            size: 20,
          ),
        ),
        items: controller.clients.map((client) {
          return DropdownMenuItem<String>(
            value: client.id,
            child: Text(
              client.displayName,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 14),
                fontWeight: FontWeight.w500,
                color: AppColor.textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          controller.selectedClientId = value;
          controller.update();
        },
      ),
    );
  }
  Widget _buildStatusDropdown(
    BuildContext context,
    AddProjectControllerImp controller,
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
          DropdownMenuItem(value: 'in progress', child: Text('In Progress')),
          DropdownMenuItem(value: 'on hold', child: Text('On Hold')),
          DropdownMenuItem(value: 'completed', child: Text('Completed')),
          DropdownMenuItem(value: 'canceled', child: Text('Canceled')),
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
    AddProjectControllerImp controller,
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
  Future<void> _selectDate(
    BuildContext context,
    AddProjectControllerImp controller,
    TextEditingController dateController,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColor.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      dateController.text = formattedDate;
      controller.update();
    }
  }
}
