import 'package:get/get.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize with light mode
    switchToLightMode();
  }
  
  void switchToLightMode() {
    isDarkMode.value = false;
    AppColor.switchToLightMode();
    update();
  }
  
  void switchToDarkMode() {
    isDarkMode.value = true;
    AppColor.switchToDarkMode();
    update();
  }
  
  void toggleTheme() {
    if (isDarkMode.value) {
      switchToLightMode();
    } else {
      switchToDarkMode();
    }
  }
}

