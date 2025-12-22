import 'package:get/get.dart';

class ClientCustomappbarControllerImp extends GetxController {
  // Search query
  final RxString searchQuery = ''.obs;

  // Notification count
  final RxInt notificationCount = 0.obs;

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Handle notification tap
  void onNotificationTap() {
    // Add your notification logic here
    // For example, mark notifications as read
    if (notificationCount.value > 0) {
      notificationCount.value = 0;
    }
  }

  // Handle user profile tap
  void onUserProfileTap() {
    // Add your user profile logic here
  }

  // Initialize notification count (you can load from API)
  void initializeNotifications() {
    // Example: Load notification count from API
    notificationCount.value = 1; // As per design - shows "1"
  }

  @override
  void onInit() {
    super.onInit();
    initializeNotifications();
  }
}
