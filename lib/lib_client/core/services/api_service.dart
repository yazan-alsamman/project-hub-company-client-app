import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:project_hub/lib_client/controller/auth_controller.dart';
import 'package:project_hub/core/services/logging_service.dart';
import 'package:project_hub/core/config/app_config.dart';

class ApiService {
  // Base URL - using centralized config
  static const String baseUrl = AppConfig.productionApiUrl;

  static const Duration timeoutDuration = AppConfig.connectTimeout;

  // Token refresh state to prevent multiple simultaneous refresh attempts
  static bool _isRefreshing = false;
  static Completer<String>? _refreshCompleter;

  final LoggingService _logger = LoggingService();

  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: {'Accept': 'application/json'})
          .timeout(
            AppConfig.connectionTestTimeout,
            onTimeout: () {
              throw TimeoutException('Connection test timeout');
            },
          );

      return response.statusCode < 500;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } on HttpException {
      return true;
    } catch (e) {
      final errorStr = e.toString();

      if (errorStr.contains('Failed to fetch') ||
          errorStr.contains('ClientException')) {
        return true;
      }

      return false;
    }
  }

  /// Refreshes the access token using the refresh token
  Future<String?> _refreshAccessToken() async {
    try {
      // If another request is already refreshing, wait for it to complete
      if (_isRefreshing && _refreshCompleter != null) {
        await _logger.logInfo('AUTH', 'Token refresh already in progress, waiting');
        return await _refreshCompleter!.future;
      }

      _isRefreshing = true;
      _refreshCompleter = Completer<String>();

      if (!Get.isRegistered<AuthController>()) {
        await _logger.logWarning('AUTH', 'AuthController not available');
        _isRefreshing = false;
        _refreshCompleter = null;
        return null;
      }

      final authController = Get.find<AuthController>();
      final currentRefreshToken = authController.refreshToken.value;

      if (currentRefreshToken.isEmpty) {
        await _logger.logWarning('AUTH', 'No refresh token available');
        _isRefreshing = false;
        _refreshCompleter = null;
        return null;
      }

      await _logger.logInfo('AUTH', 'Attempting to refresh access token');

      final response = await http
          .post(
            Uri.parse('$baseUrl/user/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': currentRefreshToken}),
          )
          .timeout(
            AppConfig.tokenRefreshTimeout,
            onTimeout: () {
              throw Exception('Token refresh timeout');
            },
          );

      await _logger.logResponse(
        method: 'POST',
        url: '$baseUrl/user/refresh',
        statusCode: response.statusCode,
        body: 'Token refresh response',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final newToken = data['data']['token'] as String?;
          final newRefreshToken = data['data']['refreshToken'] as String?;

          if (newToken != null && newToken.isNotEmpty) {
            // Update the token in the auth controller and persist to storage
            final authController = Get.find<AuthController>();
            await authController.updateTokensFromRefresh(
              newToken,
              newRefreshToken,
            );

            await _logger.logAuthEvent(event: 'TOKEN_REFRESH', success: true);
            _refreshCompleter?.complete(newToken);

            _isRefreshing = false;
            _refreshCompleter = null;

            return newToken;
          }
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await _logger.logWarning('AUTH', 'Refresh token invalid, logging out');
        await authController.logout();
      }

      await _logger.logWarning('AUTH', 'Token refresh failed: ${response.statusCode}');
      _refreshCompleter?.completeError('Token refresh failed');

      _isRefreshing = false;
      _refreshCompleter = null;

      return null;
    } catch (e, stackTrace) {
      await _logger.logError(
        tag: 'AUTH',
        message: 'Token refresh error',
        error: e,
        stackTrace: stackTrace,
      );
      _refreshCompleter?.completeError(e);

      _isRefreshing = false;
      _refreshCompleter = null;

      return null;
    }
  }

  Map<String, String> getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        if (authController.token.value.isNotEmpty) {
          headers['Authorization'] = 'Bearer ${authController.token.value}';
        }
      }
    } catch (e) {
      // Auth controller not available, continue without token
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');

      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      await _logger.logRequest(
        method: 'GET',
        url: uri.toString(),
        headers: getHeaders(additionalHeaders: headers),
      );

      final response = await http
          .get(uri, headers: getHeaders(additionalHeaders: headers))
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      await _logger.logResponse(
        method: 'GET',
        url: uri.toString(),
        statusCode: response.statusCode,
        body: response.body,
      );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          // Retry the request with the new token
          return await http
              .get(uri, headers: getHeaders(additionalHeaders: headers))
              .timeout(
                timeoutDuration,
                onTimeout: () {
                  throw Exception(
                    'Request timeout: Unable to connect to server',
                  );
                },
              );
        }
      }

      return response;
    } on SocketException catch (e) {
      throw Exception(
        'Network error: Unable to connect to server. Please check your internet connection. ${e.message}',
      );
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = '$baseUrl$endpoint';

      await _logger.logRequest(
        method: 'POST',
        url: url,
        headers: getHeaders(additionalHeaders: headers),
        body: body,
      );

      final response = await http
          .post(
            Uri.parse(url),
            headers: getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      await _logger.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
      );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          // Retry the request with the new token
          return await http
              .post(
                Uri.parse(url),
                headers: getHeaders(additionalHeaders: headers),
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(
                timeoutDuration,
                onTimeout: () {
                  throw Exception(
                    'Request timeout: Unable to connect to server',
                  );
                },
              );
        }
      }

      return response;
    } on SocketException catch (e) {
      throw Exception(
        'Network error: Unable to connect to server. Please check your internet connection. ${e.message}',
      );
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = '$baseUrl$endpoint';

      await _logger.logRequest(
        method: 'PUT',
        url: url,
        headers: getHeaders(additionalHeaders: headers),
        body: body,
      );

      final response = await http
          .put(
            Uri.parse(url),
            headers: getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      await _logger.logResponse(
        method: 'PUT',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
      );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          // Retry the request with the new token
          return await http
              .put(
                Uri.parse(url),
                headers: getHeaders(additionalHeaders: headers),
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(
                timeoutDuration,
                onTimeout: () {
                  throw Exception(
                    'Request timeout: Unable to connect to server',
                  );
                },
              );
        }
      }

      return response;
    } on SocketException catch (e) {
      throw Exception(
        'Network error: Unable to connect to server. Please check your internet connection. ${e.message}',
      );
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // PATCH request
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = '$baseUrl$endpoint';

      await _logger.logRequest(
        method: 'PATCH',
        url: url,
        headers: getHeaders(additionalHeaders: headers),
        body: body,
      );

      final response = await http
          .patch(
            Uri.parse(url),
            headers: getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      await _logger.logResponse(
        method: 'PATCH',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
      );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          // Retry the request with the new token
          return await http
              .patch(
                Uri.parse(url),
                headers: getHeaders(additionalHeaders: headers),
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(
                timeoutDuration,
                onTimeout: () {
                  throw Exception(
                    'Request timeout: Unable to connect to server',
                  );
                },
              );
        }
      }

      return response;
    } on SocketException catch (e) {
      throw Exception(
        'Network error: Unable to connect to server. Please check your internet connection. ${e.message}',
      );
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = '$baseUrl$endpoint';

      await _logger.logRequest(
        method: 'DELETE',
        url: url,
        headers: getHeaders(additionalHeaders: headers),
      );

      final response = await http
          .delete(
            Uri.parse(url),
            headers: getHeaders(additionalHeaders: headers),
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      await _logger.logResponse(
        method: 'DELETE',
        url: url,
        statusCode: response.statusCode,
        body: response.body,
      );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          // Retry the request with the new token
          return await http
              .delete(
                Uri.parse(url),
                headers: getHeaders(additionalHeaders: headers),
              )
              .timeout(
                timeoutDuration,
                onTimeout: () {
                  throw Exception(
                    'Request timeout: Unable to connect to server',
                  );
                },
              );
        }
      }

      return response;
    } on SocketException catch (e) {
      throw Exception(
        'Network error: Unable to connect to server. Please check your internet connection. ${e.message}',
      );
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Handle response
  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}
