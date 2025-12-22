import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_hub/lib_client/data/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxString token = ''.obs;
  final RxString refreshToken = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final RxMap<String, dynamic> user = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      final storedRefreshToken = prefs.getString('refresh_token');
      final storedUsername = prefs.getString('user_username');
      final storedEmail = prefs.getString('user_email');
      final storedUserId = prefs.getString('user_id');
      final storedRole = prefs.getString('user_role');

      if (storedToken != null && storedToken.isNotEmpty) {
        token.value = storedToken;
        refreshToken.value = storedRefreshToken ?? '';
        isLoggedIn.value = true;

        final userData = <String, dynamic>{
          'username': storedUsername ?? '',
          'email': storedEmail ?? '',
        };

        if (storedUserId != null) {
          userData['_id'] = storedUserId;
        }

        if (storedRole != null) {
          userData['role'] = {'name': storedRole};
        }

        user.value = userData;
      }
    } catch (e) {
      debugPrint('Error loading stored auth: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final result = await _authRepository.login(username, password);

      return result.fold(
        (error) {
          debugPrint('Login error: $error');
          return false;
        },
        (loginData) {
          if (loginData['token'] != null) {
            token.value = loginData['token'] as String;
            refreshToken.value = loginData['refreshToken'] as String? ?? '';
            user.value = loginData['user'] as Map<String, dynamic>? ?? {};
            isLoggedIn.value = true;

            _storeAuth();
            return true;
          }
          return false;
        },
      );
    } catch (e) {
      debugPrint('Login exception: $e');
      return false;
    }
  }

  Future<void> _storeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token.value.isNotEmpty) {
        await prefs.setString('auth_token', token.value);
      }
      if (refreshToken.value.isNotEmpty) {
        await prefs.setString('refresh_token', refreshToken.value);
      }
      if (user.isNotEmpty) {
        await prefs.setString('user_username', user['username'] ?? '');
        await prefs.setString('user_email', user['email'] ?? '');
        if (user['_id'] != null) {
          await prefs.setString('user_id', user['_id'].toString());
        }
        if (user['role'] != null) {
          if (user['role'] is Map<String, dynamic>) {
            await prefs.setString('user_role', user['role']['name'] ?? '');
          } else if (user['role'] is String) {
            await prefs.setString('user_role', user['role']);
          }
        }
      }
    } catch (e) {
      debugPrint('Error storing auth: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      token.value = '';
      refreshToken.value = '';
      isLoggedIn.value = false;
      user.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_username');
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.remove('user_role');
    }
  }

  String get username => user['username'] ?? '';

  String get email => user['email'] ?? '';

  String? get userId {
    if (user['_id'] != null) {
      return user['_id'] as String;
    }
    return null;
  }

  String? get userRole {
    if (user['role'] != null) {
      final role = user['role'];
      if (role is Map<String, dynamic> && role['name'] != null) {
        return role['name'] as String;
      }
      if (role is String) {
        return role;
      }
    }
    return null;
  }

  bool get isClient => userRole?.toLowerCase() == 'client';

  bool get canEdit => !isClient;

  Future<bool> refreshAccessToken() async {
    if (refreshToken.value.isEmpty) {
      return false;
    }

    try {
      final result = await _authRepository.refreshToken(refreshToken.value);

      return result.fold(
        (error) {
          logout();
          return false;
        },
        (refreshData) {
          if (refreshData['token'] != null) {
            token.value = refreshData['token'] as String;
            if (refreshData['refreshToken'] != null) {
              refreshToken.value = refreshData['refreshToken'] as String;
            }

            _storeAuth();
            return true;
          }
          return false;
        },
      );
    } catch (e) {
      logout();
      return false;
    }
  }
}
