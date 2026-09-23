import 'package:qr_app/controller/layout/layout_controller.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_flex.dart';
import 'package:qr_app/helper/widgets/my_flex_item.dart';
import 'package:qr_app/helper/widgets/my_responsive.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UtilityLayout extends StatelessWidget {
  final Widget? child;

  final LayoutController controller = LayoutController();
  final topBarTheme = AdminTheme.theme.topBarTheme;
  final contentTheme = AdminTheme.theme.contentTheme;

  UtilityLayout({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return MyResponsive(
      builder: (BuildContext context, _, screenMT) {
        return GetBuilder(
          init: controller,
          builder: (controller) {
            if (screenMT.isMobile || screenMT.isTablet) {
              return mobileScreen(context);
            } else {
              return largeScreen(context);
            }
          },
        );
      },
    );
  }

  Widget mobileScreen(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          padding: MySpacing.x(24),
          key: controller.scrollKey,
          child: child,
        ),
      ),
    );
  }

  Widget largeScreen(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      body: MyFlex(
        spacing: 0,
        runSpacing: 0,
        runAlignment: WrapAlignment.center,
        wrapCrossAlignment: WrapCrossAlignment.center,
        wrapAlignment: WrapAlignment.center,
        children: [
          MyFlexItem(
            sizes: "xxl-4 xl-4 lg-4 md-6 sm-12",
            child: MyContainer(
              height: MediaQuery.of(context).size.height,
              paddingAll: 24,
              borderRadiusAll: 0,
              color: Color(0xff323c48),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: child ?? Container(),
            ),
          ),
          MyFlexItem(
            sizes: 'xxl-8 xl-8 lg-8 md-6 sm-0',
            child: MyContainer.none(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Color(0xff191f25),
            ),
          ),
        ],
      ),
    );
  }
}
