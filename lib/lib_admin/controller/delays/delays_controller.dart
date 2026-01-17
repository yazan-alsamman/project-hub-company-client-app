import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../core/services/auth_service.dart';
import '../../data/Models/project_model.dart';
import '../../data/repository/delays_repository.dart';
import '../../data/repository/projects_repository.dart';

class DelaysController extends GetxController {
  final DelaysRepository _delaysRepository = DelaysRepository();
  final ProjectsRepository _projectsRepository = ProjectsRepository();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _delaySummary;
  StatusRequest _summaryStatusRequest = StatusRequest.none;
  bool _isLoadingSummary = false;

  List<dynamic> _allProjectsDelayStatus = [];
  StatusRequest _allProjectsStatusRequest = StatusRequest.none;
  bool _isLoadingAllProjects = false;

  Map<String, dynamic>? _projectDelayStatus;
  StatusRequest _projectDelayStatusRequest = StatusRequest.none;
  bool _isLoadingProjectDelay = false;

  List<dynamic> _projectTaskDelays = [];
  StatusRequest _projectTaskDelaysStatusRequest = StatusRequest.none;
  bool _isLoadingProjectTaskDelays = false;

  List<dynamic> _requestedDelays = [];
  StatusRequest _requestedDelaysStatusRequest = StatusRequest.none;
  bool _isLoadingRequestedDelays = false;
  Map<String, dynamic>? _requestedDelaysPagination;

  List<ProjectModel> _projects = [];
  String? _selectedProjectId;
  bool _isLoadingProjects = false;

  Map<String, dynamic>? get delaySummary => _delaySummary;
  StatusRequest get summaryStatusRequest => _summaryStatusRequest;
  bool get isLoadingSummary => _isLoadingSummary;

  List<dynamic> get allProjectsDelayStatus => _allProjectsDelayStatus;
  StatusRequest get allProjectsStatusRequest => _allProjectsStatusRequest;
  bool get isLoadingAllProjects => _isLoadingAllProjects;

  Map<String, dynamic>? get projectDelayStatus => _projectDelayStatus;
  StatusRequest get projectDelayStatusRequest => _projectDelayStatusRequest;
  bool get isLoadingProjectDelay => _isLoadingProjectDelay;

  List<dynamic> get projectTaskDelays => _projectTaskDelays;
  StatusRequest get projectTaskDelaysStatusRequest => _projectTaskDelaysStatusRequest;
  bool get isLoadingProjectTaskDelays => _isLoadingProjectTaskDelays;

  List<ProjectModel> get projects => _projects;
  String? get selectedProjectId => _selectedProjectId;
  bool get isLoadingProjects => _isLoadingProjects;

  List<dynamic> get requestedDelays => _requestedDelays;
  StatusRequest get requestedDelaysStatusRequest => _requestedDelaysStatusRequest;
  bool get isLoadingRequestedDelays => _isLoadingRequestedDelays;
  Map<String, dynamic>? get requestedDelaysPagination => _requestedDelaysPagination;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    _isLoadingProjects = true;
    update();

