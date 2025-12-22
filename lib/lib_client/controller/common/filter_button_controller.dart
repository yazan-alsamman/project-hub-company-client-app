import 'package:get/get.dart';
import 'package:project_hub/lib_client/controller/project/projects_controller.dart';

class FilterButtonController extends GetxController {
  String selectedFilter = 'All';

  void selectFilter(String filter) {
    selectedFilter = filter;
    update(); // This triggers GetBuilder to rebuild
    if (Get.isRegistered<ProjectsControllerImp>()) {
      Get.find<ProjectsControllerImp>().selectFilter(filter);
    }
  }

  bool isSelected(String filter) {
    return selectedFilter == filter;
  }
}

