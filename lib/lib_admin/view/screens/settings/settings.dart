import 'package:flutter/material.dart';
import '../../../controller/common/customDrawer_controller.dart';
import 'package:get/get.dart';
import '../../../controller/common/settings_controller.dart';
import '../../../core/functions/validinput.dart';
import '../../widgets/common/input_fields.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/main_button.dart';
import '../../widgets/common/timezone_picker.dart';
import '../../widgets/common/language_picker.dart';
import '../../widgets/common/setting_card.dart';
import '../../widgets/common/security_setting_card.dart';
import '../../widgets/common/team_setting_card.dart';
import '../../../core/constant/color.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
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
        child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColor.backgroundColor,
              child: GetBuilder<SettingsControllerImp>(
                builder: (controller) => Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Header(
                        title: "Settings",
                        subtitle: "Configure your workspace preferences",
                        haveButton: false,
                      ),
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                              spreadRadius: 0,
                            ),
                          ],
                          border: Border.all(
                            color: AppColor.borderColor,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        width: double.infinity,
                        height: 480,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      size: 35,
                                      color: AppColor.gradientMiddle,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "General",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Company Name",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.textColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                InputFields(
                                  controller: controller.companyNameController,
                                  hintText: "Enter company name",
                                  valid: (val) {
                                    return validInput(val!, 3, 30);
                                  },
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Admin Email",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.textColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                InputFields(
                                  controller: controller.adminEmailController,
                                  hintText: "Enter admin email",
                                  valid: (val) {
                                    return validInput(val!, 3, 30);
                                  },
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Timezone",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.textColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TimezonePicker(
                                  selectedTimezone: controller.selectedTimezone,
                                  onTimezoneSelected: (timezone) {
                                    controller.updateTimezone(timezone);
                                  },
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Language",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.textColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                LanguagePicker(
                                  selectedLanguage: controller.selectedLanguage,
                                  onLanguageSelected: (language) {
                                    controller.updateLanguage(language);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 1),
                  GetBuilder<SettingsControllerImp>(
                    builder: (controller) => Column(
                      children: [
                        SettingCard(
                          icon: Icons.notifications,
                          iconColor: AppColor.gradientMiddle,
                          title: "Notifications",
                          settingTitle: "Enable Notifications",
                          description: "Receive in-app notifications",
                          value: controller.enableNotifications,
                          onChanged: (value) {
                            controller.toggleNotifications(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetBuilder<SettingsControllerImp>(
                    builder: (controller) => SecuritySettingCard(
                      icon: Icons.lock,
                      iconColor: AppColor.gradientMiddle,
                      title: "Security",
                      items: [
                        SecurityItem(
                          title: "Change Password",
                          description: "Update your password",
                          onTap: () {
                            controller.navigateToChangePassword();
                          },
                        ),
                        SecurityItem(
                          title: "API Keys",
                          description: "Manage API access",
                          onTap: () {
                            controller.navigateToApiKeys();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetBuilder<SettingsControllerImp>(
                    builder: (controller) => TeamSettingCard(
                      icon: Icons.group,
                      iconColor: AppColor.gradientMiddle,
                      title: "Team",
                      items: [
                        TeamItem(
                          title: "Manage Members",
                          description: "Add or remove team members",
                          onTap: () {
                            controller.navigateToManageMembers();
                          },
                        ),
                        TeamItem(
                          title: "Roles & Permissions",
                          description: "Set user permissions",
                          onTap: () {
                            controller.navigateToRolesPermissions();
                          },
                        ),
                        TeamItem(
                          title: "Billing",
                          description: "Manage team billing and subscription",
                          onTap: () {
                            controller.navigateToBilling();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: MainButton(
                onPressed: () {},
                text: "Save changes",
                icon: Icons.save_outlined,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
