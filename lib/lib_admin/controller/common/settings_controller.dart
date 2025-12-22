import 'package:flutter/material.dart';
import 'package:get/get.dart';
abstract class SettingsController extends GetxController {}
class SettingsControllerImp extends SettingsController {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController adminEmailController = TextEditingController();
  String selectedTimezone = 'UTC';
  String selectedLanguage = 'English';
  bool enableNotifications = false;
  bool emailNotifications = false;
  bool pushNotifications = false;
  void updateTimezone(String timezone) {
    selectedTimezone = timezone;
    update();
  }
  void updateLanguage(String language) {
    selectedLanguage = language;
    update();
  }
  void toggleNotifications(bool value) {
    enableNotifications = value;
    update();
  }
  void toggleEmailNotifications(bool value) {
    emailNotifications = value;
    update();
  }
  void togglePushNotifications(bool value) {
    pushNotifications = value;
    update();
  }
  void navigateToChangePassword() {
    print('Navigate to Change Password');
  }
  void navigateToApiKeys() {
    print('Navigate to API Keys');
  }
  void navigateToManageMembers() {
    print('Navigate to Manage Members');
  }
  void navigateToRolesPermissions() {
    print('Navigate to Roles & Permissions');
  }
  void navigateToBilling() {
    print('Navigate to Billing');
  }
  @override
  void onClose() {
    companyNameController.dispose();
    adminEmailController.dispose();
    super.onClose();
  }
}
