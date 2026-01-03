import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/task_card.dart';
import '../../../controller/common/customDrawer_controller.dart';
import '../../../controller/ai_assistance/ai_assistance_controller.dart';

class AiAssistanceScreen extends StatefulWidget {
  const AiAssistanceScreen({super.key});

  @override
  State<AiAssistanceScreen> createState() => _AiAssistanceScreenState();
}

class _AiAssistanceScreenState extends State<AiAssistanceScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tasksStartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }

    if (!Get.isRegistered<AiAssistanceControllerImp>()) {
      Get.put(AiAssistanceControllerImp());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTasks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tasksStartKey.currentContext != null) {
        Scrollable.ensureVisible(
          _tasksStartKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
        child: GetBuilder<AiAssistanceControllerImp>(
          builder: (controller) {
            return SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                color: AppColor.backgroundColor,
                child: Padding(
                  padding: Responsive.padding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'AI Assistance',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 28),
                          fontWeight: FontWeight.bold,
                          color: AppColor.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate tasks using AI based on your description',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 16),
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: controller.formState,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Task Description',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(
                                    context,
                                    mobile: 18,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller:
                                    controller.projectDescriptionController,
                                maxLines: 8,
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter a description of the project you want to generate tasks for it...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: Responsive.fontSize(
                                      context,
                                      mobile: 16,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColor.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(
                                    context,
                                    mobile: 16,
                                  ),
                                  color: AppColor.textColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Number of Tasks',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(
                                    context,
                                    mobile: 18,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: controller.numTasksController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter number of tasks (10-200)',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: Responsive.fontSize(
                                      context,
                                      mobile: 16,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColor.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColor.errorColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColor.errorColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(
                                    context,
                                    mobile: 16,
                                  ),
                                  color: AppColor.textColor,
                                ),
                                validator: controller.validateNumTasks,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading
                                      ? null
                                      : () {
                                          if (controller.formState.currentState!
                                              .validate()) {
                                            final numTasks =
                                                int.tryParse(
                                                  controller
                                                      .numTasksController
                                                      .text,
                                                ) ??
                                                10;
                                            controller.generateTasks(
                                              controller
                                                  .projectDescriptionController
                                                  .text
                                                  .trim(),
                                              numTasks,
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          'Generate Tasks',
                                          style: TextStyle(
                                            fontSize: Responsive.fontSize(
                                              context,
                                              mobile: 16,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.generatedTasks.isNotEmpty) ...[
                        const SizedBox(height: 40),
                        Column(
                          key: _tasksStartKey,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.viewAll
                                      ? 'All Tasks (${controller.generatedTasks.length})'
                                      : 'Generated Tasks (${controller.displayedTasks.length}/${controller.generatedTasks.length})',
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(
                                      context,
                                      mobile: 20,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.textColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (controller.needsPagination)
                                      TextButton.icon(
                                        onPressed: () {
                                          controller.toggleViewAll();
                                        },
                                        icon: Icon(
                                          controller.viewAll
                                              ? Icons.view_list
                                              : Icons.view_agenda,
                                          size: 18,
                                        ),
                                        label: Text(
                                          controller.viewAll
                                              ? 'View Pages'
                                              : 'View All',
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppColor.primaryColor,
                                        ),
                                      ),
                                    TextButton.icon(
                                      onPressed: () {
                                        // TODO: Implement accept tasks functionality
                                      },
                                      icon: const Icon(
                                        Icons.check_circle,
                                        size: 18,
                                      ),
                                      label: const Text('Accept Tasks'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColor.successColor,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        controller.clearGeneratedTasks();
                                      },
                                      icon: const Icon(Icons.clear, size: 18),
                                      label: const Text('Clear'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColor.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (controller.generationTime != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppColor.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Generation time: ${controller.generationTime!.toStringAsFixed(2)} seconds',
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(
                                        context,
                                        mobile: 14,
                                      ),
                                      color: AppColor.textSecondaryColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...controller.displayedTasks.map(
                          (task) => _buildTaskCardFromModel(context, task),
                        ),
                        if (controller.needsPagination &&
                            !controller.viewAll) ...[
                          const SizedBox(height: 24),
                          _buildPagination(context, controller),
                        ],
                      ],
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

  Widget _buildPagination(
    BuildContext context,
    AiAssistanceControllerImp controller,
  ) {
    final totalPages = controller.totalPages;
    final currentPage = controller.currentPage;

    List<int> pageNumbers = [];
    if (totalPages <= 7) {
      for (int i = 1; i <= totalPages; i++) {
        pageNumbers.add(i);
      }
    } else {
      if (currentPage <= 3) {
        for (int i = 1; i <= 4; i++) {
          pageNumbers.add(i);
        }
        pageNumbers.add(-1);
        pageNumbers.add(totalPages);
      } else if (currentPage >= totalPages - 2) {
        pageNumbers.add(1);
        pageNumbers.add(-1);
        for (int i = totalPages - 3; i <= totalPages; i++) {
          pageNumbers.add(i);
        }
      } else {
        pageNumbers.add(1);
        pageNumbers.add(-1);
        for (int i = currentPage - 1; i <= currentPage + 1; i++) {
          pageNumbers.add(i);
        }
        pageNumbers.add(-1);
        pageNumbers.add(totalPages);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: controller.currentPage > 1
                ? () {
                    controller.previousPage();
                    _scrollToTasks();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: controller.currentPage > 1
                  ? AppColor.primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              foregroundColor: controller.currentPage > 1
                  ? AppColor.primaryColor
                  : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          ...pageNumbers.map((pageNum) {
            if (pageNum == -1) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 16),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
              );
            }
            final isCurrentPage = pageNum == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () {
                  controller.goToPage(pageNum);
                  _scrollToTasks();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentPage
                        ? AppColor.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentPage
                          ? AppColor.primaryColor
                          : AppColor.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    pageNum.toString(),
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 14),
                      fontWeight: isCurrentPage
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrentPage
                          ? AppColor.white
                          : AppColor.textColor,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          IconButton(
            onPressed: controller.currentPage < totalPages
                ? () {
                    controller.nextPage();
                    _scrollToTasks();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: controller.currentPage < totalPages
                  ? AppColor.primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              foregroundColor: controller.currentPage < totalPages
                  ? AppColor.primaryColor
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCardFromModel(BuildContext context, task) {
    Color priorityColor;
    switch (task.priorityColor) {
      case 'error':
        priorityColor = AppColor.errorColor;
        break;
      case 'orange':
        priorityColor = Colors.orange;
        break;
      case 'green':
        priorityColor = AppColor.successColor;
        break;
      default:
        priorityColor = AppColor.primaryColor;
    }

    Color avatarColor;
    switch (task.avatarColor) {
      case 'primary':
        avatarColor = AppColor.primaryColor;
        break;
      case 'purple':
        avatarColor = Colors.purple;
        break;
      case 'blue':
        avatarColor = Colors.blue;
        break;
      case 'orange':
        avatarColor = Colors.orange;
        break;
      case 'green':
        avatarColor = AppColor.successColor;
        break;
      default:
        avatarColor = AppColor.primaryColor;
    }

    final isCompleted = task.status == 'Completed';
    final isPending = task.status == 'Pending';

    return TaskCard(
      title: task.title,
      subtitle: task.subtitle.isNotEmpty ? task.subtitle : 'No description',
      category: task.category,
      priority: task.priority,
      dueDate: task.dueDate,
      assigneeName: task.assigneeName,
      assigneeInitials: task.assigneeInitials,
      priorityColor: priorityColor,
      avatarColor: avatarColor,
      isCompleted: isCompleted,
      isPending: isPending,
    );
  }
}
