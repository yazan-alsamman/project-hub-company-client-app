import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../common/filter_button_controller.dart';
import '../../data/Models/task_model.dart';
import '../../data/repository/tasks_repository.dart';
abstract class TasksController extends GetxController {
  List<TaskModel> get allTasks;
  StatusRequest get statusRequest;
  bool get isLoading;
  Future<void> loadTasks({bool refresh = false});
  Future<void> refreshTasks();
  List<TaskModel> get filteredTasks;
}
class TasksControllerImp extends TasksController {
  final TasksRepository _tasksRepository = TasksRepository();
  List<TaskModel> _allTasks = [];
  StatusRequest _statusRequest = StatusRequest.none;
  bool _isLoading = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;
  @override
  List<TaskModel> get allTasks => _allTasks;
  @override
  StatusRequest get statusRequest => _statusRequest;
  @override
  bool get isLoading => _isLoading;
  @override
  void onInit() {
    super.onInit();
    debugPrint('🔵 TasksControllerImp.onInit() called');
    loadTasks();
  }
  @override
  Future<void> loadTasks({bool refresh = false}) async {
    if (_isLoading && !refresh) {
      debugPrint('🟡 Already loading, returning.');
      return;
    }
    _isLoading = true;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _allTasks.clear();
      _statusRequest = StatusRequest.loading;
      debugPrint('🔄 Refreshing tasks...');
    } else if (_allTasks.isEmpty) {
      _statusRequest = StatusRequest.loading;
      debugPrint('⏳ Initial load of tasks...');
    }
    update();
    debugPrint('🔵 Loading tasks...');
    debugPrint('Page: $_currentPage, Limit: $_limit');
    final result = await _tasksRepository.getTasks(
      page: _currentPage,
      limit: _limit,
    );
    _isLoading = false;
    result.fold(
      (error) async {
        debugPrint('🔴 Error loading tasks: $error');
        _statusRequest = error;
        update();
      },
      (tasks) {
        debugPrint('✅ Loaded ${tasks.length} tasks');
        for (var task in tasks) {
          debugPrint(
            '  - Task: ${task.title}, Status: ${task.status}, Priority: ${task.priority}',
          );
        }
        if (refresh) {
          _allTasks = tasks;
        } else {
          _allTasks.addAll(tasks);
        }
        _hasMore = tasks.length >= _limit;
        if (_hasMore) {
          _currentPage++;
        }
        _statusRequest = StatusRequest.success;
        update();
        debugPrint('✅ Total tasks: ${_allTasks.length}');
      },
    );
  }
  @override
  Future<void> refreshTasks() async {
    await loadTasks(refresh: true);
  }
  @override
  List<TaskModel> get filteredTasks {
    final filterController = Get.find<FilterButtonController>();
    if (filterController.selectedFilter == 'All') {
      return _allTasks;
    }
    return _allTasks
        .where((task) => task.status == filterController.selectedFilter)
        .toList();
  }
}
