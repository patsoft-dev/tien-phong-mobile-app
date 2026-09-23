import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/ui/components/icon/remix_icon_controller.dart';
import 'package:qr_app/helper/services/url_service.dart';
import 'package:qr_app/helper/utils/my_shadow.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb_item.dart';
import 'package:qr_app/helper/widgets/my_button.dart';
import 'package:qr_app/helper/widgets/my_card.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/views/layout/layout.dart';

import '../../../../helper/widgets/responsive.dart';

class RemixIconScreen extends StatefulWidget {
  const RemixIconScreen({super.key});

  @override
  State<RemixIconScreen> createState() => _RemixIconScreenState();
}

class _RemixIconScreenState extends State<RemixIconScreen> with UIMixin {
  RemixIconController controller = Get.put(RemixIconController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.titleMedium(
                    "Remix Icons",
                    fontSize: 18,
                    fontWeight: 600,
                  ),
                  MyBreadcrumb(
                    children: [
                      MyBreadcrumbItem(name: 'Form'),
                      MyBreadcrumbItem(name: 'Remix Icons'),
                    ],
                  ),
                ],
              ),
              MySpacing.height(flexSpacing),
              MyCard(
                shadow: MyShadow(
                  elevation: 1,
                  position: MyShadowPosition.bottom,
                ),
                paddingAll: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("Remix Icons", fontWeight: 600),
                    MySpacing.height(20),
                    GridView.builder(
                      itemCount: controller.iconsData.length,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 32,
                      ),
                      itemBuilder: (context, index) {
                        dynamic icon = controller.iconsData[index];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon['icon'], size: 20),
                            MySpacing.width(12),
                            MyText.bodySmall(
                              icon['name'],
                              muted: true,
                              fontWeight: 600,
                            ),
                          ],
                        );
                      },
                    ),
                    MySpacing.height(20),
                    Center(
                      child: MyButton(
                        onPressed: () => UrlService.goToRemixIcon(),
                        elevation: 0,
                        padding: MySpacing.all(12),
                        backgroundColor: contentTheme.primary,
                        borderRadiusAll: 4,
                        child: MyText.labelMedium(
                          "More Icons",
                          fontWeight: 600,
                          color: contentTheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
