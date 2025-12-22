import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../class/statusrequest.dart';
import '../constant/api_constant.dart';
import 'auth_service.dart';
import '../functions/checkinternet.dart';
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  final AuthService _authService = AuthService();
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshCompleters = [];
  Future<Either<StatusRequest, Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
    bool requiresAuth = true,
  }) async {
    return await _makeRequestWithRetry(
      'GET',
      endpoint,
      queryParams: queryParams,
      pathParams: pathParams,
      requiresAuth: requiresAuth,
    );
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> _makeRequestWithRetry(
    String method,
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    int retryCount = 0,
  }) async {
    try {
      if (!await checkInternet()) {
        return const Left(StatusRequest.offlineFailure);
      }
      String url = pathParams != null
          ? ApiConstant.buildUrlWithParams(endpoint, pathParams)
          : ApiConstant.buildUrl(endpoint);
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri
            .replace(queryParameters: {...uri.queryParameters, ...queryParams})
            .toString();
      }
      final headers = await _buildHeaders(requiresAuth);
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          debugPrint('🔵 GET Request URL: $url');
          debugPrint('🔵 Query params: $queryParams');
          debugPrint('🔵 Headers: $headers');
          response = await http
              .get(Uri.parse(url), headers: headers)
              .timeout(ApiConstant.connectTimeout);
          break;
        case 'POST':
          debugPrint('🔵 POST Request URL: $url');
          final bodyJson = body != null ? jsonEncode(body) : null;
          debugPrint('🔵 Headers: $headers');
          debugPrint('🔵 Body: $bodyJson');
          response = await http
              .post(Uri.parse(url), headers: headers, body: bodyJson)
              .timeout(ApiConstant.connectTimeout);
          break;
        case 'PUT':
          debugPrint('🔵 PUT Request URL: $url');
          final bodyJson = body != null ? jsonEncode(body) : null;
          debugPrint('🔵 Headers: $headers');
          debugPrint('🔵 Body: $bodyJson');
          response = await http
              .put(Uri.parse(url), headers: headers, body: bodyJson)
              .timeout(ApiConstant.connectTimeout);
          break;
        case 'DELETE':
          debugPrint('🔵 DELETE Request URL: $url');
          debugPrint('🔵 Headers: $headers');
          response = await http
              .delete(Uri.parse(url), headers: headers)
              .timeout(ApiConstant.connectTimeout);
          break;
        default:
          return const Left(StatusRequest.serverException);
      }
      
      debugPrint('🔵 Response status: ${response.statusCode}');
      debugPrint('🔵 Response body: ${response.body}');
      
      // Handle 401 Unauthorized - Try to refresh token
      if (response.statusCode == 401 && requiresAuth && retryCount == 0) {
        debugPrint('🔴 Unauthorized (401) - Attempting to refresh token...');
        final refreshSuccess = await _refreshToken();
        if (refreshSuccess) {
          debugPrint('✅ Token refreshed successfully, retrying original request...');
          // Retry the original request with new token
          return await _makeRequestWithRetry(
            method,
            endpoint,
            queryParams: queryParams,
            pathParams: pathParams,
            body: body,
            requiresAuth: requiresAuth,
            retryCount: retryCount + 1,
          );
        } else {
          debugPrint('🔴 Failed to refresh token, logging out...');
          await _authService.logout();
        }
      }
      
      return _handleResponse(response);
    } catch (e, stackTrace) {
      debugPrint('🔴 Request exception: $e');
      debugPrint('🔴 Exception type: ${e.runtimeType}');
      debugPrint('🔴 Stack trace: $stackTrace');
      if (e.toString().contains('TimeoutException')) {
        debugPrint('🔴 Timeout exception detected');
        return const Left(StatusRequest.timeoutException);
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        debugPrint('🔴 Network exception detected');
        return const Left(StatusRequest.offlineFailure);
      }
      debugPrint('🔴 Server exception detected');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? pathParams,
    bool requiresAuth = true,
  }) async {
    print('🔵 ====== API SERVICE POST CALLED ======');
    debugPrint('🔵 API SERVICE POST CALLED');
    print('Endpoint: $endpoint');
    try {
      return await _makeRequestWithRetry(
        'POST',
        endpoint,
        pathParams: pathParams,
        body: body,
        requiresAuth: requiresAuth,
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 API Error occurred:');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');
      debugPrint('Stack trace: $stackTrace');
      if (e is TimeoutException) {
        debugPrint(
          '⏰ TIMEOUT ERROR: Request took longer than ${ApiConstant.connectTimeout.inSeconds} seconds',
        );
        return const Left(StatusRequest.timeoutException);
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        debugPrint('🌐 NETWORK ERROR: Cannot reach server');
        return const Left(StatusRequest.offlineFailure);
      }
      if (e.toString().contains('Connection refused')) {
        debugPrint(
          '🚫 CONNECTION REFUSED: Server is not listening or firewall blocked',
        );
        return const Left(StatusRequest.offlineFailure);
      }
      debugPrint('❌ UNKNOWN ERROR: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? pathParams,
    bool requiresAuth = true,
  }) async {
    try {
      return await _makeRequestWithRetry(
        'PUT',
        endpoint,
        pathParams: pathParams,
        body: body,
        requiresAuth: requiresAuth,
      );
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return const Left(StatusRequest.timeoutException);
      }
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, String>? pathParams,
    bool requiresAuth = true,
  }) async {
    try {
      return await _makeRequestWithRetry(
        'DELETE',
        endpoint,
        pathParams: pathParams,
        requiresAuth: requiresAuth,
      );
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return const Left(StatusRequest.timeoutException);
      }
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Map<String, String>> _buildHeaders(bool requiresAuth) async {
    final headers = <String, String>{
      'Content-Type': ApiConstant.contentType,
      'Accept': ApiConstant.accept,
    };
    if (requiresAuth) {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Either<StatusRequest, Map<String, dynamic>> _handleResponse(
    http.Response response,
  ) {
    try {
      debugPrint('📥 Handling response with status: ${response.statusCode}');
      if (response.body.isEmpty) {
        debugPrint('🔴 Empty response body');
        return const Left(StatusRequest.serverException);
      }
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      debugPrint('📦 Parsed response body successfully');
      switch (response.statusCode) {
        case 200:
        case 201:
          debugPrint('✅ Success status code: ${response.statusCode}');
          return Right(responseBody);
        case 400:
          debugPrint('🔴 Bad Request (400)');
          debugPrint('Response: ${response.body}');
          return Right(responseBody);
        case 401:
          debugPrint('🔴 Unauthorized (401)');
          return Right(responseBody);
        case 403:
          debugPrint('🔴 Forbidden (403) - Insufficient permissions/role');
          debugPrint('Response: ${response.body}');
          if (responseBody['message'] != null) {
            final message = responseBody['message'].toString();
            debugPrint('Error message: $message');
            if (message.contains('insufficient role') ||
                message.contains('Forbidden') ||
                message.contains('permission')) {
              debugPrint('⚠️ User does not have required permissions');
            }
          }
          return Right(responseBody);
        case 404:
          debugPrint('🔴 Not Found (404)');
          debugPrint('Response: ${response.body}');
          return Right(responseBody);
        case 500:
        case 502:
        case 503:
          debugPrint('🔴 Server Error (${response.statusCode})');
          debugPrint('Response: ${response.body}');
          return Right(responseBody);
        default:
          debugPrint('🔴 Unknown status code: ${response.statusCode}');
          debugPrint('Response: ${response.body}');
          return Right(responseBody);
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 Error parsing response: $e');
      debugPrint('Response body: ${response.body}');
      debugPrint('Stack trace: $stackTrace');
      return const Left(StatusRequest.serverException);
    }
  }

  Future<bool> _refreshToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      debugPrint('⏳ Token refresh already in progress, waiting...');
      final completer = Completer<void>();
      _refreshCompleters.add(completer);
      await completer.future;
      return true; // Assume success if another refresh succeeded
    }

    _isRefreshing = true;
    debugPrint('🔄 Starting token refresh...');

    try {
      final refreshTokenValue = await _authService.getRefreshToken();
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        debugPrint('🔴 No refresh token found');
        _isRefreshing = false;
        _completeRefreshCompleters(false);
        return false;
      }

      debugPrint('🔵 Calling refresh token API...');
      final url = ApiConstant.buildUrl(ApiConstant.refreshToken);
      final headers = <String, String>{
        'Content-Type': ApiConstant.contentType,
        'Accept': ApiConstant.accept,
      };
      final body = jsonEncode({'refreshToken': refreshTokenValue});

      final response = await http
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(ApiConstant.connectTimeout);

      debugPrint('🟢 Refresh token response status: ${response.statusCode}');
      debugPrint('🟢 Refresh token response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (responseBody['success'] == true && responseBody['data'] != null) {
            final data = responseBody['data'] as Map<String, dynamic>;
            final newToken = data['token']?.toString() ?? '';
            final newRefreshToken = data['refreshToken']?.toString() ?? '';

            if (newToken.isEmpty) {
              debugPrint('🔴 New token is empty');
              _isRefreshing = false;
              _completeRefreshCompleters(false);
              return false;
            }

            await _authService.saveToken(newToken);
            if (newRefreshToken.isNotEmpty) {
              await _authService.saveRefreshToken(newRefreshToken);
            }

            debugPrint('✅ Token refreshed successfully');
            _isRefreshing = false;
            _completeRefreshCompleters(true);
            return true;
          } else {
            debugPrint('🔴 Refresh token failed: ${responseBody['message']}');
            _isRefreshing = false;
            _completeRefreshCompleters(false);
            return false;
          }
        } catch (e) {
          debugPrint('🔴 Error parsing refresh token response: $e');
          _isRefreshing = false;
          _completeRefreshCompleters(false);
          return false;
        }
      } else {
        debugPrint('🔴 Refresh token failed with status: ${response.statusCode}');
        _isRefreshing = false;
        _completeRefreshCompleters(false);
        return false;
      }
    } catch (e) {
      debugPrint('🔴 Exception refreshing token: $e');
      _isRefreshing = false;
      _completeRefreshCompleters(false);
      return false;
    }
  }

  void _completeRefreshCompleters(bool success) {
    for (var completer in _refreshCompleters) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _refreshCompleters.clear();
  }
}
