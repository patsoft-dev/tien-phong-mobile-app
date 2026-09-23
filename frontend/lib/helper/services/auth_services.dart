import 'package:qr_app/helper/storage/local_storage.dart';
import 'package:qr_app/models/user.dart';

class AuthService {
  static bool isLoggedIn = false;

  static User get dummyUser => User(-1, "username", "Adam", "Doe");

  static Future<Map<String, String>?> loginUser(
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(Duration(seconds: 1));
    if (data['username'] != dummyUser.username) {
      return {"username": "This username is not valid"};
    } else if (data['password'] != "password") {
      return {"password": "Password is incorrect"};
    }

    isLoggedIn = true;
    await LocalStorage.setLoggedInUser(true);
    return null;
  }
}
