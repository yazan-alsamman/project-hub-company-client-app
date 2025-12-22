import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';
import 'package:project_hub/lib_client/core/constant/routes.dart';
import 'package:project_hub/lib_client/controller/auth_controller.dart';
import 'package:project_hub/lib_client/data/repository/auth_repository.dart';
import 'package:project_hub/lib_client/view/widgets/common/build_menu_item.dart';

class CustomDrawer extends StatefulWidget {
  final Function(String)? onItemTap;
  const CustomDrawer({super.key, this.onItemTap});
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? _username;
  String? _email;
  String? _userRole;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      setState(() {
        _username = authController.username;
        _email = authController.email;
        _userRole = authController.userRole;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _canAddClient() {
    if (_userRole == null) return false;
    final roleLower = _userRole!.toLowerCase();
    return roleLower == 'admin' || roleLower == 'pm';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primaryColor, AppColor.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isLoading
                            ? const SizedBox(
                                height: 40,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _username ?? 'User',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_email != null && _email!.isNotEmpty)
                                    Text(
                                      _email!,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildMenuItem(
                    icon: Icons.assignment,
                    title: 'Tasks',
                    onTap: () {
                      if (widget.onItemTap != null) {
                        widget.onItemTap!('Tasks');
                      }
                      Get.back();
                      Get.offAllNamed(AppRoute.tasksPage);
                    },
                  ),
                  buildMenuItem(
                    icon: Icons.folder,
                    title: 'Projects',
                    onTap: () {
                      if (widget.onItemTap != null) {
                        widget.onItemTap!('Projects');
                      }
                      Get.back();
                      Get.toNamed(AppRoute.projects);
                    },
                  ),
                  buildMenuItem(
                    icon: Icons.analytics,
                    title: 'Analytics',
                    onTap: () {
                      if (widget.onItemTap != null) {
                        widget.onItemTap!('Analytics');
                      }
                      Get.back();
                      Get.toNamed(AppRoute.analytics);
                    },
                  ),
                  buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      if (widget.onItemTap != null) {
                        widget.onItemTap!('Settings');
                      }
                      Get.back();
                      Get.toNamed(AppRoute.settings);
                    },
                  ),
                  buildMenuItem(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      if (widget.onItemTap != null) {
                        widget.onItemTap!('Profile');
                      }
                      Get.back();
                      Get.toNamed(AppRoute.profile);
                    },
                  ),
                  if (_canAddClient())
                    buildMenuItem(
                      icon: Icons.person,
                      title: 'Clients',
                      onTap: () {
                        if (widget.onItemTap != null) {
                          widget.onItemTap!('Clients');
                        }
                        Get.back();
                      },
                    ),
                ],
              ),
            ),
            Divider(color: AppColor.borderColor, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: Icon(Icons.logout, color: AppColor.errorColor),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColor.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  final authRepository = AuthRepository();
                  final result = await authRepository.logout();
                  result.fold(
                    (error) {
                      Get.offAllNamed(AppRoute.login);
                    },
                    (success) {
                      Get.offAllNamed(AppRoute.login);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
