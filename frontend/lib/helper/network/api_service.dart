import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  // Chỉ giữ duy nhất cấu hình URL mong muốn
  // static const String api_url = 'http://192.168.1.73:4045/api/v1'; // Local test
  // ignore: constant_identifier_names
  // static const String api_url = 'http://42.1.111.50:4045/api/v1'; // Server
  // ignore: constant_identifier_names
  static const String api_url = "http://192.168.1.190:3301/api/v1"; // Server

  // Khởi tạo một HttpClient dùng chung duy nhất
  static final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);

  // ==================== CÁC HÀM CÔNG KHAI (PUBLIC API) ====================

  // 1. Hàm post (Viết theo cơ chế async/await kết hợp callback, dùng v1 - Không Token)
  static Future<void> post(
    String url,
    Map<String, dynamic>? data,
    Function(String? error, dynamic data) callback,
  ) async {
    try {
      final String fullUrl = '$api_url$url';

      debugPrint("🚀 Gọi API (Fetch): $fullUrl");

      final HttpClientRequest request = await _client.openUrl(
        'POST',
        Uri.parse(fullUrl),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      if (data != null) {
        request.write(jsonEncode(data));
      }

      final HttpClientResponse response = await request.close();
      final String responseBody = await response.transform(utf8.decoder).join();
      final dynamic result = responseBody.isNotEmpty
          ? jsonDecode(responseBody)
          : null;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String errorMsg =
            result?['Message'] ?? 'Lỗi hệ thống (${response.statusCode})';
        callback(errorMsg, null);
        return;
      }

      callback(null, result);
    } catch (error) {
      debugPrint("Fetch error: $error");
      callback(error.toString(), null);
    }
  }

  // 2. Hàm get_cus (Sử dụng Phương thức GET, dùng v1 - Không Token)
  static Future<dynamic> get(String url, Map<String, dynamic>? params) async {
    try {
      String queryString = '';
      if (params != null && params.isNotEmpty) {
        final Uri uri = Uri(
          queryParameters: params.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
        queryString = '?${uri.query}';
      }

      final String fullUrl = '$api_url$url$queryString';

      final HttpClientRequest request = await _client.openUrl(
        'GET',
        Uri.parse(fullUrl),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      final HttpClientResponse response = await request.close();
      final String responseBody = await response.transform(utf8.decoder).join();
      final dynamic result = responseBody.isNotEmpty
          ? jsonDecode(responseBody)
          : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return result;
      } else {
        debugPrint('GET request error: ${response.statusCode} - $responseBody');
        throw {
          'status': response.statusCode,
          'message': result?['Message'] ?? responseBody,
        };
      }
    } catch (error) {
      debugPrint('GET request error: $error');
      if (error is Map) rethrow;
      throw {'status': 500, 'message': error.toString()};
    }
  }
}
