import 'package:flutter/material.dart';

/// Bảng màu chính của app tạp hóa.
/// Mọi màu sắc trong UI nên lấy từ đây, không hardcode màu rải rác
/// trong các màn hình để dễ đổi đồng bộ toàn app sau này.
class AppColors {
  AppColors._();

  // ----- Màu chính (thương hiệu) -----
  static const primary = Color(0xFF1D9E75);
  static const primaryDark = Color(0xFF0F6E56);
  static const primaryLight = Color(0xFFE1F5EE);

  // ----- Màu điểm nhấn (giá tiền, ưu đãi) -----
  static const accent = Color(0xFFEF9F27);
  static const accentLight = Color(0xFFFAEEDA);

  // ----- Màu trạng thái -----
  static const success = Color(0xFF3B6D11);
  static const successBg = Color(0xFFEAF3DE);

  static const warning = Color(0xFF633806);
  static const warningBg = Color(0xFFFAEEDA);

  static const danger = Color(0xFF791F1F);
  static const dangerBg = Color(0xFFFCEBEB);

  // ----- Nền & trung tính -----
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfacePage = Color(0xFFF1EFE8);
  static const border = Color(0xFFD3D1C7);

  static const textPrimary = Color(0xFF2C2C2A);
  static const textSecondary = Color(0xFF888780);
  static const textMuted = Color(0xFFB4B2A9);
}
