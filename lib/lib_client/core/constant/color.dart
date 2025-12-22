import 'package:flutter/material.dart';

class AppColor {
  // Primary Colors
  static const Color primaryColor = Color(0xFF3B82F6); // Blue
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  
  // Light Mode Colors
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightCardBackgroundColor = Color(0xFFF9FAFB);
  static const Color lightTextColor = Color(0xFF111827);
  static const Color lightTextSecondaryColor = Color(0xFF6B7280);
  static const Color lightBorderColor = Color(0xFFE5E7EB);
  
  // Dark Mode Colors
  static const Color darkBackgroundColor = Color(0xFF111827);
  static const Color darkCardBackgroundColor = Color(0xFF1F2937);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkTextSecondaryColor = Color(0xFF9CA3AF);
  static const Color darkBorderColor = Color(0xFF374151);
  
  // Current Theme Colors (will be set dynamically)
  static Color backgroundColor = lightBackgroundColor;
  static Color cardBackgroundColor = lightCardBackgroundColor;
  static Color textColor = lightTextColor;
  static Color textSecondaryColor = lightTextSecondaryColor;
  static Color borderColor = lightBorderColor;
  
  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444); // Red for high priority
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // Task Status Colors
  static const Color inProgressColor = Color(0xFF3B82F6);
  static const Color completedColor = Color(0xFF10B981);
  static const Color pendingColor = Color(0xFFF59E0B);
  
  // Tag Colors
  static Color tagBackgroundColor = lightBorderColor; // Light gray for tags
  static const Color highPriorityColor = Color(0xFFEF4444); // Red
  
  // Sidebar Colors
  static const Color sidebarBackgroundColor = Color(0xFFFFFFFF);
  static const Color sidebarActiveColor = Color(0xFF8B5CF6); // Purple gradient
  static const Color sidebarHoverColor = Color(0xFFF3F4F6);
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF9333EA);
  static const Color gradientMiddle = Color(0xFF3B82F6);
  static const Color gradientEnd = Color(0xFF60A5FA);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sidebarActiveGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
  
  // Switch theme method
  static void switchToLightMode() {
    backgroundColor = lightBackgroundColor;
    cardBackgroundColor = lightCardBackgroundColor;
    textColor = lightTextColor;
    textSecondaryColor = lightTextSecondaryColor;
    borderColor = lightBorderColor;
    tagBackgroundColor = lightBorderColor;
  }
  
  static void switchToDarkMode() {
    backgroundColor = darkBackgroundColor;
    cardBackgroundColor = darkCardBackgroundColor;
    textColor = darkTextColor;
    textSecondaryColor = darkTextSecondaryColor;
    borderColor = darkBorderColor;
    tagBackgroundColor = darkBorderColor;
  }
}
