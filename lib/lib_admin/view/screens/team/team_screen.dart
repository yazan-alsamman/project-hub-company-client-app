import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/common/customDrawer_controller.dart';
import '../../../controller/employee/team_controller.dart';
import '../../../core/class/statusrequest.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repository/team_repository.dart';
import '../../../data/static/team_members_data.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/info_container.dart';
import '../../widgets/common/member_card.dart';
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}
class _TeamScreenState extends State<TeamScreen> {
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
        child: GetBuilder<TeamControllerImp>(
        init: Get.find<TeamControllerImp>(),
        builder: (controller) {
          debugPrint(
            '🟡 TeamScreen build - Status: ${controller.statusRequest}, Members: ${controller.teamMembers.length}, Loading: ${controller.isLoading}',
          );
          if (controller.statusRequest == StatusRequest.loading &&
              controller.teamMembers.isEmpty) {
            debugPrint('🟡 Showing loading indicator');
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }
          if ((controller.statusRequest == StatusRequest.serverFailure ||
                  controller.statusRequest == StatusRequest.offlineFailure ||
                  controller.statusRequest == StatusRequest.serverException ||
                  controller.statusRequest == StatusRequest.timeoutException) &&
              controller.teamMembers.isEmpty) {
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
                    _getErrorMessage(controller.statusRequest),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => controller.refreshTeamMembers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final stats = controller.getTeamStats();
          final teamMembers = controller.teamMembers;
          debugPrint(
            '🟡 TeamScreen - Stats: $stats, TeamMembers count: ${teamMembers.length}',
          );
          if (teamMembers.isNotEmpty) {
            debugPrint(
              '🟡 First member: ${teamMembers.first.name}, Status: ${teamMembers.first.status}',
            );
            debugPrint(
              '🟡 All members: ${teamMembers.map((m) => '${m.name} (${m.status})').join(", ")}',
            );
          }
          final hasError =
              controller.statusRequest == StatusRequest.serverFailure ||
              controller.statusRequest == StatusRequest.offlineFailure ||
              controller.statusRequest == StatusRequest.serverException ||
              controller.statusRequest == StatusRequest.timeoutException;
          return RefreshIndicator(
            onRefresh: () => controller.refreshTeamMembers(),
            color: AppColor.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (hasError && teamMembers.isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: AppColor.errorColor.withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColor.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getErrorMessage(controller.statusRequest),
                              style: TextStyle(
                                color: AppColor.errorColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => controller.refreshTeamMembers(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
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
                              final canAddEmployee =
                                  role == 'pm' ||
                                  role == 'admin' ||
                                  role == 'superadmin';
                              return Header(
                                title: "Team",
                                subtitle: "Manage your team members and roles",
                                buttonText: canAddEmployee
                                    ? "Add Member"
                                    : null,
                                buttonIcon: canAddEmployee
                                    ? Icons.person_add
                                    : null,
                                haveButton: canAddEmployee,
                                onPressed: canAddEmployee
                                    ? () {
                                        Get.toNamed(AppRoute.addEmployee);
                                      }
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          Column(
                            children: [
                              Row(
                                children: [
                                  InformationContainer(
                                    title: "Total Members",
                                    value: "${stats['total']}",
                                  ),
                                  const SizedBox(width: 20),
                                  InformationContainer(
                                    title: "Active now",
                                    value: "${stats['active']}",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  InformationContainer(
                                    title: "Terminated",
                                    value: "${stats['busy']}",
                                  ),
                                  const SizedBox(width: 20),
                                  InformationContainer(
                                    title: "Away",
                                    value: "${stats['away']}",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  InformationContainer(
                                    title: "Departments",
                                    value: controller.isLoadingStats
                                        ? "..."
                                        : "${controller.departmentsCount}",
                                  ),
                                  const SizedBox(width: 20),
                                  InformationContainer(
                                    title: "Projects",
                                    value: controller.isLoadingStats
                                        ? "..."
                                        : "${controller.projectsCount}",
                                  ),
                                ],
                              ),
                            ],
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Team Members",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColor.textColor,
                              ),
                            ),
                            Text(
                              "${teamMembers.length} members",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (teamMembers.isEmpty &&
                            !controller.isLoading &&
                            controller.statusRequest == StatusRequest.success)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: AppColor.textSecondaryColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No team members found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColor.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ...teamMembers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final member = entry.value;
                          debugPrint(
                            '🟢 [RENDER] Member $index/${teamMembers.length - 1}: ${member.name} (${member.status})',
                          );
                          return Padding(
                            key: ValueKey(member.id ?? '${member.name}_$index'),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MemberCard(
                              name: member.name,
                              position: member.position,
                              status: member.status,
                              statusColor: member.statusColor,
                              icon: member.icon,
                              email: member.email,
                              phone: member.phone,
                              location: member.location,
                              activeProjects: member.activeProjects,
                              onTap: () {
                                Get.toNamed(
                                  AppRoute.memberDetail,
                                  arguments: member,
                                );
                              },
                              onViewProjects: () {
                                debugPrint('View projects for ${member.name}');
                              },
                              onEdit: () {
                                _handleEditMember(context, member, controller);
                              },
                              onDelete: () {
                                _handleDeleteMember(
                                  context,
                                  member,
                                  controller,
                                );
                              },
                            ),
                          );
                        }),
                        if (controller.hasMore && !controller.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Center(
                              child: TextButton(
                                onPressed: () => controller.loadMore(),
                                child: const Text('Load More'),
                              ),
                            ),
                          ),
                        if (controller.isLoading && teamMembers.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColor.primaryColor,
                              ),
                            ),
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
  String _getErrorMessage(StatusRequest statusRequest) {
    switch (statusRequest) {
      case StatusRequest.offlineFailure:
        return 'No internet connection. Please check your network.';
      case StatusRequest.serverFailure:
        return 'Access denied: You do not have permission to view team members.\n\nPlease contact your administrator for access.';
      case StatusRequest.timeoutException:
        return 'Request timeout. Please try again.';
      case StatusRequest.serverException:
        return 'An error occurred. Please try again.';
      default:
        return 'Failed to load team members';
    }
  }
  void _handleEditMember(
    BuildContext context,
    TeamMember member,
    TeamControllerImp controller,
  ) {
    if (member.id != null && member.id!.isNotEmpty) {
      Get.toNamed(AppRoute.editEmployee, arguments: member.id);
    } else {
      Get.snackbar(
        'Error',
        'Employee ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }
  void _handleDeleteMember(
    BuildContext context,
    TeamMember member,
    TeamControllerImp controller,
  ) async {
    if (member.id == null || member.id!.isEmpty) {
      Get.snackbar(
        'Error',
        'Employee ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Delete Member',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${member.name}? This action cannot be undone.',
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
      final teamRepository = TeamRepository();
      final result = await teamRepository.deleteEmployee(member.id!);
      Get.back(); // Close loading dialog
      result.fold(
        (error) {
          String errorMsg = 'Failed to delete employee';
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
          controller.refreshTeamMembers();
          Get.snackbar(
            'Success',
            'Employee deleted successfully',
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
