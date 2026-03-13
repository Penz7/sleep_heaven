import 'package:flutter/material.dart';

/// Màu sắc chính của app - gradient xanh dương → tím
class AppColors {
  AppColors._();

  // Gradient chính (blue → purple)
  static const Color primaryStart = Color(0xFF4A90E2);
  static const Color primaryEnd = Color(0xFF9B59B6);

  // Background
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color cardDark = Color(0xFF1A1A2E);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimaryDark = Color(0xFFE8E8F0);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Accent
  static const Color accent = Color(0xFF6C63FF);
  static const Color favorite = Color(0xFFE74C3C);
  static const Color premium = Color(0xFFFFD700);
}

extension ColorOpacity on Color {
  Color opacityColor(double opacity) => withValues(alpha: opacity);
}
