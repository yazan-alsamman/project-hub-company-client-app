/// ControllersInitializer is deprecated - use page bindings instead.
/// Controllers are now initialized automatically when entering each page via bindings.
class ControllersInitializer {
  // This method is kept for backwards compatibility but no longer initializes controllers.
  // Controllers are now initialized through page bindings defined in core/bindings/page_bindings.dart
  static void initializeControllers() {
    // Controllers are now initialized via bindings in routes.dart
    // This method is kept for backwards compatibility but does nothing
  }
}
