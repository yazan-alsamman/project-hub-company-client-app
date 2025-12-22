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
