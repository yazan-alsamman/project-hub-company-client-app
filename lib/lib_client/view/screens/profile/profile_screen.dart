import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/controller/common/custom_drawer_controller.dart';
import 'package:project_hub/lib_client/controller/common/profile_controller.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';
import 'package:project_hub/lib_client/core/constant/responsive.dart';
import 'package:project_hub/lib_client/view/widgets/custom_app_bar.dart';
import 'package:project_hub/lib_client/view/widgets/common/custom_drawer.dart';
import 'package:project_hub/lib_client/view/widgets/common/header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CustomDrawerControllerImp>()) {
      Get.put(CustomDrawerControllerImp());
    }
    final CustomDrawerControllerImp customDrawerController =
        Get.find<CustomDrawerControllerImp>();
    Get.put(ProfileController());
    return Scaffold(
      drawer: CustomDrawer(
        onItemTap: (item) {
          customDrawerController.onMenuItemTap(item);
        },
      ),
      appBar: const CustomAppBar(title: 'Profile', showBackButton: true),
      body: SafeArea(
        child: GetBuilder<ProfileController>(
          builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: AppColor.backgroundColor,
                  child: Padding(
                    padding: Responsive.padding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Header(
                          title: "Profile",
                          subtitle: "View and manage your account information",
                          haveButton: false,
                        ),
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Container(
                                  width: Responsive.size(context, mobile: 100),
                                  height: Responsive.size(context, mobile: 100),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColor.primaryColor,
                                        AppColor.secondaryColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.primaryColor
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: Responsive.size(context, mobile: 50),
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  controller.username ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(
                                      context,
                                      mobile: 24,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  controller.email ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(
                                      context,
                                      mobile: 16,
                                    ),
                                    color: AppColor.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (controller.role != null &&
                                    controller.role!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      controller.role!.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(
                                          context,
                                          mobile: 12,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: Responsive.padding(context),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        context,
                        icon: Icons.badge,
                        title: 'User ID',
                        value: controller.userId ?? 'N/A',
                        color: AppColor.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        icon: Icons.email,
                        title: 'Email',
                        value: controller.email ?? 'N/A',
                        color: AppColor.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        icon: Icons.person,
                        title: 'Username',
                        value: controller.username ?? 'N/A',
                        color: AppColor.successColor,
                      ),
                      const SizedBox(height: 16),
                      if (controller.role != null &&
                          controller.role!.isNotEmpty)
                        _buildInfoCard(
                          context,
                          icon: Icons.work,
                          title: 'Role',
                          value: controller.role!,
                          color: AppColor.warningColor,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 12),
                      color: AppColor.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 16),
                      color: AppColor.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

