import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import 'package:qr_app/controller/ui/components/base_ui/breadcrumb_controller.dart';
import 'package:qr_app/helper/utils/my_shadow.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb_item.dart';
import 'package:qr_app/helper/widgets/my_card.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_flex.dart';
import 'package:qr_app/helper/widgets/my_flex_item.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/views/layout/layout.dart';

import '../../../../helper/widgets/responsive.dart';

class BreadcrumbScreen extends StatefulWidget {
  const BreadcrumbScreen({super.key});

  @override
  State<BreadcrumbScreen> createState() => _BreadcrumbScreenState();
}

class _BreadcrumbScreenState extends State<BreadcrumbScreen> with UIMixin {
  BreadcrumbController controller = Get.put(BreadcrumbController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'breadcrumb_controller',
      builder: (controller) {
        return Layout(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.titleMedium(
                    "Breadcrumb",
                    fontSize: 18,
                    fontWeight: 600,
                  ),
                  MyBreadcrumb(
                    children: [
                      MyBreadcrumbItem(name: 'Base UI'),
                      MyBreadcrumbItem(name: 'Breadcrumb'),
                    ],
                  ),
                ],
              ),
              MySpacing.height(flexSpacing),
              MyFlex(
                children: [
                  MyFlexItem(child: example()),
                  MyFlexItem(child: withIcon()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget withIcon() {
    return MyCard(
      shadow: MyShadow(elevation: 1, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            width: double.infinity,
            borderRadiusAll: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleMedium("Example", fontWeight: 600),
                MySpacing.height(12),
                MyText.bodySmall(
                  "Optionally you can also specify the icon with your breadcrumb item.",
                  fontWeight: 600,
                ),
              ],
            ),
          ),
          Padding(
            padding: MySpacing.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyContainer(
                  paddingAll: 12,
                  color: contentTheme.secondary.withAlpha(10),
                  child: Row(
                    children: [
                      Icon(Remix.home_5_line, size: 16),
                      MySpacing.width(12),
                      MyText.bodyMedium("Home", xMuted: true),
                    ],
                  ),
                ),
                MySpacing.height(20),
                MyContainer(
                  paddingAll: 12,
                  color: contentTheme.secondary.withAlpha(10),
                  child: Row(
                    children: [
                      Icon(Remix.home_5_line, size: 16),
                      MySpacing.width(12),
                      MyText.bodyMedium("Home", xMuted: true),
                      MySpacing.width(4),
                      Icon(Remix.arrow_right_s_line, size: 16),
                      MySpacing.width(4),
                      MyText.bodyMedium("Library", xMuted: true),
                    ],
                  ),
                ),
                MySpacing.height(20),
                MyContainer(
                  paddingAll: 12,
                  color: contentTheme.secondary.withAlpha(10),
                  child: Row(
                    children: [
                      Icon(Remix.home_5_line, size: 16),
                      MySpacing.width(12),
                      MyText.bodyMedium("Home", xMuted: true),
                      MySpacing.width(4),
                      Icon(Remix.arrow_right_s_line, size: 16),
                      MySpacing.width(4),
                      MyText.bodyMedium("Library", xMuted: true),
                      Icon(Remix.arrow_right_s_line, size: 16),
                      MySpacing.width(4),
                      MyText.bodyMedium("Data", xMuted: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget example() {
    return MyCard(
      shadow: MyShadow(elevation: 1, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            width: double.infinity,
            borderRadiusAll: 0,
            child: MyText.titleMedium("Example", fontWeight: 600),
          ),
          Padding(
            padding: MySpacing.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium("Home", xMuted: true),
                MySpacing.height(20),
                Row(
                  children: [
                    MyText.bodyMedium("Home", xMuted: true),
                    MySpacing.width(4),
                    Icon(Remix.arrow_right_s_line, size: 16),
                    MySpacing.width(4),
                    MyText.bodyMedium("Library", xMuted: true),
                  ],
                ),
                MySpacing.height(20),
                Row(
                  children: [
                    MyText.bodyMedium("Home", xMuted: true),
                    MySpacing.width(4),
                    Icon(Remix.arrow_right_s_line, size: 16),
                    MySpacing.width(4),
                    MyText.bodyMedium("Library", xMuted: true),
                    Icon(Remix.arrow_right_s_line, size: 16),
                    MySpacing.width(4),
                    MyText.bodyMedium("Data", xMuted: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
