import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';
import 'package:project_hub/lib_client/core/constant/responsive.dart';
import 'package:project_hub/lib_client/core/constant/routes.dart';
import 'package:project_hub/lib_client/controller/custom_app_bar_controller.dart';
import 'package:project_hub/lib_client/data/repository/auth_repository.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showSearch;
  final bool showNotifications;
  final bool showUserProfile;
  final bool showHamburgerMenu;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    this.title,
    this.showSearch = true,
    this.showNotifications = true,
    this.showUserProfile = true,
    this.showHamburgerMenu = true,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // Try to get controller safely
    try {
      final controller = Get.find<ClientCustomappbarControllerImp>();
      return _buildAppBarWithController(controller);
    } catch (e) {
      // If controller not found, return simple AppBar
      return AppBar(backgroundColor: AppColor.backgroundColor, elevation: 0);
    }
  }

  Widget _buildAppBarWithController(
    ClientCustomappbarControllerImp controller,
  ) {
    return Builder(
      builder: (context) => AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Back Button
            if (showBackButton) ...[
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppColor.textColor,
                  size: Responsive.iconSize(context, mobile: 20),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8)),
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 18),
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor,
                    ),
                  ),
                ),
            ] else ...[
              // Hamburger Menu
              if (showHamburgerMenu) ...[
                _buildHamburgerMenu(context),
                SizedBox(width: Responsive.spacing(context, mobile: 16)),
              ],

              // Search Bar
              if (showSearch) ...[
                Expanded(child: _buildSearchBar(context, controller)),
                SizedBox(width: Responsive.spacing(context, mobile: 12)),
              ],

              // Search Icon (hidden on mobile)
              if (showSearch && !Responsive.isMobile(context)) ...[
                _buildSearchIcon(context),
                SizedBox(width: Responsive.spacing(context, mobile: 16)),
              ],

              // Notification Bell
              if (showNotifications) ...[
                _buildNotificationBell(context, controller),
                SizedBox(width: Responsive.spacing(context, mobile: 16)),
              ],

              // User Profile with Popup Menu
              if (showUserProfile) ...[_buildUserProfile(context, controller)],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHamburgerMenu(BuildContext context) {
    return Builder(
      builder: (builderContext) => GestureDetector(
        onTap: () {
          // Open drawer on mobile
          if (Responsive.isMobile(builderContext)) {
            Scaffold.of(builderContext).openDrawer();
          }
        },
        child: Container(
          padding: EdgeInsets.all(Responsive.spacing(context, mobile: 8)),
          child: Icon(
            Icons.menu,
            color: AppColor.textSecondaryColor,
            size: Responsive.iconSize(context, mobile: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    ClientCustomappbarControllerImp controller,
  ) {
    return Container(
      height: Responsive.size(context, mobile: 40),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 20),
        ),
        border: Border.all(color: AppColor.borderColor, width: 1),
      ),
      child: TextField(
        onChanged: (query) {
          controller.updateSearchQuery(query);
        },
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: AppColor.textSecondaryColor,
            fontSize: Responsive.fontSize(context, mobile: 14),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.spacing(context, mobile: 16),
            vertical: Responsive.spacing(context, mobile: 12),
          ),
        ),
        style: TextStyle(
          color: AppColor.textColor,
          fontSize: Responsive.fontSize(context, mobile: 14),
        ),
      ),
    );
  }

  Widget _buildSearchIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Search icon action (optional)
      },
      child: Container(
        padding: EdgeInsets.all(Responsive.spacing(context, mobile: 8)),
        child: Icon(
          Icons.search,
          color: AppColor.textSecondaryColor,
          size: Responsive.iconSize(context, mobile: 24),
        ),
      ),
    );
  }

  Widget _buildNotificationBell(
    BuildContext context,
    ClientCustomappbarControllerImp controller,
  ) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          controller.onNotificationTap();
          _showNotificationDialog(controller.notificationCount.value);
        },
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.spacing(context, mobile: 8)),
              child: Icon(
                Icons.notifications_outlined,
                color: AppColor.textSecondaryColor,
                size: Responsive.iconSize(context, mobile: 24),
              ),
            ),
            if (controller.notificationCount.value > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: Responsive.size(context, mobile: 12),
                  height: Responsive.size(context, mobile: 12),
                  decoration: BoxDecoration(
                    color: AppColor.errorColor,
                    borderRadius: BorderRadius.circular(
                      Responsive.size(context, mobile: 6),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(
    BuildContext context,
    ClientCustomappbarControllerImp controller,
  ) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Responsive.size(context, mobile: 36),
            height: Responsive.size(context, mobile: 36),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.primaryColor, AppColor.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                Responsive.size(context, mobile: 18),
              ),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: Responsive.iconSize(context, mobile: 20),
            ),
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 4)),
          Icon(
            Icons.keyboard_arrow_down,
            color: AppColor.textSecondaryColor,
            size: Responsive.iconSize(context, mobile: 16),
          ),
        ],
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, color: AppColor.primaryColor, size: 20),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              const Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: AppColor.errorColor, size: 20),
              SizedBox(width: Responsive.spacing(context, mobile: 12)),
              Text('Logout', style: TextStyle(color: AppColor.errorColor)),
            ],
          ),
        ),
      ],
      onSelected: (String value) async {
        if (value == 'profile') {
          Get.toNamed(AppRoute.profile);
        } else if (value == 'logout') {
          // Show confirmation dialog
          final shouldLogout = await Get.dialog<bool>(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.errorColor,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            // Call logout API
            final authRepository = AuthRepository();
            final result = await authRepository.logout();

            result.fold(
              (error) {
                // Even if logout API fails, clear local data and navigate
                Get.offAllNamed(AppRoute.login);
              },
              (success) {
                // Logout successful, navigate to login
                Get.offAllNamed(AppRoute.login);
              },
            );
          }
        }
      },
    );
  }

  void _showNotificationDialog(int count) {
    Get.dialog(
      AlertDialog(
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count == 0)
              const Text('No new notifications')
            else
              Text('You have $count new notifications'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
