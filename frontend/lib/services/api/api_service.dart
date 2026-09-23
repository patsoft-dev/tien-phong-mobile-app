import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:qr_app/helper/services/navigation_service.dart';
import 'package:qr_app/models/company_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 1. Khai báo URL cơ sở
  // cũ
  // static const String baseUrl = 'http://42.1.111.50:4041';
  // anh Khánh
  static const String baseUrl = 'https://api2.khanhnbd.io.vn';

  // Helper lấy Header kèm Token
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Xử lý response trung gian để check Token hết hạn
  static Future<http.Response> _processResponse(http.Response response) async {
    try {
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        // Kiểm tra điều kiện token không hợp lệ hoặc hết hạn
        if (body['status'] == false &&
            body['message'] != null &&
            body['message'].toString().toLowerCase().contains('expired')) {
          await _handleUnauthorized();
        }
      }
    } catch (e) {
      // Bỏ qua nếu response không thuộc định dạng JSON
    }

    return response;
  }

  // Xóa bộ nhớ tạm và chuyển hướng người dùng về trang Đăng nhập
  static Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Dùng GetX hoặc NavigationService để chuyển về trang login
    if (Get.context != null) {
      Get.offAllNamed('/auth/login');
    } else {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/auth/login',
        (route) => false,
      );
    }
  }

  // 2. Hàm GET COMPANY (Không cần check token)
  static Future<List<CompanyModel>> getCompany() async {
    final Uri url = Uri.parse('$baseUrl/api/company');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          return data.map((e) => CompanyModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. Hàm Đăng nhập & Xử lý Token / LocalStorage
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
    String companyKey,
    String companyId,
  ) async {
    final Uri url = Uri.parse('$baseUrl/api/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'company_key': companyKey,
          'company_id': companyId,
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      // Trường hợp thành công (status == true)
      if (response.statusCode == 200 && body['status'] == true) {
        String token = body['access_token'] ?? '';

        if (token.isNotEmpty) {
          // Giải mã JWT Token
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

          // Lưu dữ liệu vào Local Storage (SharedPreferences)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('authed', true);
          await prefs.setString('access_token', token);
          await prefs.setString('user_id', decodedToken['user_id'] ?? '');
          await prefs.setString('username', decodedToken['username'] ?? '');
          await prefs.setInt('company_id', decodedToken['company_id'] ?? 0);
          await prefs.setInt('branch_id', decodedToken['branch_id'] ?? 0);
          await prefs.setString('branch_cd', decodedToken['branch_cd'] ?? '');
          await prefs.setString(
            'acumatica_cookie',
            decodedToken['acumatica_cookie'] ?? '',
          );
        }

        return {
          'success': true,
          'message': body['message'] ?? 'Đăng nhập thành công',
        };
      }

      // Lỗi sai company_id
      if (body.containsKey('error')) {
        return {'success': false, 'message': body['error']};
      }

      // Lỗi sai username, pass, company_key hoặc hệ thống
      return {
        'success': false,
        'message':
            body['message'] ??
            'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối máy chủ: $e'};
    }
  }

  // 4. Hàm GET dùng chung
  static Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    // 1. Parse URL gốc từ baseUrl và endpoint
    Uri url = Uri.parse('$baseUrl$endpoint');

    // 2. Nếu có truyền params, convert giá trị sang String và cập nhật queryParameters cho URL
    if (params != null && params.isNotEmpty) {
      final Map<String, String> queryParams = {};

      params.forEach((key, value) {
        if (value != null) {
          // Tự động ép kiểu giá trị về String (hỗ trợ cả int, double, bool, DateTime,...)
          if (value is DateTime) {
            queryParams[key] = value.toIso8601String();
          } else {
            queryParams[key] = value.toString();
          }
        }
      });

      // Thêm các tham số hiện tại (nếu trong endpoint đã có sẵn query params) vào params mới
      final combinedQueryParams = {...url.queryParameters, ...queryParams};

      url = url.replace(queryParameters: combinedQueryParams);
    }

    // 3. Thực hiện request HTTP GET
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    return await _processResponse(response);
  }

  // 5. Hàm POST dùng chung
  // Hàm POST dùng chung
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async {
    // 1. Parse URL gốc từ baseUrl và endpoint
    Uri url = Uri.parse('$baseUrl$endpoint');

    // 2. Nếu có truyền params, convert giá trị sang String và cập nhật queryParameters cho URL
    if (params != null && params.isNotEmpty) {
      final Map<String, String> queryParams = {};

      params.forEach((key, value) {
        if (value != null) {
          if (value is DateTime) {
            queryParams[key] = value.toIso8601String();
          } else {
            queryParams[key] = value.toString();
          }
        }
      });

      final combinedQueryParams = {...url.queryParameters, ...queryParams};
      url = url.replace(queryParameters: combinedQueryParams);
    }

    // 3. Thực hiện request HTTP POST
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );
    return await _processResponse(response);
  }

  // 6. Hàm PUT dùng chung
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return await _processResponse(response);
  }

  // 7. Hàm DELETE dùng chung
  static Future<http.Response> delete(String endpoint) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    return await _processResponse(response);
  }
}
