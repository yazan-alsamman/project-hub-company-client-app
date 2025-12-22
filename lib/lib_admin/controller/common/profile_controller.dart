import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
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
      debugPrint('📋 Profile data loaded:');
      debugPrint('Username: $username');
      debugPrint('Email: $email');
      debugPrint('User ID: $userId');
      debugPrint('Role: $role');
    } catch (e) {
      debugPrint('🔴 Error loading profile data: $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> refreshProfile() async {
    await loadUserData();
  }
}
