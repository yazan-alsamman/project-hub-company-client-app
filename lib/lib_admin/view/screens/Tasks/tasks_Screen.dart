import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/common/customDrawer_controller.dart';
import '../../../controller/task/tasks_controller.dart';
import '../../../controller/common/filter_button_controller.dart';
import '../../../core/class/statusrequest.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/routes.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/filter_button.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/task_card.dart';
import '../../../data/Models/task_model.dart';
import '../../../data/repository/tasks_repository.dart';
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
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
        child: GetBuilder<TasksControllerImp>(
        init: Get.find<TasksControllerImp>(),
        builder: (controller) {
          if (controller.statusRequest == StatusRequest.loading &&
              controller.allTasks.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }
          if ((controller.statusRequest == StatusRequest.serverFailure ||
                  controller.statusRequest == StatusRequest.offlineFailure ||
                  controller.statusRequest == StatusRequest.serverException ||
                  controller.statusRequest == StatusRequest.timeoutException) &&
              controller.allTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColor.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => controller.refreshTasks(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => controller.refreshTasks(),
            color: AppColor.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    color: AppColor.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Header(
                            title: "Tasks",
                            subtitle: "Track and manage all your project tasks",
                            buttonText: "New Task",
                            buttonIcon: Icons.add,
                            onPressed: () {
                              Get.toNamed(AppRoute.addTask);
                            },
                          ),
                          const SizedBox(height: 30),
                          GetBuilder<FilterButtonController>(
                            builder: (filterController) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.update();
                              });
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_alt_outlined,
                                      color: AppColor.textSecondaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    FilterButton(
                                      text: "All",
                                      isSelected:
                                          filterController.selectedFilter ==
                                          'All',
                                      onPressed: () {
                                        filterController.selectFilter('All');
                                        controller.update();
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    FilterButton(
                                      text: "In Progress",
                                      isSelected:
                                          filterController.selectedFilter ==
                                          'In Progress',
                                      onPressed: () {
                                        filterController.selectFilter(
                                          'In Progress',
                                        );
                                        controller.update();
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    FilterButton(
                                      text: "Completed",
                                      isSelected:
                                          filterController.selectedFilter ==
                                          'Completed',
                                      onPressed: () {
                                        filterController.selectFilter(
                                          'Completed',
                                        );
                                        controller.update();
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    FilterButton(
                                      text: "Pending",
                                      isSelected:
                                          filterController.selectedFilter ==
                                          'Pending',
                                      onPressed: () {
                                        filterController.selectFilter(
                                          'Pending',
                                        );
                                        controller.update();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All Tasks",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GetBuilder<FilterButtonController>(
                          builder: (filterController) {
                            final filteredTasks = controller.filteredTasks;
                            if (filteredTasks.isEmpty &&
                                !controller.isLoading &&
                                controller.statusRequest ==
                                    StatusRequest.success) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.task_outlined,
                                        size: 64,
                                        color: AppColor.textSecondaryColor,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No tasks found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColor.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: filteredTasks.map((task) {
                                Color priorityColor;
                                Color avatarColor;
                                bool isCompleted = task.status == 'Completed';
                                bool isPending = task.status == 'Pending';
                                switch (task.priorityColor) {
                                  case 'error':
                                    priorityColor = AppColor.errorColor;
                                    break;
                                  case 'orange':
                                    priorityColor = Colors.orange;
                                    break;
                                  case 'green':
                                    priorityColor = Colors.green;
                                    break;
                                  default:
                                    priorityColor = AppColor.errorColor;
                                }
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
                                  default:
                                    avatarColor = AppColor.primaryColor;
                                }
                                return TaskCard(
                                  title: task.title,
                                  subtitle: task.subtitle,
                                  category: task.category,
                                  priority: task.priority,
                                  dueDate: task.dueDate,
                                  assigneeName: task.assigneeName,
                                  assigneeInitials: task.assigneeInitials,
                                  priorityColor: priorityColor,
                                  avatarColor: avatarColor,
                                  isCompleted: isCompleted,
                                  isPending: isPending,
                                  onEdit: () {
                                    Get.toNamed(
                                      AppRoute.editTask,
                                      arguments: task.id,
                                    );
                                  },
                                  onDelete: () {
                                    _handleDeleteTask(
                                      context,
                                      task,
                                      controller,
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
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
  void _handleDeleteTask(
    BuildContext context,
    TaskModel task,
    TasksControllerImp controller,
  ) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Delete Task',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${task.title}? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: AppColor.textColor),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColor.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColor.errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) {
      return;
    }
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final tasksRepository = TasksRepository();
      final result = await tasksRepository.deleteTask(task.id);
      Get.back(); // Close loading dialog
      result.fold(
        (error) {
          String errorMsg = 'Failed to delete task';
          if (error == StatusRequest.serverFailure) {
            errorMsg = 'Server error. Please try again.';
          } else if (error == StatusRequest.offlineFailure) {
            errorMsg = 'No internet connection. Please check your network.';
          } else if (error == StatusRequest.timeoutException) {
            errorMsg = 'Request timed out. Please try again.';
          } else if (error == StatusRequest.serverException) {
            errorMsg = 'An unexpected server error occurred.';
          }
          Get.snackbar(
            'Error',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.errorColor,
            colorText: AppColor.white,
            icon: const Icon(
              Icons.error_outline,
              color: AppColor.white,
              size: 28,
            ),
            duration: const Duration(seconds: 5),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
        },
        (success) {
          controller.refreshTasks();
          Get.snackbar(
            'Success',
            'Task deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.successColor,
            colorText: AppColor.white,
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColor.white,
              size: 28,
            ),
            duration: const Duration(seconds: 2),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
        },
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        icon: const Icon(Icons.error_outline, color: AppColor.white, size: 28),
        duration: const Duration(seconds: 5),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
