import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../Models/api_response_model.dart';
import '../Models/client_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  Future<Either<StatusRequest, Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    print('🔵 ====== AUTH REPOSITORY LOGIN CALLED ======');
    debugPrint('🔵 AuthRepository login called');
    print('Username: $username');
    print('Password length: ${password.length}');
    try {
      print('🔵 Calling API service...');
      final result = await _apiService.post(
        ApiConstant.login,
        body: {'username': username, 'password': password},
        requiresAuth: false,
      );
      print('🔵 API service returned result');
      return result.fold(
        (error) {
          debugPrint('🔴 AuthRepository login error: $error');
          return Left(error);
        },
        (response) async {
          try {
            debugPrint('🟢 AuthRepository login response received');
            debugPrint('Response keys: ${response.keys}');
            debugPrint('Full response: $response');
            print('🔵 ====== FULL LOGIN RESPONSE ======');
            print(response);
            print('🔵 ====== END RESPONSE ======');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              debugPrint('Data keys: ${data.keys}');
              debugPrint('Full data: $data');
              if (data['user'] == null) {
                debugPrint('🔴 User data is null');
                return const Left(StatusRequest.serverFailure);
              }
              final user = data['user'] as Map<String, dynamic>;
              debugPrint('User keys: ${user.keys}');
              debugPrint('Full user: $user');
              String? companyId;

              // البحث عن companyId في أماكن مختلفة
              // 1. في user['companyId']
              if (user['companyId'] != null) {
                debugPrint(
                  '🔵 Found companyId in user.companyId: ${user['companyId']}',
                );
                if (user['companyId'] is Map<String, dynamic>) {
                  companyId = (user['companyId'] as Map<String, dynamic>)['_id']
                      ?.toString();
                  debugPrint('🔵 Extracted companyId from object: $companyId');
                } else {
                  companyId = user['companyId']?.toString();
                  debugPrint('🔵 Using companyId as string: $companyId');
                }
              }

              // 2. في data['companyId']
              if ((companyId == null || companyId.isEmpty) &&
                  data['companyId'] != null) {
                debugPrint(
                  '🔵 Found companyId in data.companyId: ${data['companyId']}',
                );
                if (data['companyId'] is Map<String, dynamic>) {
                  companyId = (data['companyId'] as Map<String, dynamic>)['_id']
                      ?.toString();
                  debugPrint(
                    '🔵 Extracted companyId from data object: $companyId',
                  );
                } else {
                  companyId = data['companyId']?.toString();
                  debugPrint(
                    '🔵 Using companyId from data as string: $companyId',
                  );
                }
              }

              // 3. في response['companyId']
              if ((companyId == null || companyId.isEmpty) &&
                  response['companyId'] != null) {
                debugPrint(
                  '🔵 Found companyId in response.companyId: ${response['companyId']}',
                );
                if (response['companyId'] is Map<String, dynamic>) {
                  companyId =
                      (response['companyId'] as Map<String, dynamic>)['_id']
                          ?.toString();
                  debugPrint(
                    '🔵 Extracted companyId from response object: $companyId',
                  );
                } else {
                  companyId = response['companyId']?.toString();
                  debugPrint(
                    '🔵 Using companyId from response as string: $companyId',
                  );
                }
              }

              await _authService.saveAuthData(
                token: data['token']?.toString() ?? '',
                refreshToken: data['refreshToken']?.toString() ?? '',
                userId: user['_id']?.toString() ?? '',
                email: user['email']?.toString() ?? '',
                username: user['username']?.toString() ?? username,
                role: user['role'] != null
                    ? (user['role'] as Map<String, dynamic>)['name']
                              ?.toString() ??
                          ''
                    : '',
              );
              if (companyId != null && companyId.isNotEmpty) {
                await _authService.saveCompanyId(companyId);
                debugPrint('✅ CompanyId saved successfully: $companyId');
                // التحقق من أن companyId تم حفظه بشكل صحيح
                final savedCompanyId = await _authService.getCompanyId();
                debugPrint('✅ Verified saved companyId: $savedCompanyId');
                print('🔵 ====== COMPANY ID VERIFICATION ======');
                print('Saved: $companyId');
                print('Retrieved: $savedCompanyId');
                print('Match: ${companyId == savedCompanyId}');
                print('🔵 ====== END VERIFICATION ======');
              } else {
                debugPrint('⚠️ CompanyId not found in any location');
                debugPrint(
                  '⚠️ Searched in: user.companyId, data.companyId, response.companyId',
                );
                print('🔴 ====== COMPANY ID NOT FOUND ======');
                print('Response structure:');
                print('  - response keys: ${response.keys}');
                print('  - data keys: ${data.keys}');
                print('  - user keys: ${user.keys}');
                print('🔴 ====== END NOT FOUND ======');
              }
              debugPrint('✅ Authentication data saved successfully');
              return Right(response);
            } else {
              debugPrint(
                '🔴 Login failed: success=${response['success']}, data=${response['data']}',
              );
              debugPrint('Message: ${response['message']}');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Login parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('Login error: $e');
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
    debugPrint('🚪 Logout called');
    try {
      final refreshTokenValue = await _authService.getRefreshToken();
      Map<String, dynamic>? body;
      if (refreshTokenValue != null && refreshTokenValue.isNotEmpty) {
        body = {'refreshToken': refreshTokenValue};
        debugPrint('🔵 Sending logout request with refreshToken');
      } else {
        debugPrint('⚠️ No refresh token found, sending logout without it');
      }
      final result = await _apiService.post(
        ApiConstant.logout,
        body: body,
        requiresAuth: true, // May need auth token
      );
      await _authService.logout();
      debugPrint('✅ Local authentication data cleared');
      return result.fold(
        (error) {
          debugPrint('⚠️ Logout API failed, but logged out locally: $error');
          return const Right(true);
        },
        (response) {
          try {
            debugPrint('🟢 Logout API response received');
            debugPrint('Response keys: ${response.keys}');
            if (response['success'] == true) {
              debugPrint('✅ Logout successful');
              return const Right(true);
            } else {
              debugPrint(
                '⚠️ Logout response indicates failure, but logged out locally',
              );
              return const Right(true);
            }
          } catch (e) {
            debugPrint('⚠️ Error parsing logout response: $e');
            return const Right(true);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 Logout error: $e');
      await _authService.logout();
      return const Right(true);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> refreshToken() async {
    debugPrint('🔄 Refresh token called');
    try {
      final refreshTokenValue = await _authService.getRefreshToken();
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        debugPrint('🔴 No refresh token found');
        return const Left(StatusRequest.serverFailure);
      }
      debugPrint('🔵 Calling refresh token API...');
      final result = await _apiService.post(
        ApiConstant.refreshToken,
        body: {'refreshToken': refreshTokenValue},
        requiresAuth: false,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 Refresh token error: $error');
          return Left(error);
        },
        (response) async {
          try {
            debugPrint('🟢 Refresh token response received');
            debugPrint('Response keys: ${response.keys}');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              debugPrint('Data keys: ${data.keys}');
              final newToken = data['token']?.toString() ?? '';
              final newRefreshToken = data['refreshToken']?.toString() ?? '';
              if (newToken.isEmpty) {
                debugPrint('🔴 New token is empty');
                return const Left(StatusRequest.serverFailure);
              }
              await _authService.saveToken(newToken);
              if (newRefreshToken.isNotEmpty) {
                await _authService.saveRefreshToken(newRefreshToken);
              }
              debugPrint('✅ Tokens refreshed successfully');
              return Right(response);
            } else {
              debugPrint(
                '🔴 Refresh token failed: success=${response['success']}, data=${response['data']}',
              );
              debugPrint('Message: ${response['message']}');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Refresh token parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 Refresh token error: $e');
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

  Future<Either<dynamic, ClientModel>> createClient({
    required String username,
    required String email,
    required String password,
    required bool isActive,
  }) async {
    debugPrint('🔵 AuthRepository: Creating client...');
    try {
      final body = <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'role': '6942a1b121d1fb7ea37ae3ed',
        'isActive': isActive,
      };
      debugPrint('🔵 Request body: $body');
      final result = await _apiService.post(
        ApiConstant.createClient,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 AuthRepository error creating client: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 AuthRepository create client response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              final client = ClientModel.fromJson(data);
              debugPrint('✅ Successfully created client: ${client.username}');
              return Right(client);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create client';
              debugPrint('🔴 Failed to create client: $errorMessage');
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Client creation parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 AuthRepository exception creating client: $e');
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<dynamic, Map<String, dynamic>>> getClients({
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('🔵 AuthRepository: Getting clients...');
    debugPrint('Page: $page, Limit: $limit');
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
          debugPrint('🔴 AuthRepository error getting clients: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 AuthRepository get clients response received');
            debugPrint('🟢 Response: $response');
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
              debugPrint('✅ Successfully loaded ${clients.length} clients');
              return Right({'clients': clients, 'pagination': pagination});
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to get clients';
              debugPrint('🔴 Failed to get clients: $errorMessage');
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Clients parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 AuthRepository exception getting clients: $e');
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<dynamic, bool>> deleteClient(String clientId) async {
    debugPrint('🔵 AuthRepository: Deleting client...');
    debugPrint('Client ID: $clientId');
    try {
      final result = await _apiService.delete(
        ApiConstant.deleteClient,
        pathParams: {'id': clientId},
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 AuthRepository error deleting client: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 AuthRepository delete client response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == true) {
              debugPrint('✅ Successfully deleted client');
              return const Right(true);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete client';
              debugPrint('🔴 Failed to delete client: $errorMessage');
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Client deletion parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 AuthRepository exception deleting client: $e');
      return const Left(StatusRequest.serverException);
    }
  }
}
