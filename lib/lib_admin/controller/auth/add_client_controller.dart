import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../data/Models/client_model.dart';
import '../../data/repository/auth_repository.dart';

abstract class AddClientController extends GetxController {
  void createClient();
  void resetForm();
  void loadClients({bool refresh = false});
  void refreshClients();
  void deleteClient(String clientId);
}

class AddClientControllerImp extends AddClientController {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedStatus = 'active';
  StatusRequest statusRequest = StatusRequest.none;
  bool isLoading = false;
  String? errorMessage;

  List<ClientModel> clients = [];
  StatusRequest clientsStatusRequest = StatusRequest.none;
  bool isLoadingClients = false;
  int currentPage = 1;
  int limit = 10;
  bool hasMore = true;
  Map<String, dynamic>? pagination;

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  @override
  void createClient() async {
    if (!_validateForm()) {
      return;
    }
    isLoading = true;
    statusRequest = StatusRequest.loading;
    update();
    try {
      final isActive = selectedStatus == 'active';
      final result = await _authRepository.createClient(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        isActive: isActive,
      );
      result.fold(
        (error) {
          String errorMsg = 'Failed to create client';
          StatusRequest errorStatus = StatusRequest.serverFailure;
          if (error is Map<String, dynamic>) {
            errorStatus =
                error['error'] as StatusRequest? ?? StatusRequest.serverFailure;
            errorMsg =
                error['message']?.toString() ?? 'Failed to create client';
          } else if (error is StatusRequest) {
            errorStatus = error;
            if (error == StatusRequest.serverFailure) {
              errorMsg = 'Server error. Please try again.';
            } else if (error == StatusRequest.offlineFailure) {
              errorMsg = 'No internet connection. Please check your network.';
            } else if (error == StatusRequest.timeoutException) {
              errorMsg = 'Request timed out. Please try again.';
            } else if (error == StatusRequest.serverException) {
              errorMsg = 'An unexpected server error occurred.';
            }
          }
          errorMessage = errorMsg;
          isLoading = false;
          statusRequest = errorStatus;
          update();
          Get.snackbar(
            'Error',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.errorColor,
            colorText: AppColor.white,
            icon: const Icon(
              Icons.error_outline,
              color: AppColor.white,
              size: 28,
            ),
            shouldIconPulse: false,
            duration: const Duration(seconds: 5),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            boxShadows: [
              BoxShadow(
                color: AppColor.errorColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            forwardAnimationCurve: Curves.easeOutBack,
            reverseAnimationCurve: Curves.easeInBack,
          );
        },
        (client) {
          errorMessage = null;
          isLoading = false;
          statusRequest = StatusRequest.success;
          update();
          Get.snackbar(
            'Success',
            'Client created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.successColor,
            colorText: AppColor.white,
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColor.white,
              size: 28,
            ),
            shouldIconPulse: false,
            duration: const Duration(seconds: 5),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            boxShadows: [
              BoxShadow(
                color: AppColor.successColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            forwardAnimationCurve: Curves.easeOutBack,
            reverseAnimationCurve: Curves.easeInBack,
          );
          Future.delayed(const Duration(milliseconds: 300), () {
            loadClients(refresh: true);
            Get.back();
          });
        },
      );
    } catch (e) {
      isLoading = false;
      statusRequest = StatusRequest.serverException;
      update();
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        icon: const Icon(Icons.error_outline, color: AppColor.white, size: 28),
        shouldIconPulse: false,
        duration: const Duration(seconds: 5),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        boxShadows: [
          BoxShadow(
            color: AppColor.errorColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
      );
    }
  }

  bool _validateForm() {
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Username',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (!emailController.text.trim().contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (passwordController.text.trim().length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }

  @override
  void resetForm() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    selectedStatus = 'active';
    statusRequest = StatusRequest.none;
    errorMessage = null;
    update();
  }

  @override
  void loadClients({bool refresh = false}) async {
    if (isLoadingClients && !refresh) {
      return;
    }
    if (refresh) {
      currentPage = 1;
      clients = [];
      hasMore = true;
    }
    if (!hasMore && !refresh) {
      return;
    }
    isLoadingClients = true;
    clientsStatusRequest = StatusRequest.loading;
    update();
    try {
      final result = await _loadAllClients();
      result.fold(
        (error) {
          StatusRequest errorStatus = StatusRequest.serverFailure;
          if (error is Map<String, dynamic>) {
            errorStatus =
                error['error'] as StatusRequest? ?? StatusRequest.serverFailure;
          } else if (error is StatusRequest) {
            errorStatus = error;
          }
          clientsStatusRequest = errorStatus;
          isLoadingClients = false;
          update();
        },
        (clientsList) {
          try {
            clients = clientsList;
            clientsStatusRequest = StatusRequest.success;
            isLoadingClients = false;
            update();
          } catch (e) {
            clientsStatusRequest = StatusRequest.serverException;
            isLoadingClients = false;
            update();
          }
        },
      );
    } catch (e) {
      clientsStatusRequest = StatusRequest.serverException;
      isLoadingClients = false;
      update();
    }
  }

  @override
  void refreshClients() {
    loadClients(refresh: true);
  }

  Future<Either<dynamic, List<ClientModel>>> _loadAllClients() async {
    List<ClientModel> allClients = [];
    int currentPage = 1;
    const int maxLimit = 100;

    while (true) {
      final result = await _authRepository.getClients(
        page: currentPage,
        limit: maxLimit,
      );

      final shouldContinue = result.fold(
        (error) {
          if (allClients.isNotEmpty) {
            return false;
          }
          return false;
        },
        (data) {
          try {
            final clientsList = data['clients'] as List<ClientModel>;
            allClients.addAll(clientsList);
            return clientsList.length >= maxLimit;
          } catch (e) {
            return false;
          }
        },
      );

      if (!shouldContinue) {
        return result.fold(
          (error) {
            if (allClients.isNotEmpty) {
              return Right<dynamic, List<ClientModel>>(allClients);
            }
            return Left<dynamic, List<ClientModel>>(error);
          },
          (data) {
            return Right<dynamic, List<ClientModel>>(allClients);
          },
        );
      }

      currentPage++;
    }
  }

  @override
  void deleteClient(String clientId) async {
    final client = clients.firstWhere(
      (c) => c.id == clientId,
      orElse: () => ClientModel(
        id: clientId,
        username: 'this client',
        email: '',
        isActive: true,
      ),
    );
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Delete Client',
          style: TextStyle(
            color: AppColor.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${client.username}?',
          style: TextStyle(color: AppColor.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColor.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColor.errorColor),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirm != true) {
      return;
    }
    try {
      final result = await _authRepository.deleteClient(clientId);
      result.fold(
        (error) {
          String errorMsg = 'Failed to delete client';
          if (error is Map<String, dynamic>) {
            errorMsg =
                error['message']?.toString() ?? 'Failed to delete client';
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
          }
          Get.snackbar(
            'Error',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.errorColor,
            colorText: AppColor.white,
            icon: const Icon(
              Icons.error_outline,
              color: AppColor.white,
              size: 28,
            ),
            shouldIconPulse: false,
            duration: const Duration(seconds: 5),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            boxShadows: [
              BoxShadow(
                color: AppColor.errorColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            forwardAnimationCurve: Curves.easeOutBack,
            reverseAnimationCurve: Curves.easeInBack,
          );
        },
        (success) {
          Get.snackbar(
            'Success',
            'Client deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.successColor,
            colorText: AppColor.white,
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColor.white,
              size: 28,
            ),
            shouldIconPulse: false,
            duration: const Duration(seconds: 2),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            boxShadows: [
              BoxShadow(
                color: AppColor.successColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            forwardAnimationCurve: Curves.easeOutBack,
            reverseAnimationCurve: Curves.easeInBack,
          );
          clients.removeWhere((client) => client.id == clientId);
          update();
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        icon: const Icon(Icons.error_outline, color: AppColor.white, size: 28),
        shouldIconPulse: false,
        duration: const Duration(seconds: 5),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        boxShadows: [
          BoxShadow(
            color: AppColor.errorColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
      );
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
