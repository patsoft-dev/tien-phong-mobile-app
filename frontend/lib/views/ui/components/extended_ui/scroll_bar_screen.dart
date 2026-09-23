import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/ui/components/extended_ui/scroll_bar_controller.dart';
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

class ScrollBarScreen extends StatefulWidget {
  const ScrollBarScreen({super.key});

  @override
  State<ScrollBarScreen> createState() => _ScrollBarScreenState();
}

class _ScrollBarScreenState extends State<ScrollBarScreen> with UIMixin {
  ScrollBarController controller = Get.put(ScrollBarController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'scrollbar_controller',
      builder: (controller) {
        return Layout(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.titleMedium(
                    "Scroll Bar",
                    fontSize: 18,
                    fontWeight: 600,
                  ),
                  MyBreadcrumb(
                    children: [
                      MyBreadcrumbItem(name: 'Advanced UI'),
                      MyBreadcrumbItem(name: 'Scroll Bar'),
                    ],
                  ),
                ],
              ),
              MySpacing.height(flexSpacing),
              MyFlex(
                children: [
                  MyFlexItem(sizes: 'lg-6 md-6', child: defaultScroll()),
                  MyFlexItem(sizes: 'lg-6 md-6', child: rtlSupport()),
                  MyFlexItem(sizes: 'lg-6 md-6', child: scrollSize()),
                  MyFlexItem(sizes: 'lg-6 md-6', child: scrollBarColor()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget defaultScroll() {
    return MyCard(
      shadow: MyShadow(elevation: 1, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            width: double.infinity,
            borderRadiusAll: 0,
            child: MyText.bodyMedium(
              "Default Scroll",
              fontWeight: 700,
              muted: true,
            ),
          ),
          SizedBox(
            height: 400,
            child: ListView(
              shrinkWrap: true,
              padding: MySpacing.all(20),
              children: [
                MyText.bodySmall(controller.dummyTexts[0], muted: true),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[1], muted: true),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[2], muted: true),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[3], muted: true),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[4], muted: true),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[5], muted: true),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[6], muted: true),
                MySpacing.height(20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rtlSupport() {
    return MyCard(
      shadow: MyShadow(elevation: 1, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            width: double.infinity,
            borderRadiusAll: 0,
            child: MyText.bodyMedium(
              "RTL Position",
              fontWeight: 700,
              muted: true,
            ),
          ),
          SizedBox(
            height: 400,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                child: Padding(
                  padding: MySpacing.all(20),
                  child: Column(
                    children: [
                      MyText.bodySmall(controller.dummyTexts[0], muted: true),
                      MySpacing.height(20),
                      MyText.bodySmall(controller.dummyTexts[1], muted: true),
                      MySpacing.height(20),
                      MyText.bodySmall(controller.dummyTexts[2], muted: true),
                      MySpacing.height(20),
                      MyText.bodySmall(controller.dummyTexts[3], muted: true),
                      MySpacing.height(20),
                      MyText.bodySmall(controller.dummyTexts[4], muted: true),
                      MySpacing.height(20),
                      MyText.bodySmall(controller.dummyTexts[5], muted: true),
                      MySpacing.height(20),
                      MyText.bodySmall(controller.dummyTexts[6], muted: true),
                      MySpacing.height(20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget scrollSize() {
    return MyCard(
      shadow: MyShadow(elevation: 1, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            width: double.infinity,
            borderRadiusAll: 0,
            child: MyText.bodyMedium(
              "Scroll Size",
              fontWeight: 700,
              muted: true,
            ),
          ),
          SizedBox(
            height: 400,
            child: Scrollbar(
              thickness: 12,
              thumbVisibility: true,
              controller: controller.scrollController,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: ListView(
                  shrinkWrap: true,
                  controller: controller.scrollController,
                  padding: MySpacing.all(20),
                  children: [
                    MyText.bodySmall(controller.dummyTexts[0], muted: true),
                    MySpacing.height(20),
                    MyText.bodySmall(controller.dummyTexts[1], muted: true),
                    MySpacing.height(20),
                    MyText.bodySmall(controller.dummyTexts[2], muted: true),
                    MySpacing.height(20),
                    MyText.bodySmall(controller.dummyTexts[3], muted: true),
                    MySpacing.height(20),
                    MyText.bodySmall(controller.dummyTexts[4], muted: true),
                    MySpacing.height(20),
                    MyText.bodySmall(controller.dummyTexts[5], muted: true),
                    MySpacing.height(20),
                    MyText.bodySmall(controller.dummyTexts[6], muted: true),
                    MySpacing.height(20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget scrollBarColor() {
    return MyCard(
      shadow: MyShadow(elevation: 1, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            width: double.infinity,
            borderRadiusAll: 0,
            child: MyText.bodyMedium(
              "Scroll Color",
              fontWeight: 700,
              muted: true,
            ),
          ),
          SizedBox(
            height: 400,
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: WidgetStatePropertyAll(contentTheme.primary),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: MySpacing.all(20),
                children: [
                  MyText.bodySmall(controller.dummyTexts[0], muted: true),
                  MySpacing.height(20),
                  MyText.bodySmall(controller.dummyTexts[1], muted: true),
                  MySpacing.height(20),
                  MyText.bodySmall(controller.dummyTexts[2], muted: true),
                  MySpacing.height(20),
                  MyText.bodySmall(controller.dummyTexts[3], muted: true),
                  MySpacing.height(20),
                  MyText.bodySmall(controller.dummyTexts[4], muted: true),
                  MySpacing.height(20),
                  MyText.bodySmall(controller.dummyTexts[5], muted: true),
                  MySpacing.height(20),
                  MyText.bodySmall(controller.dummyTexts[6], muted: true),
                  MySpacing.height(20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
