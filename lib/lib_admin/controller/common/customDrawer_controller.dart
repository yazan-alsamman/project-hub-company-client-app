import 'package:get/get.dart';
abstract class CustomDrawerController extends GetxController {
  void onMenuItemTap(String item);
}
class CustomDrawerControllerImp extends GetxController {
  void onMenuItemTap(String item) {
    Get.back(); // إغلاق الـ drawer
    print('Selected menu item: $item');
  }
}
