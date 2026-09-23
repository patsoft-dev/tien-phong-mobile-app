import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyToken = 'token';
  static const String _keyUserData = 'userData';

  /// Cập nhật trạng thái đăng nhập
  static Future<bool> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyIsLoggedIn, value);
  }

  /// Kiểm tra xem người dùng đã đăng nhập hay chưa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Lưu Token
  static Future<bool> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyToken, token);
  }

  /// Lấy Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Lưu thông tin User
  static Future<bool> setUserData(String userDataJson) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserData, userDataJson);
  }

  /// Lấy thông tin User
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserData);
  }

  /// Xóa sạch dữ liệu khi Đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);
  }
}
