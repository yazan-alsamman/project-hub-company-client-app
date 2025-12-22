import 'package:get/get.dart';
abstract class CustomappbarController extends GetxController {
  void updateNotificationCount(int count);
  void addNotification();
  void clearNotifications();
  void updateSearchQuery(String query);
  void onNotificationTap();
  void onUserProfileTap();
  void onMenuItemTap(String item);
}
class CustomappbarControllerImp extends GetxController {
  var notificationCount = 3.obs;
  var searchQuery = ''.obs;
  void updateNotificationCount(int count) {
    notificationCount.value = count;
  }
  void addNotification() {
    notificationCount.value++;
  }
  void clearNotifications() {
    notificationCount.value = 0;
  }
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  void onNotificationTap() {
    clearNotifications();
  }
  void onUserProfileTap() {
    print('User profile tapped');
  }
}
