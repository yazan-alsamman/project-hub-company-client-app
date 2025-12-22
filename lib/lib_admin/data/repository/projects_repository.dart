import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import '../Models/project_model.dart';
import '../Models/client_model.dart';
class ProjectsRepository {
  final ApiService _apiService = ApiService();
  Future<Either<StatusRequest, int>> getProjectsCount({
    required String? companyId,
  }) async {
    debugPrint('🔵 ProjectsRepository: Getting projects count...');
    try {
      final queryParams = <String, String>{
        'page': '1',
        'limit': '1', // Just need pagination info
      };
      if (companyId != null && companyId.isNotEmpty) {
        queryParams['companyId'] = companyId;
      }
      final result = await _apiService.get(
        ApiConstant.projects,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint(
            '🔴 ProjectsRepository error getting projects count: $error',
          );
          return Left(error);
        },
        (response) {
          try {
            debugPrint(
              '🟢 ProjectsRepository get projects count response received',
            );
            debugPrint('🟢 Response: $response');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              Map<String, dynamic>? dataMap;
              if (data is Map<String, dynamic>) {
                dataMap = data;
              } else {
                debugPrint('🔴 Unexpected data format for projects count');
                return const Left(StatusRequest.serverFailure);
              }
              if (dataMap['pagination'] != null) {
                final pagination =
                    dataMap['pagination'] as Map<String, dynamic>;
                final total = pagination['total'] as int? ?? 0;
                debugPrint('✅ Projects total count from pagination: $total');
                return Right(total);
              }
              if (dataMap['projects'] is List) {
                final projectsList = dataMap['projects'] as List;
                debugPrint(
                  '✅ Projects count from array: ${projectsList.length}',
                );
                return Right(projectsList.length);
              }
              debugPrint('🔴 No pagination or projects array found');
              return const Left(StatusRequest.serverFailure);
            } else {
              debugPrint('🔴 Response validation failed for projects count');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Projects count parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 ProjectsRepository exception getting projects count: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, List<ProjectModel>>> getProjects({
    String? status,
    int page = 1,
    int limit = 10,
    String? companyId,
  }) async {
    debugPrint('🔵 ProjectsRepository: Getting projects...');
    debugPrint(
      'Page: $page, Limit: $limit, CompanyId: $companyId, Status: $status',
    );
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (companyId != null && companyId.isNotEmpty) {
        queryParams['companyId'] = companyId;
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] =
            status; // Keep original case (in_progress has underscore)
        debugPrint('🔵 Adding status filter to query: $status');
      }
      debugPrint('Query params: $queryParams');
      final finalUrl =
          '${ApiConstant.baseUrl}${ApiConstant.projects}?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      debugPrint('🔵 Final API URL: $finalUrl');
      final result = await _apiService.get(
        ApiConstant.projects,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 ProjectsRepository error: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 ProjectsRepository response received');
            debugPrint('🟢 Full response: $response');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              debugPrint('🟢 Data type: ${data.runtimeType}');
              debugPrint('🟢 Data: $data');
              List<dynamic> projectsList;
              if (data is List) {
                projectsList = data;
                debugPrint(
                  '🟢 Found direct array format with ${projectsList.length} items',
                );
              } else if (data is Map<String, dynamic>) {
                if (data['projects'] is List) {
                  projectsList = data['projects'] as List<dynamic>;
                  if (data['pagination'] != null) {
                    final pagination =
                        data['pagination'] as Map<String, dynamic>;
                    debugPrint(
                      '🟢 Pagination: page=${pagination['page']}, limit=${pagination['limit']}, total=${pagination['total']}, totalPages=${pagination['totalPages']}',
                    );
                  }
                } else if (data['data'] is List) {
                  projectsList = data['data'] as List<dynamic>;
                } else {
                  debugPrint('🔴 Unexpected data format: ${data.runtimeType}');
                  return const Left(StatusRequest.serverFailure);
                }
              } else {
                debugPrint('🔴 Unexpected data format: ${data.runtimeType}');
                return const Left(StatusRequest.serverFailure);
              }
              debugPrint('🟢 Found ${projectsList.length} projects in list');
              final projects = projectsList.map((item) {
                try {
                  return ProjectModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('🔴 Error parsing project: $e');
                  debugPrint('🔴 Project data: $item');
                  rethrow;
                }
              }).toList();
              debugPrint('✅ Successfully parsed ${projects.length} projects');
              return Right(projects);
            } else {
              debugPrint('🔴 Response validation failed:');
              debugPrint('🔴 success: ${response['success']}');
              debugPrint('🔴 message: ${response['message']}');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Project parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 ProjectsRepository exception: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, ProjectModel>> getProjectById(String id) async {
    try {
      final result = await _apiService.get(
        ApiConstant.projectDetails,
        pathParams: {'id': id},
        requiresAuth: true,
      );
      return result.fold((error) => Left(error), (response) {
        try {
          if (response['success'] == true && response['data'] != null) {
            final projectData = response['data'];
            Map<String, dynamic> projectJson;
            if (projectData is Map<String, dynamic>) {
              projectJson = projectData;
            } else {
              return const Left(StatusRequest.serverFailure);
            }
            final project = ProjectModel.fromJson(projectJson);
            return Right(project);
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
  Future<Either<StatusRequest, List<ClientModel>>> getClients({
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('🔵 ProjectsRepository: Getting clients...');
    debugPrint('🔵 Page: $page, Limit: $limit');
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      debugPrint('🔵 Query params: $queryParams');
      final finalUrl =
          '${ApiConstant.baseUrl}${ApiConstant.clients}?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      debugPrint('🔵 Final API URL: $finalUrl');
      final result = await _apiService.get(
        ApiConstant.clients,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 ProjectsRepository error getting clients: $error');
          debugPrint('🔴 Error type: ${error.runtimeType}');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 ProjectsRepository get clients response received');
            debugPrint('🟢 Response type: ${response.runtimeType}');
            debugPrint('🟢 Full response: $response');
            debugPrint('🟢 Response keys: ${response.keys}');
            final success = response['success'];
            final data = response['data'];
            debugPrint(
              '🟢 success value: $success (type: ${success.runtimeType})',
            );
            debugPrint('🟢 data value: $data (type: ${data?.runtimeType})');
            debugPrint('🟢 success == true: ${success == true}');
            debugPrint('🟢 data != null: ${data != null}');
            if (success == true && data != null) {
              debugPrint('🟢 Data type: ${data.runtimeType}');
              debugPrint('🟢 Data: $data');
              List<dynamic> clientsList;
              if (data is Map<String, dynamic>) {
                debugPrint('🟢 Data is Map<String, dynamic>');
                debugPrint('🟢 Data keys: ${data.keys}');
                if (data.containsKey('clients')) {
                  final clientsValue = data['clients'];
                  debugPrint(
                    '🟢 clients key exists, value type: ${clientsValue.runtimeType}',
                  );
                  debugPrint('🟢 clients value: $clientsValue');
                  if (clientsValue is List) {
                    clientsList = clientsValue;
                    debugPrint(
                      '🟢 Found clients array with ${clientsList.length} items',
                    );
                  } else {
                    debugPrint('🔴 clients value is not a List');
                    debugPrint(
                      '🔴 clients value type: ${clientsValue.runtimeType}',
                    );
                    return const Left(StatusRequest.serverFailure);
                  }
                } else {
                  debugPrint('🔴 Data Map does not contain "clients" key');
                  debugPrint('🔴 Available keys: ${data.keys}');
                  return const Left(StatusRequest.serverFailure);
                }
              } else if (data is List) {
                clientsList = data;
                debugPrint(
                  '🟢 Data is directly a List with ${clientsList.length} items',
                );
              } else {
                debugPrint('🔴 Unexpected data format for clients');
                debugPrint('🔴 Data type: ${data.runtimeType}');
                return const Left(StatusRequest.serverFailure);
              }
              debugPrint('🟢 Found ${clientsList.length} clients in list');
              if (clientsList.isEmpty) {
                debugPrint('⚠️ Clients list is empty');
                return Right([]);
              }
              final clients = clientsList.map((item) {
                try {
                  debugPrint('🟢 Parsing client: $item');
                  if (item is! Map<String, dynamic>) {
                    debugPrint('🔴 Client item is not Map<String, dynamic>');
                    throw Exception('Client item is not a Map');
                  }
                  return ClientModel.fromJson(item);
                } catch (e) {
                  debugPrint('🔴 Error parsing client: $e');
                  debugPrint('🔴 Client data: $item');
                  rethrow;
                }
              }).toList();
              debugPrint('✅ Successfully parsed ${clients.length} clients');
              for (var i = 0; i < clients.length; i++) {
                debugPrint(
                  '  ✅ Client $i: ${clients[i].displayName} (${clients[i].id})',
                );
              }
              return Right(clients);
            } else {
              debugPrint('🔴 Response validation failed for clients');
              debugPrint('🔴 success: $success');
              debugPrint('🔴 success type: ${success.runtimeType}');
              debugPrint('🔴 success == true: ${success == true}');
              debugPrint('🔴 message: ${response['message']}');
              debugPrint('🔴 data: $data');
              debugPrint('🔴 data is null: ${data == null}');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Clients parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 ProjectsRepository exception getting clients: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<dynamic, ProjectModel>> createProject({
    required String companyId,
    required String clientId,
    required String name,
    required String code,
    required String status,
    required String startAt,
    required String estimatedEndAt,
    int safeDelay = 7,
  }) async {
    debugPrint('🔵 ProjectsRepository: Creating project...');
    debugPrint('✅ CompanyId received: $companyId');
    if (companyId.isEmpty) {
      debugPrint('🔴 ERROR: CompanyId is empty!');
      return Left({
        'error': StatusRequest.serverFailure,
        'message': 'Company ID is required',
      });
    }
    try {
      final body = <String, dynamic>{
        'companyId': companyId,
        'clientId': clientId,
        'name': name,
        'code': code,
        'status': status,
        'startAt': startAt,
        'estimatedEndAt': estimatedEndAt,
        'safeDelay': safeDelay,
      };
      debugPrint('🔵 Request body: $body');
      final result = await _apiService.post(
        ApiConstant.createProject,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 ProjectsRepository error creating project: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint(
              '🟢 ProjectsRepository create project response received',
            );
            debugPrint('🟢 Response: $response');
            if (response['success'] == false || response['success'] == null) {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create project';
              debugPrint('🔴 API returned success: false or null');
              debugPrint('🔴 Error message: $errorMessage');
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
            if (response['success'] == true && response['data'] != null) {
              final projectData = response['data'] as Map<String, dynamic>;
              final project = ProjectModel.fromJson(projectData);
              debugPrint('✅ Successfully created project: ${project.title}');
              return Right(project);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create project';
              debugPrint('🔴 Failed to create project');
              debugPrint(
                '🔴 Response structure: success=${response['success']}, data=${response['data']}',
              );
              debugPrint('🔴 Error message: $errorMessage');
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Project creation parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 ProjectsRepository exception creating project: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, ProjectModel>> updateProject({
    required String projectId,
    required String status,
    required String code,
    required int safeDelay,
  }) async {
    debugPrint('🔵 ProjectsRepository: Updating project...');
    debugPrint('🔵 ProjectId: $projectId');
    debugPrint('🔵 Status: $status, Code: $code, SafeDelay: $safeDelay');
    try {
      final body = <String, dynamic>{
        'status': status,
        'code': code,
        'safeDelay': safeDelay,
      };
      debugPrint('🔵 Request body: $body');
      final result = await _apiService.put(
        ApiConstant.updateProject,
        pathParams: {'id': projectId},
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 ProjectsRepository error updating project: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint(
              '🟢 ProjectsRepository update project response received',
            );
            debugPrint('🟢 Response: $response');
            if (response['success'] == false || response['success'] == null) {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update project';
              debugPrint('🔴 API returned success: false or null');
              debugPrint('🔴 Error message: $errorMessage');
              return Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final projectData = response['data'] as Map<String, dynamic>;
              final project = ProjectModel.fromJson(projectData);
              debugPrint('✅ Successfully updated project: ${project.title}');
              return Right(project);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update project';
              debugPrint('🔴 Failed to update project');
              debugPrint(
                '🔴 Response structure: success=${response['success']}, data=${response['data']}',
              );
              debugPrint('🔴 Error message: $errorMessage');
              return Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Project update parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 ProjectsRepository exception updating project: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, bool>> deleteProject(String projectId) async {
    debugPrint('🔵 ProjectsRepository: Deleting project...');
    debugPrint('🔵 ProjectId: $projectId');
    try {
      final result = await _apiService.delete(
        ApiConstant.deleteProject,
        pathParams: {'id': projectId},
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 ProjectsRepository error deleting project: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint(
              '🟢 ProjectsRepository delete project response received',
            );
            debugPrint('🟢 Response: $response');
            if (response['success'] == true) {
              debugPrint('✅ Successfully deleted project');
              return const Right(true);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete project';
              debugPrint('🔴 Failed to delete project');
              debugPrint('🔴 Error message: $errorMessage');
              return Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Project delete parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 ProjectsRepository exception deleting project: $e');
      return const Left(StatusRequest.serverException);
    }
  }
}
