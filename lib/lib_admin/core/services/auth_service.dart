import 'package:get/get.dart';
import 'package:project_hub/core/services/services.dart';
class AuthService {
  final Myservices _services = Get.find();
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _usernameKey = 'username';
  static const String _userRoleKey = 'user_role';
  static const String _companyIdKey = 'company_id';
  Future<void> saveToken(String token) async {
    await _services.sharedPreferences.setString(_tokenKey, token);
  }
  Future<String?> getToken() async {
    return _services.sharedPreferences.getString(_tokenKey);
  }
  Future<void> saveRefreshToken(String refreshToken) async {
    await _services.sharedPreferences.setString(_refreshTokenKey, refreshToken);
  }
  Future<String?> getRefreshToken() async {
    return _services.sharedPreferences.getString(_refreshTokenKey);
  }
  Future<void> saveUserId(String userId) async {
    await _services.sharedPreferences.setString(_userIdKey, userId);
  }
  Future<String?> getUserId() async {
    return _services.sharedPreferences.getString(_userIdKey);
  }
  Future<void> saveUserEmail(String email) async {
    await _services.sharedPreferences.setString(_userEmailKey, email);
  }
  Future<String?> getUserEmail() async {
    return _services.sharedPreferences.getString(_userEmailKey);
  }
  Future<void> saveUsername(String username) async {
    await _services.sharedPreferences.setString(_usernameKey, username);
  }
  Future<String?> getUsername() async {
    return _services.sharedPreferences.getString(_usernameKey);
  }
  Future<void> saveUserRole(String role) async {
    await _services.sharedPreferences.setString(_userRoleKey, role);
  }
  Future<String?> getUserRole() async {
    return _services.sharedPreferences.getString(_userRoleKey);
  }
  Future<void> saveCompanyId(String companyId) async {
    await _services.sharedPreferences.setString(_companyIdKey, companyId);
  }
  Future<String?> getCompanyId() async {
    return _services.sharedPreferences.getString(_companyIdKey);
  }
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  Future<void> logout() async {
    await _services.sharedPreferences.remove(_tokenKey);
    await _services.sharedPreferences.remove(_refreshTokenKey);
    await _services.sharedPreferences.remove(_userIdKey);
    await _services.sharedPreferences.remove(_userEmailKey);
    await _services.sharedPreferences.remove(_usernameKey);
    await _services.sharedPreferences.remove(_userRoleKey);
    await _services.sharedPreferences.remove(_companyIdKey);
  }
  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
    String username = '',
    String role = '',
  }) async {
    await saveToken(token);
    await saveRefreshToken(refreshToken);
    await saveUserId(userId);
    await saveUserEmail(email);
    if (username.isNotEmpty) {
      await saveUsername(username);
    }
    if (role.isNotEmpty) {
      await saveUserRole(role);
    }
  }
  Future<void> updateTokens({
    required String token,
    String? refreshToken,
  }) async {
    await saveToken(token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await saveRefreshToken(refreshToken);
    }
  }
}