    try {
      final companyId = await _authService.getCompanyId();
      final result = await _projectsRepository.getProjects(
        page: 1,
        limit: 100,
        companyId: companyId,
      );

      result.fold(
        (error) {
          _projects = [];
        },
        (projectsList) {
          _projects = projectsList;
        },
      );
    } catch (e) {
      _projects = [];
    } finally {
      _isLoadingProjects = false;
      update();
    }
  }

  void selectProject(String? projectId) {
    _selectedProjectId = projectId;
    _projectDelayStatus = null;
    _projectTaskDelays = [];
    _projectDelayStatusRequest = StatusRequest.none;
    _projectTaskDelaysStatusRequest = StatusRequest.none;
    update();
  }

  Future<void> loadDelaySummary() async {
    _isLoadingSummary = true;
    _summaryStatusRequest = StatusRequest.loading;
    update();

    try {
      final result = await _delaysRepository.getDelaySummary();

      result.fold(
        (error) {
          _summaryStatusRequest = error;
          _delaySummary = null;
        },
        (summary) {
          _delaySummary = summary;
          _summaryStatusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      _summaryStatusRequest = StatusRequest.serverException;
      _delaySummary = null;
    } finally {
      _isLoadingSummary = false;
      update();
    }
  }

  Future<void> loadAllProjectsDelayStatus({int page = 1, int limit = 10}) async {
    _isLoadingAllProjects = true;
    _allProjectsStatusRequest = StatusRequest.loading;
    update();

    try {
      final result = await _delaysRepository.getAllProjectsDelayStatus(
        page: page,
        limit: limit,
      );

      result.fold(
        (error) {
          _allProjectsStatusRequest = error;
          _allProjectsDelayStatus = [];
        },
        (data) {
          if (data['projects'] != null && data['projects'] is List) {
            _allProjectsDelayStatus = data['projects'] as List<dynamic>;
          } else {
            _allProjectsDelayStatus = [];
          }
          _allProjectsStatusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      _allProjectsStatusRequest = StatusRequest.serverException;
      _allProjectsDelayStatus = [];
    } finally {
      _isLoadingAllProjects = false;
      update();
    }
  }

  Future<void> loadProjectDelayStatus() async {
    if (_selectedProjectId == null || _selectedProjectId!.isEmpty) {
      return;
    }

    _isLoadingProjectDelay = true;
    _projectDelayStatusRequest = StatusRequest.loading;
    update();

    try {
      final result = await _delaysRepository.getProjectDelayStatus(_selectedProjectId!);

      result.fold(
        (error) {
          _projectDelayStatusRequest = error;
          _projectDelayStatus = null;
        },
        (status) {
          _projectDelayStatus = status;
          _projectDelayStatusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      _projectDelayStatusRequest = StatusRequest.serverException;
      _projectDelayStatus = null;
    } finally {
      _isLoadingProjectDelay = false;
      update();
    }
  }

  Future<void> loadProjectTaskDelays({int page = 1, int limit = 10}) async {
    if (_selectedProjectId == null || _selectedProjectId!.isEmpty) {
      return;
    }

    _isLoadingProjectTaskDelays = true;
    _projectTaskDelaysStatusRequest = StatusRequest.loading;
    update();

    try {
      final result = await _delaysRepository.getProjectTaskDelays(
        projectId: _selectedProjectId!,
        page: page,
        limit: limit,
      );

      result.fold(
        (error) {
          _projectTaskDelaysStatusRequest = error;
          _projectTaskDelays = [];
        },
        (data) {
          if (data['tasks'] != null && data['tasks'] is List) {
            _projectTaskDelays = data['tasks'] as List<dynamic>;
          } else {
            _projectTaskDelays = [];
          }
          _projectTaskDelaysStatusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      _projectTaskDelaysStatusRequest = StatusRequest.serverException;
      _projectTaskDelays = [];
    } finally {
      _isLoadingProjectTaskDelays = false;
      update();
    }
  }

  Future<void> acceptDelayRequest({
    required String delayRequestId,
    required String reviewNote,
  }) async {
    try {
      final result = await _delaysRepository.acceptDelayRequest(
        delayRequestId: delayRequestId,
        reviewNote: reviewNote,
      );

      result.fold(
        (error) {
          String errorMsg = 'Failed to accept delay request';
          if (error is Map<String, dynamic> && error['message'] != null) {
            errorMsg = error['message'].toString();
          } else if (error is StatusRequest) {
            if (error == StatusRequest.serverFailure) {
              errorMsg = 'Server error. Please try again.';
            } else if (error == StatusRequest.offlineFailure) {
              errorMsg = 'No internet connection. Please check your network.';
            } else if (error == StatusRequest.timeoutException) {
              errorMsg = 'Request timed out. Please try again.';
            } else if (error == StatusRequest.serverException) {
              errorMsg = 'An unexpected server error occurred.';
            }
          } else if (error is String) {
            errorMsg = error;
          }
          Get.snackbar(
            'Error',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.errorColor,
            colorText: Colors.white,
            icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
            duration: const Duration(seconds: 5),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
        },
        (success) {
          Get.snackbar(
            'Success',
            'Delay request accepted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.successColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          if (_selectedProjectId != null) {
            loadProjectTaskDelays();
          }
          loadRequestedDelays();
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while accepting delay request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> rejectDelayRequest({
    required String delayRequestId,
    required String reviewNote,
  }) async {
    try {
      final result = await _delaysRepository.rejectDelayRequest(
        delayRequestId: delayRequestId,
        reviewNote: reviewNote,
      );

      result.fold(
        (error) {
          String errorMsg = 'Failed to reject delay request';
          if (error is Map<String, dynamic> && error['message'] != null) {
            errorMsg = error['message'].toString();
          } else if (error is StatusRequest) {
            if (error == StatusRequest.serverFailure) {
              errorMsg = 'Server error. Please try again.';
            } else if (error == StatusRequest.offlineFailure) {
              errorMsg = 'No internet connection. Please check your network.';
            } else if (error == StatusRequest.timeoutException) {
              errorMsg = 'Request timed out. Please try again.';
            } else if (error == StatusRequest.serverException) {
              errorMsg = 'An unexpected server error occurred.';
            }
          } else if (error is String) {
            errorMsg = error;
          }
          Get.snackbar(
            'Error',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.errorColor,
            colorText: Colors.white,
            icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
            duration: const Duration(seconds: 5),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
        },
        (success) {
          Get.snackbar(
            'Success',
            'Delay request rejected successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.successColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          if (_selectedProjectId != null) {
            loadProjectTaskDelays();
          }
          loadRequestedDelays();
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while rejecting delay request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> loadRequestedDelays({
    int page = 1,
    int limit = 10,
    String? status,
    String? taskID,
    String? requestedBy,
  }) async {
    _isLoadingRequestedDelays = true;
    _requestedDelaysStatusRequest = StatusRequest.loading;
    update();

    try {
      final result = await _delaysRepository.getDelayRequests(
        page: page,
        limit: limit,
        status: status,
        taskID: taskID,
        requestedBy: requestedBy,
      );

      result.fold(
        (error) {
          _requestedDelaysStatusRequest = error;
          _requestedDelays = [];
          _requestedDelaysPagination = null;
        },
        (data) {
          if (data['delayRequests'] != null && data['delayRequests'] is List) {
            _requestedDelays = data['delayRequests'] as List<dynamic>;
          } else {
            _requestedDelays = [];
          }
          if (data['pagination'] != null && data['pagination'] is Map) {
            _requestedDelaysPagination = data['pagination'] as Map<String, dynamic>;
          } else {
            _requestedDelaysPagination = null;
          }
          _requestedDelaysStatusRequest = StatusRequest.success;
        },
      );
    } catch (e) {
      _requestedDelaysStatusRequest = StatusRequest.serverException;
      _requestedDelays = [];
      _requestedDelaysPagination = null;
    } finally {
      _isLoadingRequestedDelays = false;
      update();
    }
  }
}

