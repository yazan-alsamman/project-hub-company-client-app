import 'dart:io';

/// Centralized application configuration
/// All hardcoded values should be defined here for easy management
class AppConfig {
  AppConfig._();

  // ============================================
  // API Server Configuration
  // ============================================

  /// Production API server URL
  static const String productionApiUrl = 'http://72.62.52.238:5020';

  /// Android emulator API URL (uses special gateway IP)
  static const String androidEmulatorApiUrl = 'http://10.0.2.2:5000';

  /// Development localhost API URL
  static const String localhostApiUrl = 'http://localhost:5000';

  /// Get the appropriate base URL based on platform
  static String get defaultBaseUrl {
    if (Platform.isAndroid) {
      return androidEmulatorApiUrl;
    }
    return localhostApiUrl;
  }

  // ============================================
  // External API Configuration
  // ============================================

  /// AI task generation API URL
  static const String aiApiUrl = 'https://daliliai.com/api/ai/generate';

  /// AI task assignment API URL
  static const String aiAssignTasksApiUrl =
      'https://daliliai.com/api/assignment/api/assign-tasks';

  // ============================================
  // App Domain Configuration
  // ============================================

  /// Project sharing base URL
  static const String projectShareBaseUrl = 'https://projecthub.app/project';

  /// Generate a shareable project link
  static String getProjectShareUrl(String projectId) {
    return '$projectShareBaseUrl/$projectId';
  }

  // ============================================
  // Timeout Configuration
  // ============================================

  /// Default connection timeout
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Default receive timeout
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Connection test timeout
  static const Duration connectionTestTimeout = Duration(seconds: 5);

  /// Token refresh timeout
  static const Duration tokenRefreshTimeout = Duration(seconds: 15);

  /// PDF generation timeout
  static const Duration pdfGenerationTimeout = Duration(seconds: 30);

  // ============================================
  // Retry Configuration
  // ============================================

  /// Maximum number of retry attempts for network requests
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts
  static const Duration retryDelay = Duration(seconds: 2);

  // ============================================
  // Pagination Configuration
  // ============================================

  /// Default items per page
  static const int defaultItemsPerPage = 10;

  /// Maximum items per page for dropdowns/lists
  static const int maxItemsPerPage = 100;

  // ============================================
  // Content Type Headers
  // ============================================

  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
}
