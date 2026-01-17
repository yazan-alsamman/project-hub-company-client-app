import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/task/request_delay_controller.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../../data/Models/task_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';

class RequestDelayScreen extends StatelessWidget {
  const RequestDelayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = Get.arguments as TaskModel?;
    if (task == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Request Delay', showBackButton: true),
        body: const Center(
          child: Text('Task not found'),
        ),
      );
    }

    if (!Get.isRegistered<RequestDelayController>()) {
      Get.put(RequestDelayController(taskId: task.id, task: task));
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Request Delay', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<RequestDelayController>(
          init: Get.isRegistered<RequestDelayController>()
              ? Get.find<RequestDelayController>()
              : Get.put(RequestDelayController(taskId: task.id, task: task)),
          builder: (controller) {
            return SingleChildScrollView(
              child: Padding(
                padding: Responsive.padding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      title: 'Request Task Delay',
                      subtitle: 'Request to extend the due date for this task',
                      haveButton: false,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 30)),
                    _buildTaskInfo(context, task),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),
                    _buildDateField(context, controller),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),
                    _buildReasonField(context, controller),
                    if (controller.errorMessage != null) ...[
                      SizedBox(height: Responsive.spacing(context, mobile: 16)),
                      _buildErrorMessage(context, controller.errorMessage!),
                    ],
                    SizedBox(height: Responsive.spacing(context, mobile: 32)),
                    _buildSubmitButton(context, controller),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTaskInfo(BuildContext context, TaskModel task) {
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
                  task.title,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 16),
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColor.textSecondaryColor,
                size: Responsive.iconSize(context, mobile: 16),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              Text(
                'Current Due Date: ${task.dueDate}',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 14),
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    RequestDelayController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Due Date',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 14),
            fontWeight: FontWeight.w500,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 8)),
        GestureDetector(
          onTap: () => controller.selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.spacing(context, mobile: 16),
              vertical: Responsive.spacing(context, mobile: 14),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                Responsive.borderRadius(context, mobile: 12),
              ),
              border: Border.all(color: AppColor.borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColor.textSecondaryColor,
                  size: Responsive.iconSize(context, mobile: 20),
                ),
                SizedBox(width: Responsive.spacing(context, mobile: 12)),
                Expanded(
                  child: Text(
                    controller.selectedDate != null
                        ? '${controller.selectedDate!.year}-${controller.selectedDate!.month.toString().padLeft(2, '0')}-${controller.selectedDate!.day.toString().padLeft(2, '0')}'
                        : 'Select new due date',
                    style: TextStyle(
                      color: controller.selectedDate != null
                          ? AppColor.textColor
                          : AppColor.textSecondaryColor,
                      fontSize: Responsive.fontSize(context, mobile: 14),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColor.textSecondaryColor,
                  size: Responsive.iconSize(context, mobile: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField(
    BuildContext context,
    RequestDelayController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 14),
            fontWeight: FontWeight.w500,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 8)),
        TextFormField(
          controller: controller.reasonController,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          style: TextStyle(
            color: AppColor.textColor,
            fontSize: Responsive.fontSize(context, mobile: 14),
          ),
          decoration: InputDecoration(
            hintText: 'Enter the reason for requesting delay...',
            hintStyle: TextStyle(
              color: AppColor.textSecondaryColor,
              fontSize: Responsive.fontSize(context, mobile: 14),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                Responsive.borderRadius(context, mobile: 12),
              ),
              borderSide: BorderSide(color: AppColor.borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                Responsive.borderRadius(context, mobile: 12),
              ),
              borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.spacing(context, mobile: 16),
              vertical: Responsive.spacing(context, mobile: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    RequestDelayController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading ? null : () => controller.requestDelay(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: Responsive.spacing(context, mobile: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.borderRadius(context, mobile: 12),
            ),
          ),
          elevation: 0,
        ),
        child: controller.isLoading
            ? SizedBox(
                height: Responsive.size(context, mobile: 20),
                width: Responsive.size(context, mobile: 20),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Request Delay',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, mobile: 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String errorMessage) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 12)),
      decoration: BoxDecoration(
        color: AppColor.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 8),
        ),
        border: Border.all(
          color: AppColor.errorColor.withOpacity(0.3),
          width: 1,
        ),
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
              errorMessage,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 14),
                color: AppColor.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

