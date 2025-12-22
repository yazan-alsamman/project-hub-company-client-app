import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/services/auth_service.dart';
import '../../data/repository/projects_repository.dart';
import '../../data/repository/team_repository.dart';
import '../../data/static/team_members_data.dart';
abstract class TeamController extends GetxController {}
class TeamControllerImp extends TeamController {
  final TeamRepository _teamRepository = TeamRepository();
  final ProjectsRepository _projectsRepository = ProjectsRepository();
  final AuthService _authService = AuthService();
  List<TeamMember> _teamMembers = [];
  StatusRequest _statusRequest = StatusRequest.none;
  bool _isLoading = false;
  int _departmentsCount = 0;
  int _projectsCount = 0;
  bool _isLoadingStats = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;
  List<TeamMember> get teamMembers => _teamMembers;
  StatusRequest get statusRequest => _statusRequest;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get departmentsCount => _departmentsCount;
  int get projectsCount => _projectsCount;
  bool get isLoadingStats => _isLoadingStats;
  @override
  void onInit() async {
    super.onInit();
    debugPrint('🔵 TeamControllerImp.onInit() called');
    final companyId = await _authService.getCompanyId();
    debugPrint('🔵 Loaded companyId from AuthService: $companyId');
    loadTeamMembers(companyId: companyId, status: null);
    loadStatistics();
  }
  Future<void> loadStatistics() async {
    _isLoadingStats = true;
    update();
    try {
      final companyId = await _authService.getCompanyId();
      debugPrint('🔵 Loading statistics with companyId: $companyId');
      final departmentsCountResult = await _teamRepository
          .getDepartmentsCount();
      departmentsCountResult.fold(
        (error) {
          debugPrint('🔴 Error loading departments count: $error');
          _departmentsCount = 0;
        },
        (count) {
          _departmentsCount = count;
          debugPrint('✅ Total departments count: $count');
        },
      );
      final projectsCountResult = await _projectsRepository.getProjectsCount(
        companyId: companyId,
      );
      projectsCountResult.fold(
        (error) {
          debugPrint('🔴 Error loading projects count: $error');
          _projectsCount = 0;
        },
        (count) {
          _projectsCount = count;
          debugPrint('✅ Total projects count: $count');
        },
      );
    } catch (e) {
      debugPrint('🔴 Exception loading statistics: $e');
      _departmentsCount = 0;
      _projectsCount = 0;
    }
    _isLoadingStats = false;
    update();
  }
  Future<void> loadTeamMembers({
    String? companyId,
    String? status,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _teamMembers = [];
      _hasMore = true;
    }
    if (!_hasMore && !refresh) {
      return;
    }
    _isLoading = true;
    _statusRequest = StatusRequest.loading;
    update();
    debugPrint('🔵 Loading team members...');
    debugPrint('Page: $_currentPage, Limit: $_limit');
    debugPrint('CompanyId: $companyId, Status: $status');
    // جلب companyId من AuthService في كل مرة قبل الإرسال
    String? finalCompanyId = await _authService.getCompanyId();
    debugPrint('🔵 Got companyId from AuthService: $finalCompanyId');
    // التحقق من وجود companyId قبل الإرسال
    if (finalCompanyId == null || finalCompanyId.isEmpty) {
      debugPrint('🔴 CompanyId is required but not found');
      _isLoading = false;
      _statusRequest = StatusRequest.serverFailure;
      update();
      return;
    }
    final result = await _teamRepository.getEmployees(
      page: _currentPage,
      limit: _limit,
      companyId: finalCompanyId,
      status: status, // Don't filter by status - show all employees
    );
    _isLoading = false;
    result.fold(
      (error) {
        debugPrint('🔴 Error loading team members: $error');
        _statusRequest = error;
        update();
      },
      (employees) {
        debugPrint('✅ Loaded ${employees.length} employees');
        for (var emp in employees) {
          debugPrint(
            '  - Employee: ${emp.username}, Position: ${emp.position}, Status: ${emp.status}',
          );
        }
        final newMembers = employees.map((e) {
          final member = e.toTeamMember();
          debugPrint(
            '  - TeamMember: ${member.name}, Position: ${member.position}, Status: ${member.status}',
          );
          return member;
        }).toList();
        if (refresh) {
          _teamMembers = newMembers;
        } else {
          _teamMembers.addAll(newMembers);
        }
        _hasMore = employees.length >= _limit;
        if (_hasMore) {
          _currentPage++;
        }
        _statusRequest = StatusRequest.success;
        update();
        debugPrint('✅ Total team members: ${_teamMembers.length}');
        for (var i = 0; i < _teamMembers.length; i++) {
          debugPrint(
            '  ✅ Member $i: ${_teamMembers[i].name} (${_teamMembers[i].status})',
          );
        }
      },
    );
  }
  Future<void> refreshTeamMembers({String? companyId, String? status}) async {
    await loadTeamMembers(companyId: companyId, status: status, refresh: true);
  }
  Future<void> loadMore({String? companyId, String? status}) async {
    if (!_hasMore || _isLoading) {
      return;
    }
    await loadTeamMembers(companyId: companyId, status: status, refresh: false);
  }
  Map<String, int> getTeamStats() {
    final total = _teamMembers.length;
    final active = _teamMembers.where((m) => m.status == 'Active').length;
    final away = _teamMembers
        .where((m) => m.status == 'Away' || m.status == 'On Leave')
        .length;
    final terminated = _teamMembers
        .where((m) => m.status == 'Terminated')
        .length;
    return {
      'total': total,
      'active': active,
      'busy': terminated, // Show terminated count in busy field
      'away': away,
      'terminated': terminated,
    };
  }
}
