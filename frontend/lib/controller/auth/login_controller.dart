import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/services/auth_service.dart';
import 'package:qr_app/services/api/api_service.dart';
import 'package:qr_app/helper/services/navigation_service.dart';
import 'package:qr_app/models/company_model.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool isLoadingCompany = false;
  CompanyModel? selectedCompany;
  List<CompanyModel> companies = [];

  @override
  void onInit() {
    super.onInit();
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    isLoadingCompany = true;
    update();

    try {
      final response = await ApiService.getCompany();
      companies = response;
      if (companies.isNotEmpty) {
        selectedCompany = companies.first;
      }
    } catch (e) {
      debugPrint("Lỗi lấy danh sách công ty: $e");
    } finally {
      isLoadingCompany = false;
      update();
    }
  }

  void onSelectCompany(CompanyModel? company) {
    selectedCompany = company;
    update();
  }

  Future<void> onLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showErrorBanner("Vui lòng nhập đầy đủ tài khoản và mật khẩu");
      return;
    }

    if (selectedCompany == null) {
      showErrorBanner("Vui lòng chọn công ty");
      return;
    }

    loading = true;
    update();

    try {
      final result = await ApiService.login(
        username,
        password,
        selectedCompany!.companyKey,
        selectedCompany!.companyId.toString(),
      );
      // final result = await ApiService.login(
      //   "admin",
      //   "TanPhongNew@2026",
      //   "tanphong",
      //   "2",
      // );

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('companyName', selectedCompany!.companyKey);
        // await prefs.setString('username', "admin");
        // await prefs.setString('companyName', "tanphong");

        // 1. Cập nhật Auth State
        await AuthService.setLoggedIn(true);

        showLoginSuccessBanner();

        // 2. Unfocus bàn phím & ẩn Banner trước khi điều hướng
        FocusManager.instance.primaryFocus?.unfocus();

        Future.delayed(const Duration(milliseconds: 1200), () {
          final context = NavigationService.navigatorKey.currentContext;
          if (context != null) {
            MyBannerNotification.hide();
          }

          // 3. Chuyển hướng sang màn hình chính
          Get.offAllNamed('/produce-list');
        });
      } else {
        showErrorBanner(result['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      showErrorBanner('Đã có lỗi xảy ra: $e');
    } finally {
      loading = false;
      update();
    }
  }

  void showErrorBanner(String message) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      MyBannerNotification.show(
        context,
        title: "Lỗi",
        message: message,
        type: BannerType.error,
      );
    }
  }

  void showLoginSuccessBanner() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      MyBannerNotification.show(
        context,
        title: "Thông báo",
        message: "Đăng nhập thành công!",
        type: BannerType.success,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
