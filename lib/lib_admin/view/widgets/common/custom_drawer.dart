import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/imageassets.dart';
import '../../../core/constant/routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repository/auth_repository.dart';
import 'build_menu_item.dart';

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
    final authService = AuthService();
    final username = await authService.getUsername();
    final email = await authService.getUserEmail();
    final role = await authService.getUserRole();
    if (mounted) {
      setState(() {
        _username = username;
        _email = email;
        _userRole = role;
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
                  colors: [AppColor.primaryColor, AppColor.gradientStart],
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
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          AppImageAsset.appIcon,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            );
                          },
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
                                        color: Colors.white.withOpacity(0.9),
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
                    icon: Icons.group,
                    title: 'Team',
                    onTap: () {
                      if (widget.onItemTap != null) {
                        widget.onItemTap!('Team');
                      }
                      Get.back();
                      Get.offAllNamed(AppRoute.team);
                    },
                  ),
                  buildMenuItem(
                    icon: Icons.assignment,
                    title: 'Tasks',
                    onTap: () {
                      if (widget.onItemTap != null) {
                        widget.onItemTap!('Tasks');
                      }
                      Get.back();
                      Get.offAllNamed(AppRoute.tasks);
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
                      Get.offAllNamed(AppRoute.settings);
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
                      Get.offAllNamed(AppRoute.projects);
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
                      Get.offAllNamed(AppRoute.analytics);
                    },
                  ),
                  buildMenuItem(
                    icon: Icons.dashboard,
                    title: 'Project Dashboard',
                    onTap: () {
                      if (widget.onItemTap != null) {
                        widget.onItemTap!('Project Dashboard');
                      }
                      Get.back();
                      Get.offAllNamed(AppRoute.projectDashboard);
                    },
                  ),
                  buildMenuItem(
                    icon: Icons.assignment_ind,
                    title: 'Assignment',
                    onTap: () {
                      if (widget.onItemTap != null) {
                        widget.onItemTap!('Assignment');
                      }
                      Get.back();
                      Get.offAllNamed(AppRoute.assignments);
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
                        Get.toNamed(AppRoute.addClient);
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
