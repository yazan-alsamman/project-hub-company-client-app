import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:project_hub/lib_client/controller/auth_controller.dart';

class ApiService {
  // Base URL
  static const String baseUrl = 'http://72.62.52.238:5020';

  static const Duration timeoutDuration = Duration(seconds: 30);

  // Token refresh state to prevent multiple simultaneous refresh attempts
  static bool _isRefreshing = false;
  static Completer<String>? _refreshCompleter;

  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Connection test timeout');
            },
          );

      return response.statusCode < 500;
    } on SocketException {
      debugPrint('Connection test: SocketException - Server unreachable');
      return false;
    } on TimeoutException {
      debugPrint('Connection test: TimeoutException - Server not responding');
      return false;
    } on HttpException catch (e) {
      debugPrint('Connection test: HttpException - ${e.message}');
      // HTTP exception means we connected but got an error - server is reachable
      return true;
    } catch (e) {
      final errorStr = e.toString();

      if (errorStr.contains('Failed to fetch') ||
          errorStr.contains('ClientException')) {
        debugPrint(
          'Connection test: CORS error detected - Browser blocking request (server is reachable)',
        );

        return true;
      }
      debugPrint('Connection test: Unknown error - $e');

      return false;
    }
  }

  /// Refreshes the access token using the refresh token
  Future<String?> _refreshAccessToken() async {
    try {
      // If another request is already refreshing, wait for it to complete
      if (_isRefreshing && _refreshCompleter != null) {
        debugPrint(
          '🔄 Token refresh already in progress, waiting for completion',
        );
        return await _refreshCompleter!.future;
      }

      _isRefreshing = true;
      _refreshCompleter = Completer<String>();

      if (!Get.isRegistered<AuthController>()) {
        debugPrint('🔴 AuthController not available, cannot refresh token');
        _isRefreshing = false;
        _refreshCompleter = null;
        return null;
      }

      final authController = Get.find<AuthController>();
      final currentRefreshToken = authController.refreshToken.value;

      if (currentRefreshToken.isEmpty) {
        debugPrint('🔴 No refresh token available');
        _isRefreshing = false;
        _refreshCompleter = null;
        return null;
      }

      debugPrint('🔄 Attempting to refresh access token...');

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
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Token refresh timeout');
            },
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

            debugPrint('✅ Token refreshed successfully');
            _refreshCompleter?.complete(newToken);

            _isRefreshing = false;
            _refreshCompleter = null;

            return newToken;
          }
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('🔴 Refresh token is invalid or expired, logging out');
        // Refresh token is invalid, log out the user
        await authController.logout();
      }

      debugPrint('🔴 Token refresh failed: ${response.statusCode}');
      _refreshCompleter?.completeError('Token refresh failed');

      _isRefreshing = false;
      _refreshCompleter = null;

      return null;
    } catch (e) {
      debugPrint('🔴 Token refresh error: $e');
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

      final response = await http
          .get(uri, headers: getHeaders(additionalHeaders: headers))
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        debugPrint('🔴 GET $endpoint returned 401, attempting token refresh');
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          debugPrint('🔄 Retrying GET request after token refresh');
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
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        debugPrint('🔴 POST $endpoint returned 401, attempting token refresh');
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          debugPrint('🔄 Retrying POST request after token refresh');
          // Retry the request with the new token
          return await http
              .post(
                Uri.parse('$baseUrl$endpoint'),
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
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        debugPrint('🔴 PUT $endpoint returned 401, attempting token refresh');
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          debugPrint('🔄 Retrying PUT request after token refresh');
          // Retry the request with the new token
          return await http
              .put(
                Uri.parse('$baseUrl$endpoint'),
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
      final response = await http
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        debugPrint('🔴 PATCH $endpoint returned 401, attempting token refresh');
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          debugPrint('🔄 Retrying PATCH request after token refresh');
          // Retry the request with the new token
          return await http
              .patch(
                Uri.parse('$baseUrl$endpoint'),
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
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: getHeaders(additionalHeaders: headers),
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timeout: Unable to connect to server');
            },
          );

      // Handle 401 Unauthorized - try to refresh token and retry
      if (response.statusCode == 401) {
        debugPrint(
          '🔴 DELETE $endpoint returned 401, attempting token refresh',
        );
        final newToken = await _refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          debugPrint('🔄 Retrying DELETE request after token refresh');
          // Retry the request with the new token
          return await http
              .delete(
                Uri.parse('$baseUrl$endpoint'),
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
