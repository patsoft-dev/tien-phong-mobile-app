import 'package:provider/provider.dart';
import 'package:qr_app/helper/services/url_service.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/theme/theme_customizer.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/utils/my_shadow.dart';
import 'package:qr_app/helper/widgets/my_card.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/views/layout/widget/navigation_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeftBar extends StatefulWidget {
  final bool isCondensed;

  const LeftBar({super.key, this.isCondensed = false});

  @override
  State<LeftBar> createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar>
    with SingleTickerProviderStateMixin, UIMixin {
  final ThemeCustomizer customizer = ThemeCustomizer.instance;

  bool isCondensed = false;
  String path = UrlService.getCurrentUrl();

  String username = "";
  String companyName = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "User";
      companyName = prefs.getString('companyName') ?? "Công ty";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Xóa dữ liệu xác thực và thông tin user
    await prefs.remove('authed');
    await prefs.remove('userData');
    await prefs.remove('username');
    await prefs.remove('companyName');

    // Điều hướng về màn auth/login
    Get.offAllNamed('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    isCondensed = widget.isCondensed;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Consumer<AppNotifier>(
      builder: (context, notifier, child) {
        return MyCard(
          paddingAll: 0,
          shadow: MyShadow(
            position: MyShadowPosition.centerRight,
            elevation: 0.2,
          ),
          child: AnimatedContainer(
            color: leftBarTheme.background,
            width: 255,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topPadding + 16),

                // ================= HEADER SIDEBAR =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.labelLarge(
                        companyName.toUpperCase(),
                        color: leftBarTheme.labelColor,
                        muted: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: 700,
                        fontSize: 18,
                      ),
                      MySpacing.height(2),
                      MyText.bodyMedium(
                        "$username",
                        color: leftBarTheme.labelColor,
                        fontWeight: 500,
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),

                MySpacing.height(16),

                // Menu Danh sách các item
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: ListView(
                      shrinkWrap: true,
                      controller: ScrollController(),
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      children: [
                        NavigationItem(
                          title: "Phiếu cân sản xuất",
                          fontSize: 16,
                          isCondensed: isCondensed,
                          route: '/produce-list',
                        ),
                        NavigationItem(
                          title: "Kiểm tồn kho",
                          fontSize: 16,
                          isCondensed: isCondensed,
                          route: '/inventory-check',
                        ),
                        NavigationItem(
                          title: "Kiểm kê kho",
                          fontSize: 16,
                          isCondensed: isCondensed,
                          route: '/stocktake-list',
                        ),
                        NavigationItem(
                          title: "Cài đặt",
                          fontSize: 16,
                          isCondensed: isCondensed,
                          route: '/setting',
                        ),
                        MySpacing.height(20),
                      ],
                    ),
                  ),
                ),

                // ================= BOTTOM SIDEBAR =================
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: leftBarTheme.labelColor.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: _logout,
                        child: MyContainer.none(
                          padding: MySpacing.xy(10, 10),
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              const Icon(
                                RemixIcons.logout_box_r_line,
                                size: 22,
                                color: Colors.redAccent,
                              ),
                              MySpacing.width(12),
                              Expanded(
                                child: MyText.labelMedium(
                                  "Đăng xuất",
                                  color: Colors.redAccent,
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
