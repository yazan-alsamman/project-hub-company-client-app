import 'package:get/get.dart';
import 'package:project_hub/lib_client/core/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  String? username;
  String? email;
  String? userId;
  String? role;
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading = true;
    update();
    try {
      username = await _authService.getUsername();
      email = await _authService.getUserEmail();
      userId = await _authService.getUserId();
      role = await _authService.getUserRole();
    } catch (e) {
      // Error loading profile data
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshProfile() async {
    await loadUserData();
  }
}

