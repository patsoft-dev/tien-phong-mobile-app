import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_app/services/api/api_service.dart';

class UserService {
  /// Tải danh sách người dùng theo công ty
  static Future<Map<String, dynamic>?> getUsersByCompany({
    int page = 1,
    int limit = 10,
    String keyword = '',
  }) async {
    try {
      // 1. Truyền tham số thông qua Map params của ApiService
      final response = await ApiService.get(
        '/api/Users/getUsersByCompany',
        params: {'filter': keyword, 'page': page, 'limit': limit},
      );

      debugPrint("🔗 Status Code: ${response.statusCode}");

      // 2. Kiểm tra Response OK và Decode JSON
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      }

      debugPrint(
        "⚠️ Lỗi API: Status ${response.statusCode} - Body: ${response.body}",
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint("❌ Lỗi getUsersByCompany: $e");
      debugPrint("📜 StackTrace: $stackTrace");
      return null;
    }
  }
}
