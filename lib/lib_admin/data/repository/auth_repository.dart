import 'package:dartz/dartz.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../Models/api_response_model.dart';
import '../Models/client_model.dart';
import '../Models/role_model.dart';
import '../../../core/services/logging_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final LoggingService _logger = LoggingService();

  Future<Either<StatusRequest, Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    try {
      await _logger.logAuthEvent(event: 'LOGIN_ATTEMPT', success: true);

      final result = await _apiService.post(
        ApiConstant.login,
        body: {'username': username, 'password': password},
        requiresAuth: false,
      );

      return result.fold(
        (error) {
          _logger.logAuthEvent(event: 'LOGIN_FAILED', success: false);
          return Left(error);
        },
        (response) async {
          try {
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;

              if (data['user'] == null) {
                await _logger.logWarning(
                  'AUTH',
                  'User data is null in login response',
                );
                return const Left(StatusRequest.serverFailure);
              }

              final user = data['user'] as Map<String, dynamic>;
              String? companyId;

              if (user['companyId'] != null) {
                if (user['companyId'] is Map<String, dynamic>) {
                  companyId = (user['companyId'] as Map<String, dynamic>)['_id']
                      ?.toString();
                } else {
                  companyId = user['companyId']?.toString();
                }
              }

              if ((companyId == null || companyId.isEmpty) &&
                  data['companyId'] != null) {
                if (data['companyId'] is Map<String, dynamic>) {
                  companyId = (data['companyId'] as Map<String, dynamic>)['_id']
                      ?.toString();
                } else {
                  companyId = data['companyId']?.toString();
                }
              }

              if ((companyId == null || companyId.isEmpty) &&
                  response['companyId'] != null) {
                if (response['companyId'] is Map<String, dynamic>) {
                  companyId =
                      (response['companyId'] as Map<String, dynamic>)['_id']
                          ?.toString();
                } else {
                  companyId = response['companyId']?.toString();
                }
              }

              final userRole = user['role'] != null
                  ? (user['role'] as Map<String, dynamic>)['name']
                            ?.toString() ??
                        ''
                  : '';

              await _authService.saveAuthData(
                token: data['token']?.toString() ?? '',
                refreshToken: data['refreshToken']?.toString() ?? '',
                userId: user['_id']?.toString() ?? '',
                email: user['email']?.toString() ?? '',
                username: user['username']?.toString() ?? username,
                role: userRole,
              );

              if (companyId != null && companyId.isNotEmpty) {
                await _authService.saveCompanyId(companyId);
              }

              await _logger.logAuthEvent(
                event: 'LOGIN_SUCCESS',
                userId: user['_id']?.toString(),
                role: userRole,
                success: true,
              );

              return Right(response);
            } else {
              await _logger.logAuthEvent(event: 'LOGIN_FAILED', success: false);
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            await _logger.logError(
              tag: 'AUTH',
              message: 'Login parsing error',
              error: e,
              stackTrace: stackTrace,
            );
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e, stackTrace) {
      await _logger.logError(
        tag: 'AUTH',
        message: 'Login exception',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final result = await _apiService.post(
        ApiConstant.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
        requiresAuth: false,
      );

      return result.fold((error) => Left(error), (response) async {
        try {
          final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
            response,
            (data) => data as Map<String, dynamic>,
          );
          if (apiResponse.success && apiResponse.data != null) {
            final data = apiResponse.data!;
            if (data['token'] != null) {
              await _authService.saveAuthData(
                token: data['token'] ?? '',
                refreshToken: data['refresh_token'] ?? '',
                userId: data['user']['id']?.toString() ?? '',
                email: data['user']['email'] ?? email,
              );
            }
            await _logger.logAuthEvent(
              event: 'REGISTER_SUCCESS',
              success: true,
            );
            return Right(data);
          } else {
            return const Left(StatusRequest.serverFailure);
          }
        } catch (e) {
          return const Left(StatusRequest.serverException);
        }
      });
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, bool>> logout() async {
    await _logger.logAuthEvent(event: 'LOGOUT_ATTEMPT', success: true);

    try {
      final refreshTokenValue = await _authService.getRefreshToken();
      Map<String, dynamic>? body;

      if (refreshTokenValue != null && refreshTokenValue.isNotEmpty) {
        body = {'refreshToken': refreshTokenValue};
      }

      final result = await _apiService.post(
        ApiConstant.logout,
        body: body,
        requiresAuth: true,
      );

      await _authService.logout();
      await _logger.logAuthEvent(event: 'LOGOUT_SUCCESS', success: true);

      return result.fold(
        (error) {
          return const Right(true);
        },
        (response) {
          if (response['success'] == true) {
            return const Right(true);
          } else {
            return const Right(true);
          }
        },
      );
    } catch (e, stackTrace) {
      await _logger.logError(
        tag: 'AUTH',
        message: 'Logout error',
        error: e,
        stackTrace: stackTrace,
      );
      await _authService.logout();
      return const Right(true);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> refreshToken() async {
    try {
      final refreshTokenValue = await _authService.getRefreshToken();
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        await _logger.logWarning('AUTH', 'No refresh token found');
        return const Left(StatusRequest.serverFailure);
      }

      final result = await _apiService.post(
        ApiConstant.refreshToken,
        body: {'refreshToken': refreshTokenValue},
        requiresAuth: false,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) async {
          try {
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              final newToken = data['token']?.toString() ?? '';
              final newRefreshToken = data['refreshToken']?.toString() ?? '';

              if (newToken.isEmpty) {
                return const Left(StatusRequest.serverFailure);
              }

              await _authService.saveToken(newToken);
              if (newRefreshToken.isNotEmpty) {
                await _authService.saveRefreshToken(newRefreshToken);
              }

              await _logger.logAuthEvent(
                event: 'TOKEN_REFRESH_SUCCESS',
                success: true,
              );
              return Right(response);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            await _logger.logError(
              tag: 'AUTH',
              message: 'Refresh token parsing error',
              error: e,
              stackTrace: stackTrace,
            );
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e, stackTrace) {
      await _logger.logError(
        tag: 'AUTH',
        message: 'Refresh token error',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, bool>> forgotPassword(String email) async {
    try {
      final result = await _apiService.post(
        ApiConstant.forgotPassword,
        body: {'email': email},
        requiresAuth: false,
      );

      return result.fold((error) => Left(error), (response) {
        try {
          final apiResponse = ApiResponseModel.fromJson(response, null);
          return Right(apiResponse.success);
        } catch (e) {
          return const Left(StatusRequest.serverException);
        }
      });
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, List<RoleModel>>> getRoles() async {
    try {
      final result = await _apiService.get(
        ApiConstant.roles,
        requiresAuth: true,
      );
      return result.fold((error) => Left(error), (response) {
        try {
          if (response['success'] == true && response['data'] != null) {
            final data = response['data'];
            List<dynamic> rolesList;
            if (data is List) {
              rolesList = data;
            } else {
              return const Left(StatusRequest.serverFailure);
            }
            final roles = rolesList
                .map((item) => RoleModel.fromJson(item as Map<String, dynamic>))
                .toList();
            return Right(roles);
          } else {
            return const Left(StatusRequest.serverFailure);
          }
        } catch (e) {
          return const Left(StatusRequest.serverException);
        }
      });
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }

  Future<String?> _getClientRoleId() async {
    final rolesResult = await getRoles();
    return rolesResult.fold((error) => null, (roles) {
      final clientRole = roles.firstWhere(
        (role) => role.name.toLowerCase() == 'client',
        orElse: () =>
            RoleModel(id: '', name: '', description: '', isActive: false),
      );
      return clientRole.id.isNotEmpty ? clientRole.id : null;
    });
  }

  Future<Either<dynamic, ClientModel>> createClient({
    required String username,
    required String email,
    required String password,
    required bool isActive,
  }) async {
    try {
      final clientRoleId = await _getClientRoleId();
      if (clientRoleId == null || clientRoleId.isEmpty) {
        _logger.logError(
          tag: 'CLIENT',
          message: 'Failed to fetch client role ID',
        );
        return Left({
          'error': StatusRequest.serverFailure,
          'message': 'Failed to fetch client role. Please try again.',
        });
      }

      final body = <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'role': clientRoleId,
        'isActive': isActive,
      };

      final result = await _apiService.post(
        ApiConstant.createClient,
        body: body,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              final client = ClientModel.fromJson(data);
              _logger.logInfo('CLIENT', 'Client created: ${client.username}');
              return Right(client);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create client';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e, stackTrace) {
            _logger.logError(
              tag: 'CLIENT',
              message: 'Client creation parsing error',
              error: e,
              stackTrace: stackTrace,
            );
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.logError(
        tag: 'CLIENT',
        message: 'Client creation exception',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<dynamic, Map<String, dynamic>>> getClients({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final result = await _apiService.get(
        ApiConstant.clients,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              final clientsList = data['clients'] as List<dynamic>? ?? [];
              final pagination = data['pagination'] as Map<String, dynamic>?;

              final clients = clientsList
                  .map(
                    (clientJson) => ClientModel.fromJson(
                      clientJson as Map<String, dynamic>,
                    ),
                  )
                  .toList();

              return Right({'clients': clients, 'pagination': pagination});
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to get clients';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e, stackTrace) {
            _logger.logError(
              tag: 'CLIENT',
              message: 'Clients parsing error',
              error: e,
              stackTrace: stackTrace,
            );
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.logError(
        tag: 'CLIENT',
        message: 'Get clients exception',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<dynamic, bool>> deleteClient(String clientId) async {
    try {
      final result = await _apiService.delete(
        ApiConstant.deleteClient,
        pathParams: {'id': clientId},
        requiresAuth: true,
      );

      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == true) {
              _logger.logInfo('CLIENT', 'Client deleted: $clientId');
              return const Right(true);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete client';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e, stackTrace) {
            _logger.logError(
              tag: 'CLIENT',
              message: 'Client deletion parsing error',
              error: e,
              stackTrace: stackTrace,
            );
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.logError(
        tag: 'CLIENT',
        message: 'Delete client exception',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(StatusRequest.serverException);
    }
  }
}
