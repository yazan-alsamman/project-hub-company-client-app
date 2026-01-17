import 'package:dartz/dartz.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import '../Models/employee_model.dart';
import '../Models/role_model.dart';
import '../Models/position_model.dart';
import '../Models/department_model.dart';

class TeamRepository {
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
  Future<Either<dynamic, List<EmployeeModel>>> getEmployees({
    int page = 1,
    int limit = 10,
    String? companyId,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (companyId != null && companyId.isNotEmpty) {
        queryParams['companyId'] = companyId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      final result = await _apiService.get(
        ApiConstant.employees,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to fetch employees';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              List<dynamic> employeesList;
              if (data is List) {
                employeesList = data;
              } else if (data is Map<String, dynamic>) {
                if (data['employees'] is List) {
                  employeesList = data['employees'] as List<dynamic>;
                } else if (data['data'] is List) {
                  employeesList = data['data'] as List<dynamic>;
                } else {
                  return const Left(StatusRequest.serverFailure);
                }
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              final employees = employeesList.map((item) {
                try {
                  return EmployeeModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  rethrow;
                }
              }).toList();
              return Right(employees);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to fetch employees';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
          } catch (e, stackTrace) {
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
  Future<Either<dynamic, EmployeeModel>> getEmployeeById(
    String id,
  ) async {
    try {
      final result = await _apiService.get(
        ApiConstant.employeeDetails,
        pathParams: {'id': id},
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to fetch employee';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              Map<String, dynamic> employeeData;
              if (data is Map<String, dynamic>) {
                employeeData = data;
              } else {
                return Left({'error': StatusRequest.serverFailure, 'message': 'Invalid employee data'});
              }
              final employee = EmployeeModel.fromJson(employeeData);
              return Right(employee);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to fetch employee';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
          } catch (e, stackTrace) {
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
  Future<Either<dynamic, EmployeeModel>> createEmployeeWithUser({
    required String companyId,
    required String employeeCode,
    required String position,
    required String department,
    required String hireDate,
    required int salary,
    required String status,
    String? subRole,
    required String username,
    required String email,
    required String password,
    required String roleId,
    bool isActive = true,
  }) async {
    if (companyId.isEmpty) {
      return Left({
        'error': StatusRequest.serverFailure,
        'message': 'Company ID is required',
      });
    }
    try {
      String formattedHireDate = hireDate;
      if (!hireDate.contains('T')) {
        formattedHireDate = '${hireDate}T00:00:00.000Z';
      }
      final body = <String, dynamic>{
        'employee': {
          'companyId': companyId,
          'employeeCode': employeeCode,
          'position': position,
          'department': department,
          'hireDate': formattedHireDate,
          'salary': salary,
          'status': status,
        },
        'user': {
          'username': username,
          'email': email,
          'password': password,
          'roleId': roleId,
          'isActive': isActive,
        },
      };
      if (subRole != null && subRole.isNotEmpty) {
        (body['employee'] as Map<String, dynamic>)['subRole'] = subRole;
      }
      final result = await _apiService.post(
        ApiConstant.createEmployeeWithUser,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create employee with user';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              if (data['employee'] == null) {
                final errorMessage =
                    response['message']?.toString() ??
                    'Employee data not found in response';
                return Left({
                  'error': StatusRequest.serverFailure,
                  'message': errorMessage,
                });
              }
              final employeeData = data['employee'] as Map<String, dynamic>;
              final employee = EmployeeModel.fromJson(employeeData);
              return Right(employee);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create employee with user';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e, stackTrace) {
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
  Future<Either<dynamic, EmployeeModel>> createEmployee({
    required String userId,
    required String companyId,
    required String employeeCode,
    required String position,
    required String department,
    required String hireDate,
    required int salary,
    required String status,
    String? subRole,
  }) async {
    try {
      final body = <String, dynamic>{
        'userId': userId,
        'companyId': companyId,
        'employeeCode': employeeCode,
        'position': position,
        'department': department,
        'hireDate': hireDate,
        'salary': salary,
        'status': status,
      };
      if (subRole != null && subRole.isNotEmpty) {
        body['subRole'] = subRole;
      }
      final result = await _apiService.post(
        ApiConstant.employees,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create employee';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true && response['data'] != null) {
              final employeeData = response['data'] as Map<String, dynamic>;
              final employee = EmployeeModel.fromJson(employeeData);
              return Right(employee);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create employee';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
          } catch (e, stackTrace) {
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
  Future<Either<dynamic, EmployeeModel>> updateEmployee({
    required String employeeId,
    required String position,
    required int salary,
    required String status,
    String? subRole,
    required String department,
  }) async {
    try {
      final body = <String, dynamic>{
        'position': position,
        'salary': salary,
        'status': status,
        'department': department,
      };
      if (subRole != null && subRole.isNotEmpty) {
        body['subRole'] = subRole;
      }
      final result = await _apiService.put(
        ApiConstant.updateEmployee,
        pathParams: {'id': employeeId},
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update employee';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
            if (response['success'] == true && response['data'] != null) {
              final employeeData = response['data'] as Map<String, dynamic>;
              final employee = EmployeeModel.fromJson(employeeData);
              return Right(employee);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update employee';
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
          } catch (e, stackTrace) {
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
  Future<Either<dynamic, bool>> deleteEmployee(String employeeId) async {
    try {
      final result = await _apiService.delete(
        ApiConstant.deleteEmployee,
        pathParams: {'id': employeeId},
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left({'error': error, 'message': _getErrorMessage(error)});
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete employee';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
            if (response['success'] == true) {
              return const Right(true);
            } else {
              final errorMessage = response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete employee';
              return Left({'error': StatusRequest.serverFailure, 'message': errorMessage});
            }
          } catch (e, stackTrace) {
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
  Future<Either<StatusRequest, List<RoleModel>>> getRoles() async {
    try {
      final result = await _apiService.get(
        ApiConstant.roles,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              List<dynamic> rolesList;
              if (data is List) {
                rolesList = data;
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              final roles = rolesList.map((item) {
                try {
                  return RoleModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  rethrow;
                }
              }).toList();
              return Right(roles);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, List<PositionModel>>> getPositions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final result = await _apiService.get(
        ApiConstant.positions,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              List<dynamic> positionsList;
              if (data['positions'] is List) {
                positionsList = data['positions'] as List<dynamic>;
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              final positions = positionsList.map((item) {
                try {
                  return PositionModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  rethrow;
                }
              }).toList();
              return Right(positions);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, int>> getDepartmentsCount() async {
    try {
      final result = await _apiService.get(
        ApiConstant.departments,
        queryParams: {'page': '1', 'limit': '1'},
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              if (data['pagination'] != null) {
                final pagination = data['pagination'] as Map<String, dynamic>;
                final total = pagination['total'] as int? ?? 0;
                return Right(total);
              }
              if (data['departments'] is List) {
                final departmentsList = data['departments'] as List;
                return Right(departmentsList.length);
              }
              return const Left(StatusRequest.serverFailure);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, List<DepartmentModel>>> getDepartments({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final result = await _apiService.get(
        ApiConstant.departments,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          return Left(error);
        },
        (response) {
          try {
            if (response['success'] == false || response['success'] == null) {
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              List<dynamic> departmentsList;
              if (data['departments'] is List) {
                departmentsList = data['departments'] as List<dynamic>;
              } else {
                return const Left(StatusRequest.serverFailure);
              }
              final departments = departmentsList.map((item) {
                try {
                  return DepartmentModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  rethrow;
                }
              }).toList();
              return Right(departments);
            } else {
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      return const Left(StatusRequest.serverException);
    }
  }
}
