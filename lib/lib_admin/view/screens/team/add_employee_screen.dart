import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/employee/add_employee_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/input_fields.dart';
import '../../widgets/common/main_button.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});
  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _previousErrorMessage;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AddEmployeeControllerImp());
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Employee', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<AddEmployeeControllerImp>(
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
                        title: "Add New Employee",
                        subtitle:
                            "Fill in the details to add a new team member",
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
                        "User Information",
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 18),
                          fontWeight: FontWeight.bold,
                          color: AppColor.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                      _buildFormField(
                        context,
                        label: "Username",
                        hint: "e.g., johndoe",
                        controller: controller.usernameController,
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                      _buildFormField(
                        context,
                        label: "Email",
                        hint: "e.g., john.doe@example.com",
                        controller: controller.emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                      _buildFormField(
                        context,
                        label: "Password",
                        hint: "Enter password",
                        controller: controller.passwordController,
                        icon: Icons.lock_outline,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                      Text(
                        "Role",
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 14),
                          fontWeight: FontWeight.w500,
                          color: AppColor.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 8)),
                      _buildRoleDropdown(context, controller),
                      SizedBox(height: Responsive.spacing(context, mobile: 30)),
                      Text(
                        "Employee Information",
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 18),
                          fontWeight: FontWeight.bold,
                          color: AppColor.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                      _buildFormField(
                        context,
                        label: "Employee Code",
                        hint: "e.g., EMP001",
                        controller: controller.employeeCodeController,
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.text,
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
                      Text(
                        "Hire Date",
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 14),
                          fontWeight: FontWeight.w500,
                          color: AppColor.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 8)),
                      GestureDetector(
                        onTap: () => _selectDate(context, controller),
                        child: AbsorbPointer(
                          child: InputFields(
                            controller: controller.hireDateController,
                            hintText: "Select hire date (YYYY-MM-DD)",
                            keyboardType: TextInputType.text,
                            valid: (value) => null,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                      _buildFormField(
                        context,
                        label: "Salary",
                        hint: "e.g., 75000",
                        controller: controller.salaryController,
                        icon: Icons.attach_money,
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
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                      _buildFormField(
                        context,
                        label: "Sub Role",
                        hint: "e.g., frontend, backend,",
                        controller: controller.subRoleController,
                        icon: Icons.settings_outlined,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 30)),
                      MainButton(
                        onPressed: controller.isLoading
                            ? null
                            : controller.createEmployee,
                        text: controller.isLoading
                            ? 'Creating...'
                            : 'Create Employee',
                        icon: Icons.person_add,
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
    required IconData icon,
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

  Widget _buildRoleDropdown(
    BuildContext context,
    AddEmployeeControllerImp controller,
  ) {
    if (controller.isLoadingRoles) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.roles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No roles available',
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
        initialValue: controller.selectedRoleId,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          hintText: "Select role",
          hintStyle: TextStyle(
            color: AppColor.textSecondaryColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.assignment_ind_outlined,
            color: AppColor.textSecondaryColor,
            size: 20,
          ),
        ),
        items: controller.roles.map((role) {
          return DropdownMenuItem<String>(
            value: role.id,
            child: Text(
              role.name,
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
          controller.selectedRoleId = value;
          controller.update();
        },
      ),
    );
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    AddEmployeeControllerImp controller,
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

  Widget _buildPositionDropdown(
    BuildContext context,
    AddEmployeeControllerImp controller,
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
    AddEmployeeControllerImp controller,
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
          controller.update();
        },
      ),
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    AddEmployeeControllerImp controller,
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
    AddEmployeeControllerImp controller,
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
      controller.hireDateController.text = formattedDate;
      controller.update();
    }
  }
}
