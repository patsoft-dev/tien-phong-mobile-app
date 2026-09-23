import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/controller/auth/login_controller.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/models/company_model.dart';
import 'package:qr_app/widgets/my_dropdown.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:remixicon/remixicon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with UIMixin {
  @override
  Widget build(BuildContext context) {
    // ✅ Bọc Consumer để nhận thông báo tự động rebuild khi đổi Theme
    return Consumer<AppNotifier>(
      builder: (context, notifier, child) {
        final contentTheme = AdminTheme.theme.contentTheme;

        return Scaffold(
          backgroundColor: contentTheme.background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: MySpacing.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: GetBuilder<LoginController>(
                        init: LoginController(),
                        builder: (controller) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                width: 200,
                                height: 70,
                                fit: BoxFit.contain,
                              ),
                              // Text(
                              //   "TanPhong",
                              //   style: TextStyle(
                              //     fontSize: 28,
                              //     fontWeight: FontWeight.bold,
                              //     color: contentTheme.onBackground,
                              //   ),
                              // ),
                              MySpacing.height(8),
                              Text(
                                "Đăng nhập để tiếp tục quản lý",
                                style: TextStyle(
                                  color: contentTheme.onBackground.withOpacity(
                                    0.6,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                              MySpacing.height(32),

                              MyInput(
                                hintText: "Tài khoản",
                                borderRadius: 12,
                                prefixIcon: RemixIcons.user_3_line,
                                controller: controller.usernameController,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                              MySpacing.height(16),

                              MyInput(
                                hintText: "Mật khẩu",
                                borderRadius: 12,
                                prefixIcon: RemixIcons.lock_line,
                                isPassword: true,
                                controller: controller.passwordController,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                  controller.onLogin();
                                },
                              ),
                              MySpacing.height(16),

                              controller.isLoadingCompany
                                  ? CircularProgressIndicator(
                                      color: contentTheme.primary,
                                    )
                                  : MyDropdown<CompanyModel>(
                                      hintText: "Chọn công ty",
                                      borderRadius: 12,
                                      prefixIcon: RemixIcons.building_4_line,
                                      value: controller.selectedCompany,
                                      items: controller.companies
                                          .map(
                                            (
                                              company,
                                            ) => DropdownMenuItem<CompanyModel>(
                                              value: company,
                                              child: Text(
                                                company.companyKey.isNotEmpty
                                                    ? company.companyKey
                                                    : "Công ty ${company.companyId}",
                                                style: TextStyle(
                                                  color:
                                                      contentTheme.onBackground,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: controller.onSelectCompany,
                                    ),
                              MySpacing.height(28),

                              MyContainer(
                                onTap: controller.loading
                                    ? null
                                    : controller.onLogin,
                                color: controller.loading
                                    ? contentTheme.primary.withOpacity(0.6)
                                    : contentTheme.primary,
                                borderRadiusAll: 6,
                                paddingAll: 16,
                                child: Center(
                                  child: controller.loading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: contentTheme.onPrimary,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          "Đăng nhập",
                                          style: TextStyle(
                                            color: contentTheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
