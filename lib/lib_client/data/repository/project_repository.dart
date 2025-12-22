import 'package:dartz/dartz.dart';
import 'package:project_hub/lib_client/core/services/api_service.dart';
import 'package:project_hub/lib_client/data/Models/project_model.dart';

class ProjectRepository {
  final ApiService _apiService = ApiService();

  Future<Either<String, List<ProjectModel>>> getProjectsByClientId(
    String clientId,
  ) async {
    try {
      final response = await _apiService.get(
        '/project',
        queryParameters: {'clientId': clientId},
      );

      final data = _apiService.handleResponse(response);

      if (data['data'] != null) {
        final dataObj = data['data'];
        List<dynamic> projectsList;

        // Handle both formats: data['data']['projects'] and data['data'] as direct list
        if (dataObj is Map<String, dynamic> && dataObj['projects'] != null) {
          projectsList = dataObj['projects'] as List;
        } else if (dataObj is List) {
          projectsList = dataObj;
        } else {
          return Left('No projects found for this client');
        }

        final projects = projectsList
            .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return Right(projects);
      }

      return Left('No projects found for this client');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
