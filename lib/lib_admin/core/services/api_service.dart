import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../class/statusrequest.dart';
import '../constant/api_constant.dart';
import 'auth_service.dart';
import '../functions/checkinternet.dart';
import '../../../core/services/logging_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final AuthService _authService = AuthService();
  final LoggingService _logger = LoggingService();
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
    final stopwatch = Stopwatch()..start();

    try {
      if (!await checkInternet()) {
        await _logger.logWarning('API', 'No internet connection');
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

      await _logger.logRequest(
        method: method,
        url: url,
        headers: headers,
        body: body,
      );

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(Uri.parse(url), headers: headers)
              .timeout(ApiConstant.connectTimeout);
          break;
        case 'POST':
          final bodyJson = body != null ? jsonEncode(body) : null;
          response = await http
              .post(Uri.parse(url), headers: headers, body: bodyJson)
              .timeout(ApiConstant.connectTimeout);
          break;
        case 'PUT':
          final bodyJson = body != null ? jsonEncode(body) : null;
          response = await http
              .put(Uri.parse(url), headers: headers, body: bodyJson)
              .timeout(ApiConstant.connectTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(Uri.parse(url), headers: headers)
              .timeout(ApiConstant.connectTimeout);
          break;
        default:
          await _logger.logError(
            tag: 'API',
            message: 'Unknown HTTP method: $method',
          );
          return const Left(StatusRequest.serverException);
      }

      stopwatch.stop();

      await _logger.logResponse(
        method: method,
        url: url,
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode == 401 && requiresAuth && retryCount == 0) {
        await _logger.logWarning('API', 'Unauthorized (401) - Attempting token refresh');
        final refreshSuccess = await _refreshToken();
        if (refreshSuccess) {
          await _logger.logInfo('API', 'Token refreshed, retrying request');
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
          await _logger.logWarning('AUTH', 'Token refresh failed, logging out');
          await _authService.logout();
        }
      }

      return _handleResponse(response);
    } catch (e, stackTrace) {
      stopwatch.stop();

      await _logger.logError(
        tag: 'API',
        message: '$method $endpoint failed',
        error: e,
        stackTrace: stackTrace,
      );

      if (e.toString().contains('TimeoutException')) {
        return const Left(StatusRequest.timeoutException);
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        return const Left(StatusRequest.offlineFailure);
      }
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? pathParams,
    bool requiresAuth = true,
  }) async {
    try {
      return await _makeRequestWithRetry(
        'POST',
        endpoint,
        pathParams: pathParams,
        body: body,
        requiresAuth: requiresAuth,
      );
    } catch (e, stackTrace) {
      await _logger.logError(
        tag: 'API',
        message: 'POST $endpoint failed',
        error: e,
        stackTrace: stackTrace,
      );

      if (e is TimeoutException) {
        return const Left(StatusRequest.timeoutException);
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection refused')) {
        return const Left(StatusRequest.offlineFailure);
      }
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
    } catch (e, stackTrace) {
      await _logger.logError(
        tag: 'API',
        message: 'PUT $endpoint failed',
        error: e,
        stackTrace: stackTrace,
      );

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
    } catch (e, stackTrace) {
      await _logger.logError(
        tag: 'API',
        message: 'DELETE $endpoint failed',
        error: e,
        stackTrace: stackTrace,
      );

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
      if (response.body.isEmpty) {
        _logger.logWarning('API', 'Empty response body received');
        return const Left(StatusRequest.serverException);
      }

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
        case 201:
          return Right(responseBody);
        case 400:
        case 401:
        case 403:
        case 404:
        case 500:
        case 502:
        case 503:
        default:
          return Right(responseBody);
      }
    } catch (e, stackTrace) {
      _logger.logError(
        tag: 'API',
        message: 'Failed to parse response',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(StatusRequest.serverException);
    }
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      await _logger.logInfo('AUTH', 'Token refresh already in progress, waiting');
      final completer = Completer<void>();
      _refreshCompleters.add(completer);
      await completer.future;
      return true;
    }

    _isRefreshing = true;
    await _logger.logInfo('AUTH', 'Starting token refresh');

    try {
      final refreshTokenValue = await _authService.getRefreshToken();
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        await _logger.logWarning('AUTH', 'No refresh token found');
        _isRefreshing = false;
        _completeRefreshCompleters(false);
        return false;
      }

      final url = ApiConstant.buildUrl(ApiConstant.refreshToken);
      final headers = <String, String>{
        'Content-Type': ApiConstant.contentType,
        'Accept': ApiConstant.accept,
      };
      final body = jsonEncode({'refreshToken': refreshTokenValue});

      await _logger.logRequest(
        method: 'POST',
        url: url,
        headers: headers,
        body: {'refreshToken': '[REDACTED]'},
      );

      final response = await http
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(ApiConstant.connectTimeout);

      await _logger.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        body: 'Token refresh response',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (responseBody['success'] == true && responseBody['data'] != null) {
            final data = responseBody['data'] as Map<String, dynamic>;
            final newToken = data['token']?.toString() ?? '';
            final newRefreshToken = data['refreshToken']?.toString() ?? '';

            if (newToken.isEmpty) {
              await _logger.logWarning('AUTH', 'Received empty token');
              _isRefreshing = false;
              _completeRefreshCompleters(false);
              return false;
            }

            await _authService.saveToken(newToken);
            if (newRefreshToken.isNotEmpty) {
              await _authService.saveRefreshToken(newRefreshToken);
            }

            await _logger.logAuthEvent(
              event: 'TOKEN_REFRESH',
              success: true,
            );

            _isRefreshing = false;
            _completeRefreshCompleters(true);
            return true;
          } else {
            await _logger.logWarning('AUTH', 'Token refresh response invalid');
            _isRefreshing = false;
            _completeRefreshCompleters(false);
            return false;
          }
        } catch (e) {
          await _logger.logError(
            tag: 'AUTH',
            message: 'Failed to parse token refresh response',
            error: e,
          );
          _isRefreshing = false;
          _completeRefreshCompleters(false);
          return false;
        }
      } else {
        await _logger.logWarning(
          'AUTH',
          'Token refresh failed with status: ${response.statusCode}',
        );
        _isRefreshing = false;
        _completeRefreshCompleters(false);
        return false;
      }
    } catch (e, stackTrace) {
      await _logger.logError(
        tag: 'AUTH',
        message: 'Token refresh exception',
        error: e,
        stackTrace: stackTrace,
      );
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
