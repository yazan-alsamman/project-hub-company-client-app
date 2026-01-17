import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/common/customDrawer_controller.dart';
import '../../../controller/task/tasks_controller.dart';
import '../../../controller/common/filter_button_controller.dart';
import '../../../core/class/statusrequest.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/routes.dart';
import '../../../core/services/auth_service.dart';
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
    // Ensure controllers are registered before use
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    if (!Get.isRegistered<TasksControllerImp>()) {
      Get.put(TasksControllerImp());
    }
    if (!Get.isRegistered<FilterButtonController>()) {
      Get.put(FilterButtonController());
    }
    
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
                          FutureBuilder<String?>(
                            future: AuthService().getUserRole(),
                            builder: (context, snapshot) {
                              final role = snapshot.data?.toLowerCase() ?? '';
                              final canAddTask = role != 'developer';
                              return Header(
                                title: "Tasks",
                                subtitle: "Track and manage all your project tasks",
                                buttonText: canAddTask ? "New Task" : null,
                                buttonIcon: canAddTask ? Icons.add : null,
                                haveButton: canAddTask,
                                onPressed: canAddTask
                                    ? () {
                                        Get.toNamed(AppRoute.addTask);
                                      }
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          GetBuilder<TasksControllerImp>(
                            builder: (tasksController) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColor.borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.folder_outlined,
                                      color: AppColor.textSecondaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String?>(
                                          value: tasksController.selectedProjectId,
                                          isExpanded: true,
                                          hint: Text(
                                            'Select Project',
                                            style: TextStyle(
                                              color: AppColor.textSecondaryColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          items: [
                                            DropdownMenuItem<String?>(
                                              value: null,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.view_list,
                                                    size: 18,
                                                    color: AppColor.primaryColor,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'View All Tasks',
                                                    style: TextStyle(
                                                      color: AppColor.textColor,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            ...tasksController.projects.map(
                                              (project) => DropdownMenuItem<String?>(
                                                value: project.id,
                                                child: Text(
                                                  project.title,
                                                  style: TextStyle(
                                                    color: AppColor.textColor,
                                                    fontSize: 14,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                          onChanged: (String? projectId) {
                                            if (projectId == null) {
                                              tasksController.viewAllTasks();
                                            } else {
                                              tasksController.selectProject(projectId);
                                            }
                                          },
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: AppColor.textSecondaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (tasksController.selectedProjectId != null)
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: AppColor.textSecondaryColor,
                                        ),
                                        onPressed: () {
                                          tasksController.viewAllTasks();
                                        },
                                        tooltip: 'Clear filter',
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          GetBuilder<FilterButtonController>(
                            init: Get.isRegistered<FilterButtonController>()
                                ? Get.find<FilterButtonController>()
                                : Get.put(FilterButtonController()),
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
                        FutureBuilder<String?>(
                          future: AuthService().getUserRole(),
                          builder: (context, roleSnapshot) {
                            return GetBuilder<FilterButtonController>(
                              init: Get.isRegistered<FilterButtonController>()
                                  ? Get.find<FilterButtonController>()
                                  : Get.put(FilterButtonController()),
                              builder: (filterController) {
                                final filteredTasks = controller.filteredTasks;
                                final userRole = roleSnapshot.data?.toLowerCase() ?? '';
                                final isDeveloper = userRole == 'developer';
                                final isPM = userRole == 'pm';
                                final isAdmin = userRole == 'admin';
                                final canViewTaskDetail = isDeveloper || isPM || isAdmin;
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
                                      showAssignee: !isDeveloper,
                                      delayRequests: task.delayRequests,
                                      onTap: canViewTaskDetail
                                          ? () {
                                              final userRole = roleSnapshot.data?.toLowerCase() ?? '';
                                              if (userRole == 'admin') {
                                                Get.toNamed(
                                                  AppRoute.taskComments,
                                                  arguments: task,
                                                );
                                              } else {
                                                Get.toNamed(
                                                  AppRoute.taskDetail,
                                                  arguments: task,
                                                );
                                              }
                                            }
                                          : null,
                                      onEdit: isDeveloper
                                          ? null
                                          : () {
                                              Get.toNamed(
                                                AppRoute.editTask,
                                                arguments: task.id,
                                              );
                                            },
                                      onDelete: isDeveloper
                                          ? null
                                          : () {
                                              _handleDeleteTask(
                                                context,
                                                task,
                                                controller,
                                              );
                                            },
                                      onRequestDelay: isDeveloper
                                          ? () {
                                              Get.toNamed(
                                                AppRoute.requestDelay,
                                                arguments: task,
                                              );
                                            }
                                          : null,
                                      onMarkCompleted: isDeveloper && !isCompleted
                                          ? () {
                                              _handleMarkAsCompleted(
                                                context,
                                                task.id,
                                                controller,
                                              );
                                            }
                                          : null,
                                    );
                                  }).toList(),
                                );
                              },
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
      Get.back();
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
      Get.back();
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

  void _handleMarkAsCompleted(
    BuildContext context,
    String taskId,
    TasksControllerImp controller,
  ) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Mark as Completed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to mark this task as completed?',
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
              'Mark as Completed',
              style: TextStyle(
                color: AppColor.successColor,
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
    await controller.markTaskAsCompleted(taskId);
  }
}
