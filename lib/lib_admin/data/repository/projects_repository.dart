import 'package:dartz/dartz.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import '../Models/project_model.dart';
import '../Models/client_model.dart';

class ProjectsRepository {
  final ApiService _apiService = ApiService();

  String _getErrorMessage(StatusRequest error) {
    switch (error) {
      case StatusRequest.serverFailure:
        return 'Server error. Please try again.';
      case StatusRequest.offlineFailure:
        return 'No internet connection. Please check your network.';
      case StatusRequest.timeoutException:
        return 'Request timed out. Please try again.';
      case StatusRequest.serverException:
        return 'An unexpected error occurred.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Future<Either<StatusRequest, int>> getProjectsCount({
    required String? companyId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': '1',
        'limit': '1',
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
        (error) => Left(error),
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              Map<String, dynamic>? dataMap;
              if (data is Map<String, dynamic>) {
                dataMap = data;
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              if (dataMap['pagination'] != null) {
                final pagination = dataMap['pagination'] as Map<String, dynamic>;
                final total = pagination['total'] as int? ?? 0;
                return Right(total);
              }
              if (dataMap['projects'] is List) {
                final projectsList = dataMap['projects'] as List;
                return Right(projectsList.length);
              }
              return const Left(StatusRequest.serverFailure);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<StatusRequest, List<ProjectModel>>> getProjects({
    String? status,
    int page = 1,
    int limit = 10,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (companyId != null && companyId.isNotEmpty) {
        queryParams['companyId'] = companyId;
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status;
      }
      final result = await _apiService.get(
        ApiConstant.projects,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) => Left(error),
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              List<dynamic> projectsList;
              if (data is List) {
                projectsList = data;
              } else if (data is Map<String, dynamic>) {
                if (data['projects'] is List) {
                  projectsList = data['projects'] as List<dynamic>;
                } else if (data['data'] is List) {
                  projectsList = data['data'] as List<dynamic>;
                } else {
                  return const Left(StatusRequest.serverFailure);
                }
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              final projects = projectsList.map((item) {
                return ProjectModel.fromJson(item as Map<String, dynamic>);
              }).toList();
              return Right(projects);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
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
          if (response['success'] == false || response['success'] == null) {
            return const Left(StatusRequest.serverFailure);
          }
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
        (error) => Left(error),
        (response) {
          try {
            final success = response['success'];
            final data = response['data'];
            if (success == false || success == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (success == true && data != null) {
              List<dynamic> clientsList;
              if (data is Map<String, dynamic>) {
                if (data.containsKey('clients')) {
                  final clientsValue = data['clients'];
                  if (clientsValue is List) {
                    clientsList = clientsValue;
                  } else {
                    return const Left(StatusRequest.serverFailure);
                  }
                } else {
                  return const Left(StatusRequest.serverFailure);
                }
              } else if (data is List) {
                clientsList = data;
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              if (clientsList.isEmpty) {
                return Right([]);
              }
              final clients = clientsList.map((item) {
                if (item is! Map<String, dynamic>) {
                  throw Exception('Client item is not a Map');
                }
                return ClientModel.fromJson(item);
              }).toList();
              return Right(clients);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
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
    if (companyId.isEmpty) {
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
      final result = await _apiService.post(
        ApiConstant.createProject,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({
            'error': error,
            'message': _getErrorMessage(error),
          });
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create project';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
            if (response['success'] == true && response['data'] != null) {
              final projectData = response['data'] as Map<String, dynamic>;
              final project = ProjectModel.fromJson(projectData);
              return Right(project);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create project';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e) {
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      return Left({
        'error': StatusRequest.serverException,
        'message': 'An unexpected error occurred.',
      });
    }
  }

  Future<Either<dynamic, ProjectModel>> updateProject({
    required String projectId,
    required String status,
    required String code,
    required int safeDelay,
    String? clientId,
  }) async {
    try {
      final body = <String, dynamic>{
        'status': status,
        'code': code,
        'safeDelay': safeDelay,
      };
      if (clientId != null && clientId.isNotEmpty) {
        body['clientId'] = clientId;
      }
      final result = await _apiService.put(
        ApiConstant.updateProject,
        pathParams: {'id': projectId},
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({
            'error': error,
            'message': _getErrorMessage(error),
          });
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update project';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
            if (response['success'] == true && response['data'] != null) {
              final projectData = response['data'] as Map<String, dynamic>;
              final project = ProjectModel.fromJson(projectData);
              return Right(project);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update project';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e) {
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }

  Future<Either<dynamic, bool>> deleteProject(String projectId) async {
    try {
      final result = await _apiService.delete(
        ApiConstant.deleteProject,
        pathParams: {'id': projectId},
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({
            'error': error,
            'message': _getErrorMessage(error),
          });
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete project';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
            if (response['success'] == true) {
              return const Right(true);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete project';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e) {
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      return Left({
        'error': StatusRequest.serverException,
        'message': 'An unexpected error occurred.',
      });
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getProjectStats({
    String? companyId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (companyId != null && companyId.isNotEmpty) {
        queryParams['companyId'] = companyId;
      }
      final result = await _apiService.get(
        ApiConstant.projectStats,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) => Left(error),
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              if (data is Map<String, dynamic>) {
                return Right(data);
              } else {
                return const Left(StatusRequest.serverFailure);
              }
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }
}
