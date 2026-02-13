import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints comuns
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Detecta se é mobile (phone)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // Detecta se é tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  // Detecta se é desktop ou TV
  static bool isDesktopOrTV(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Detecta se é TV (Android TV, Apple TV, etc)
  static bool isTV(BuildContext context) {
    // TVs geralmente têm telas muito grandes e são landscape
    final size = MediaQuery.of(context).size;
    return size.width >= 1920 || (size.width > size.height && size.width >= 1280);
  }

  // Retorna o tamanho baseado no tipo de dispositivo
  static double getResponsiveSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.5;
    } else {
      return desktop ?? mobile * 2.0;
    }
  }

  // Retorna padding responsivo
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  // Retorna número de colunas para grid responsivo
  static int getGridColumnCount(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }
}

