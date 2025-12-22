import 'package:flutter/material.dart';
class Responsive {
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  static bool isMobile(BuildContext context) {
    return width(context) < 600;
  }
  static bool isTablet(BuildContext context) {
    final w = width(context);
    return w >= 600 && w < 1200;
  }
  static bool isDesktop(BuildContext context) {
    return width(context) >= 1200;
  }
  static EdgeInsets padding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
  static EdgeInsets horizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    }
  }
  static EdgeInsets verticalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(vertical: 16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(vertical: 24.0);
    } else {
      return const EdgeInsets.symmetric(vertical: 32.0);
    }
  }
  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }
  static double size(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.3;
    } else {
      return desktop ?? mobile * 1.6;
    }
  }
  static double spacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }
  static double widthPercent(BuildContext context, double percent) {
    return width(context) * percent;
  }
  static double heightPercent(BuildContext context, double percent) {
    return height(context) * percent;
  }
  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 800;
    } else {
      return 1200;
    }
  }
  static int columnCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }
  static double borderRadius(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }
  static double iconSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }
  static double containerHeight(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }
  static double containerWidth(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.3;
    } else {
      return desktop ?? mobile * 1.6;
    }
  }
}
