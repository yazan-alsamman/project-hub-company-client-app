import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/employee/edit_employee_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/input_fields.dart';
import '../../widgets/common/main_button.dart';
class EditEmployeeScreen extends StatefulWidget {
  final String employeeId;
  const EditEmployeeScreen({super.key, required this.employeeId});
  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}
class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _previousErrorMessage;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Get.put(EditEmployeeControllerImp(employeeId: widget.employeeId));
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Employee', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<EditEmployeeControllerImp>(
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
          if (controller.isLoadingEmployee) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }
          if (controller.employee == null) {
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
                    controller.errorMessage ?? 'Failed to load employee data',
                    style: TextStyle(fontSize: 16, color: AppColor.textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadEmployeeData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final employee = controller.employee!;
          return SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: Responsive.padding(context),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      title: "Edit Employee",
                      subtitle: "Update employee information",
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
                      "Employee Information",
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 18),
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Username",
                      value: employee.username,
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Email",
                      value: employee.email,
                      icon: Icons.email_outlined,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Employee Code",
                      value: employee.employeeCode ?? '-',
                      icon: Icons.badge_outlined,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Hire Date",
                      value: employee.hireDate != null
                          ? _formatDate(employee.hireDate!)
                          : '-',
                      icon: Icons.calendar_today_outlined,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildReadOnlyField(
                      context,
                      label: "Sub Role",
                      value: employee.subRole ?? '-',
                      icon: Icons.work_outline,
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
                      "Position",
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 8)),
                    _buildPositionDropdown(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    Text(
                      "Department",
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 8)),
                    _buildDepartmentDropdown(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    _buildFormField(
                      context,
                      label: "Salary",
                      hint: "e.g., 75000",
                      controller: controller.salaryController,
                      keyboardType: TextInputType.number,
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
                    SizedBox(height: Responsive.spacing(context, mobile: 30)),
                    MainButton(
                      onPressed: controller.isLoading
                          ? null
                          : controller.updateEmployee,
                      text: controller.isLoading
                          ? 'Updating...'
                          : 'Update Employee',
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
                            : controller.deleteEmployee,
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
                                  : 'Delete Employee',
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
  Widget _buildPositionDropdown(
    BuildContext context,
    EditEmployeeControllerImp controller,
  ) {
    if (controller.isLoadingPositions) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.positions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No positions available',
          style: TextStyle(color: AppColor.textSecondaryColor, fontSize: 14),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: controller.selectedPositionId,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          hintText: "Select position",
          hintStyle: TextStyle(
            color: AppColor.textSecondaryColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.work_outline,
            color: AppColor.textSecondaryColor,
            size: 20,
          ),
        ),
        items: controller.positions.map((position) {
          return DropdownMenuItem<String>(
            value: position.id,
            child: Text(
              position.name,
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
          controller.selectedPositionId = value;
          controller.update();
        },
      ),
    );
  }
  Widget _buildDepartmentDropdown(
    BuildContext context,
    EditEmployeeControllerImp controller,
  ) {
    if (controller.isLoadingDepartments) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.departments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No departments available',
          style: TextStyle(color: AppColor.textSecondaryColor, fontSize: 14),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: controller.selectedDepartmentId,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          hintText: "Select department",
          hintStyle: TextStyle(
            color: AppColor.textSecondaryColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.business_outlined,
            color: AppColor.textSecondaryColor,
            size: 20,
          ),
        ),
        items: controller.departments.map((department) {
          return DropdownMenuItem<String>(
            value: department.id,
            child: Text(
              department.name,
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
          controller.selectedDepartmentId = value;
          controller.departmentId = value; // Update departmentId as well
          controller.update();
        },
      ),
    );
  }
  Widget _buildStatusDropdown(
    BuildContext context,
    EditEmployeeControllerImp controller,
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
          DropdownMenuItem(value: 'active', child: Text('Active')),
          DropdownMenuItem(value: 'on_leave', child: Text('On Leave')),
          DropdownMenuItem(value: 'terminated', child: Text('Terminated')),
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
    EditEmployeeControllerImp controller,
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
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
