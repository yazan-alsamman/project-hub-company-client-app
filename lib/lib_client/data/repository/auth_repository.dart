import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:project_hub/lib_client/core/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<Either<String, Map<String, dynamic>>> login(
    String username,
    String password,
  ) async {
    await _apiService.testConnection();

    int retries = 3;
    Exception? lastException;

    while (retries > 0) {
      try {
        final response = await _apiService.post(
          '/user/login',
          body: {'username': username, 'password': password},
        );

        final data = _apiService.handleResponse(response);

        if (data['success'] == true && data['data'] != null) {
          final loginData = data['data'] as Map<String, dynamic>;
          return Right(loginData);
        } else {
          final errorMsg =
              data['message'] ??
              'Login failed: Invalid credentials or server error';
          return Left(errorMsg);
        }
      } on SocketException catch (e) {
        lastException = e;
        retries--;
        if (retries > 0) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        return Left(
          'Network error: Unable to connect to server. Please check your internet connection and ensure the server is running at http://72.62.52.238:5020. Error: ${e.message}',
        );
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        final errorMessage = e.toString();

        if (errorMessage.contains('401') ||
            errorMessage.contains('403') ||
            errorMessage.contains('Unauthorized')) {
          return Left('Login failed: Invalid username or password');
        }

        if (errorMessage.contains('Failed to fetch') ||
            errorMessage.contains('ClientException')) {
          return Left(
            'CORS Error: Browser is blocking the request. This is a web platform issue.\n\n'
            'Solutions:\n'
            '1. Server must enable CORS for your origin\n'
            '2. For development, run Chrome with: chrome.exe --user-data-dir="C:/temp/chrome_dev" --disable-web-security\n'
            '3. Contact server admin to add CORS headers:\n'
            '   Access-Control-Allow-Origin: *\n'
            '   Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS\n'
            '   Access-Control-Allow-Headers: Content-Type, Authorization\n'
            '4. Or run the app on mobile/desktop instead of web',
          );
        }

        if (errorMessage.contains('timeout') ||
            errorMessage.contains('Connection') ||
            errorMessage.contains('Network error')) {
          retries--;
          if (retries > 0) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return Left(
            'Connection failed after 3 attempts. Unable to reach the server. Please check:\n1. Server is running at http://72.62.52.238:5020\n2. Your internet connection\n3. Firewall settings',
          );
        }

        return Left(errorMessage);
      }
    }

    return Left(
      'Login failed after multiple attempts: ${lastException?.toString() ?? "Unknown error"}',
    );
  }

  Future<Either<String, Map<String, dynamic>>> refreshToken(
    String refreshToken,
  ) async {
    try {
      final response = await _apiService.post(
        '/user/refresh',
        body: {'refreshToken': refreshToken},
      );

      final data = _apiService.handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        final refreshData = data['data'] as Map<String, dynamic>;
        return Right(refreshData);
      } else {
        return Left(data['message'] ?? 'Token refresh failed');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> logout() async {
    try {
      final response = await _apiService.post('/user/logout');
      _apiService.handleResponse(response);
      return const Right(true);
    } catch (e) {
      return const Right(true);
    }
  }
}
