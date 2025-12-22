import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import '../Models/employee_model.dart';
import '../Models/role_model.dart';
import '../Models/position_model.dart';
import '../Models/department_model.dart';
class TeamRepository {
  final ApiService _apiService = ApiService();
  Future<Either<StatusRequest, List<EmployeeModel>>> getEmployees({
    int page = 1,
    int limit = 10,
    String? companyId,
    String? status,
  }) async {
    debugPrint('🔵 TeamRepository: Getting employees...');
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
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      debugPrint('Query params: $queryParams');
      final finalUrl =
          '${ApiConstant.baseUrl}${ApiConstant.employees}?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      debugPrint('🔵 Final API URL: $finalUrl');
      final result = await _apiService.get(
        ApiConstant.employees,
        queryParams: queryParams,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 TeamRepository error: $error');
          debugPrint('🔴 Error type: ${error.runtimeType}');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 TeamRepository response received');
            debugPrint('🟢 Full response: $response');
            debugPrint('🟢 Response keys: ${response.keys}');
            debugPrint('🟢 Response type: ${response.runtimeType}');
            if (response['success'] == false ||
                (response['success'] == null && response['message'] != null)) {
              debugPrint('🔴 API returned success: false or null');
              debugPrint('🔴 Error message: ${response['message']}');
              return const Left(StatusRequest.serverFailure);
            }
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              debugPrint('🟢 Data type: ${data.runtimeType}');
              debugPrint('🟢 Data: $data');
              List<dynamic> employeesList;
              if (data is List) {
                employeesList = data;
                debugPrint(
                  '🟢 Found direct array format with ${employeesList.length} items',
                );
              } else if (data is Map<String, dynamic>) {
                if (data['employees'] is List) {
                  employeesList = data['employees'] as List<dynamic>;
                  if (data['pagination'] != null) {
                    final pagination =
                        data['pagination'] as Map<String, dynamic>;
                    debugPrint(
                      '🟢 Pagination: page=${pagination['page']}, limit=${pagination['limit']}, total=${pagination['total']}, totalPages=${pagination['totalPages']}',
                    );
                  }
                } else if (data['data'] is List) {
                  employeesList = data['data'] as List<dynamic>;
                } else {
                  debugPrint('🔴 Unexpected data format: ${data.runtimeType}');
                  debugPrint('🔴 Data keys: ${data.keys}');
                  return const Left(StatusRequest.serverFailure);
                }
              } else {
                debugPrint('🔴 Unexpected data format: ${data.runtimeType}');
                return const Left(StatusRequest.serverFailure);
              }
              debugPrint('🟢 Found ${employeesList.length} employees in list');
              final employees = employeesList.map((item) {
                try {
                  return EmployeeModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('🔴 Error parsing employee: $e');
                  debugPrint('🔴 Employee data: $item');
                  rethrow;
                }
              }).toList();
              debugPrint('✅ Successfully parsed ${employees.length} employees');
              return Right(employees);
            } else {
              debugPrint('🔴 Response validation failed:');
              debugPrint('🔴 success: ${response['success']}');
              debugPrint('🔴 message: ${response['message']}');
              debugPrint('🔴 data: ${response['data']}');
              debugPrint('🔴 data is null: ${response['data'] == null}');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Employee parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TeamRepository exception: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, EmployeeModel>> getEmployeeById(
    String id,
  ) async {
    try {
      final result = await _apiService.get(
        ApiConstant.employeeDetails,
        pathParams: {'id': id},
        requiresAuth: true,
      );
      return result.fold((error) => Left(error), (response) {
        try {
          debugPrint('🟢 getEmployeeById response received');
          debugPrint('🟢 Response: $response');
          if (response['success'] == true && response['data'] != null) {
            final data = response['data'];
            Map<String, dynamic> employeeData;
            if (data is Map<String, dynamic>) {
              employeeData = data;
            } else {
              debugPrint('🔴 Unexpected data format for employee details');
              return const Left(StatusRequest.serverFailure);
            }
            final employee = EmployeeModel.fromJson(employeeData);
            debugPrint('✅ Successfully parsed employee: ${employee.username}');
            return Right(employee);
          } else {
            debugPrint('🔴 Response validation failed for employee details');
            return const Left(StatusRequest.serverFailure);
          }
        } catch (e, stackTrace) {
          debugPrint('🔴 Employee parsing error: $e');
          debugPrint('Stack trace: $stackTrace');
          return const Left(StatusRequest.serverException);
        }
      });
    } catch (e) {
      return const Left(StatusRequest.serverException);
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
    debugPrint('🔵 TeamRepository: Creating employee with user...');
    debugPrint('✅ CompanyId received: $companyId');
    if (companyId.isEmpty) {
      debugPrint('🔴 ERROR: CompanyId is empty!');
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
      debugPrint('🔵 Request body: $body');
      final result = await _apiService.post(
        ApiConstant.createEmployeeWithUser,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint(
            '🔴 TeamRepository error creating employee with user: $error',
          );
          return Left(error);
        },
        (response) {
          try {
            debugPrint(
              '🟢 TeamRepository create employee with user response received',
            );
            debugPrint('🟢 Response: $response');
            if (response['success'] == false || response['success'] == null) {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create employee with user';
              debugPrint('🔴 API returned success: false or null');
              debugPrint('🔴 Error message: $errorMessage');
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
                debugPrint('🔴 Employee data not found in response');
                return Left({
                  'error': StatusRequest.serverFailure,
                  'message': errorMessage,
                });
              }
              final employeeData = data['employee'] as Map<String, dynamic>;
              final employee = EmployeeModel.fromJson(employeeData);
              debugPrint(
                '✅ Successfully created employee with user: ${employee.username}',
              );
              return Right(employee);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to create employee with user';
              debugPrint('🔴 Failed to create employee with user');
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
            debugPrint('🔴 Employee creation parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TeamRepository exception creating employee with user: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, EmployeeModel>> createEmployee({
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
    debugPrint('🔵 TeamRepository: Creating employee...');
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
      debugPrint('🔵 Request body: $body');
      final result = await _apiService.post(
        ApiConstant.employees,
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 TeamRepository error creating employee: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 TeamRepository create employee response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == true && response['data'] != null) {
              final employeeData = response['data'] as Map<String, dynamic>;
              final employee = EmployeeModel.fromJson(employeeData);
              debugPrint(
                '✅ Successfully created employee: ${employee.username}',
              );
              return Right(employee);
            } else {
              debugPrint('🔴 Failed to create employee');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Employee creation parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TeamRepository exception creating employee: $e');
      return const Left(StatusRequest.serverException);
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
    debugPrint('🔵 TeamRepository: Updating employee...');
    debugPrint('🔵 EmployeeId: $employeeId');
    debugPrint('🔵 Position: $position, Salary: $salary, Status: $status');
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
      debugPrint('🔵 Request body: $body');
      final result = await _apiService.put(
        ApiConstant.updateEmployee,
        pathParams: {'id': employeeId},
        body: body,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 TeamRepository error updating employee: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 TeamRepository update employee response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == false || response['success'] == null) {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update employee';
              debugPrint('🔴 API returned success: false or null');
              debugPrint('🔴 Error message: $errorMessage');
              return Left({
                'error': StatusRequest.serverFailure,
                'message': errorMessage,
              });
            }
            if (response['success'] == true && response['data'] != null) {
              final employeeData = response['data'] as Map<String, dynamic>;
              final employee = EmployeeModel.fromJson(employeeData);
              debugPrint(
                '✅ Successfully updated employee: ${employee.username}',
              );
              return Right(employee);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to update employee';
              debugPrint('🔴 Failed to update employee');
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
            debugPrint('🔴 Employee update parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return Left({
              'error': StatusRequest.serverException,
              'message': 'An error occurred while processing the response: $e',
            });
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TeamRepository exception updating employee: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, bool>> deleteEmployee(String employeeId) async {
    debugPrint('🔵 TeamRepository: Deleting employee...');
    debugPrint('🔵 EmployeeId: $employeeId');
    try {
      final result = await _apiService.delete(
        ApiConstant.deleteEmployee,
        pathParams: {'id': employeeId},
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 TeamRepository error deleting employee: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 TeamRepository delete employee response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == true) {
              debugPrint('✅ Successfully deleted employee');
              return const Right(true);
            } else {
              final errorMessage =
                  response['message']?.toString() ??
                  response['error']?.toString() ??
                  'Failed to delete employee';
              debugPrint('🔴 Failed to delete employee');
              debugPrint('🔴 Error message: $errorMessage');
              return Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Employee delete parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TeamRepository exception deleting employee: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, List<RoleModel>>> getRoles() async {
    debugPrint('🔵 TeamRepository: Getting roles...');
    try {
      final result = await _apiService.get(
        ApiConstant.roles,
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint('🔴 TeamRepository error getting roles: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 TeamRepository get roles response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'];
              List<dynamic> rolesList;
              if (data is List) {
                rolesList = data;
              } else {
                debugPrint('🔴 Unexpected data format for roles');
                return const Left(StatusRequest.serverFailure);
              }
              debugPrint('🟢 Found ${rolesList.length} roles in list');
              final roles = rolesList.map((item) {
                try {
                  return RoleModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('🔴 Error parsing role: $e');
                  debugPrint('🔴 Role data: $item');
                  rethrow;
                }
              }).toList();
              debugPrint('✅ Successfully parsed ${roles.length} roles');
              return Right(roles);
            } else {
              debugPrint('🔴 Response validation failed for roles');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Roles parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TeamRepository exception getting roles: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, List<PositionModel>>> getPositions({
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('🔵 TeamRepository: Getting positions...');
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
          debugPrint('🔴 TeamRepository error getting positions: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 TeamRepository get positions response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              List<dynamic> positionsList;
              if (data['positions'] is List) {
                positionsList = data['positions'] as List<dynamic>;
              } else {
                debugPrint('🔴 Unexpected data format for positions');
                return const Left(StatusRequest.serverFailure);
              }
              debugPrint('🟢 Found ${positionsList.length} positions in list');
              final positions = positionsList.map((item) {
                try {
                  return PositionModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('🔴 Error parsing position: $e');
                  debugPrint('🔴 Position data: $item');
                  rethrow;
                }
              }).toList();
              debugPrint('✅ Successfully parsed ${positions.length} positions');
              return Right(positions);
            } else {
              debugPrint('🔴 Response validation failed for positions');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Positions parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TeamRepository exception getting positions: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, int>> getDepartmentsCount() async {
    debugPrint('🔵 TeamRepository: Getting departments count...');
    try {
      final result = await _apiService.get(
        ApiConstant.departments,
        queryParams: {'page': '1', 'limit': '1'},
        requiresAuth: true,
      );
      return result.fold(
        (error) {
          debugPrint(
            '🔴 TeamRepository error getting departments count: $error',
          );
          return Left(error);
        },
        (response) {
          try {
            debugPrint(
              '🟢 TeamRepository get departments count response received',
            );
            debugPrint('🟢 Response: $response');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              if (data['pagination'] != null) {
                final pagination = data['pagination'] as Map<String, dynamic>;
                final total = pagination['total'] as int? ?? 0;
                debugPrint('✅ Departments total count from pagination: $total');
                return Right(total);
              }
              if (data['departments'] is List) {
                final departmentsList = data['departments'] as List;
                debugPrint(
                  '✅ Departments count from array: ${departmentsList.length}',
                );
                return Right(departmentsList.length);
              }
              debugPrint('🔴 No pagination or departments array found');
              return const Left(StatusRequest.serverFailure);
            } else {
              debugPrint('🔴 Response validation failed for departments count');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Departments count parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TeamRepository exception getting departments count: $e');
      return const Left(StatusRequest.serverException);
    }
  }
  Future<Either<StatusRequest, List<DepartmentModel>>> getDepartments({
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('🔵 TeamRepository: Getting departments...');
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
          debugPrint('🔴 TeamRepository error getting departments: $error');
          return Left(error);
        },
        (response) {
          try {
            debugPrint('🟢 TeamRepository get departments response received');
            debugPrint('🟢 Response: $response');
            if (response['success'] == true && response['data'] != null) {
              final data = response['data'] as Map<String, dynamic>;
              List<dynamic> departmentsList;
              if (data['departments'] is List) {
                departmentsList = data['departments'] as List<dynamic>;
              } else {
                debugPrint('🔴 Unexpected data format for departments');
                return const Left(StatusRequest.serverFailure);
              }
              debugPrint(
                '🟢 Found ${departmentsList.length} departments in list',
              );
              final departments = departmentsList.map((item) {
                try {
                  return DepartmentModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('🔴 Error parsing department: $e');
                  debugPrint('🔴 Department data: $item');
                  rethrow;
                }
              }).toList();
              debugPrint(
                '✅ Successfully parsed ${departments.length} departments',
              );
              return Right(departments);
            } else {
              debugPrint('🔴 Response validation failed for departments');
              return const Left(StatusRequest.serverFailure);
            }
          } catch (e, stackTrace) {
            debugPrint('🔴 Departments parsing error: $e');
            debugPrint('Stack trace: $stackTrace');
            return const Left(StatusRequest.serverException);
          }
        },
      );
    } catch (e) {
      debugPrint('🔴 TeamRepository exception getting departments: $e');
      return const Left(StatusRequest.serverException);
    }
  }
}
