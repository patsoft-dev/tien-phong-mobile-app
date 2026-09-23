import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:remixicon/remixicon.dart';
import 'package:qr_app/controller/ui/utilities/maintenance_controller.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_flex.dart';
import 'package:qr_app/helper/widgets/my_flex_item.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/images.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with UIMixin {
  late MaintenanceController controller;

  @override
  void initState() {
    controller = Get.put(MaintenanceController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Images.logoDark, height: 28),
                MySpacing.height(20),
                Icon(RemixIcons.tools_fill, size: 100),
                MySpacing.height(20),

                MyText.titleLarge("Site is Under Maintenance", fontWeight: 600),
                MySpacing.height(20),
                MyText.bodyMedium("Please check back in sometime."),
                MySpacing.height(20),
                MyContainer(
                  onTap: () {
                    Get.back();
                  },
                  color: contentTheme.primary,
                  paddingAll: 12,
                  child: MyText.bodyMedium(
                    "Back to home",
                    color: contentTheme.onPrimary,
                  ),
                ),
                MySpacing.height(20),
                MyFlex(
                  children: [
                    MyFlexItem(
                      sizes: 'lg-2',
                      child: Column(
                        children: [
                          MyContainer.rounded(
                            color: contentTheme.primary,
                            child: Icon(
                              MdiIcons.accessPointNetwork,
                              color: contentTheme.onPrimary,
                            ),
                          ),
                          MySpacing.height(12),
                          MyText.bodyMedium(
                            "Why is the Site Down?",
                            fontWeight: 600,
                          ),
                          MySpacing.height(12),
                          MyText.bodyMedium(
                            "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    MyFlexItem(
                      sizes: 'lg-2',
                      child: Column(
                        children: [
                          MyContainer.rounded(
                            color: contentTheme.primary,
                            child: Icon(
                              MdiIcons.clockOutline,
                              color: contentTheme.onPrimary,
                            ),
                          ),
                          MySpacing.height(12),
                          MyText.bodyMedium(
                            "Why is the Site Down?",
                            fontWeight: 600,
                          ),
                          MySpacing.height(12),
                          MyText.bodyMedium(
                            "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    MyFlexItem(
                      sizes: 'lg-2',
                      child: Column(
                        children: [
                          MyContainer.rounded(
                            color: contentTheme.primary,
                            child: Icon(
                              MdiIcons.emailOutline,
                              color: contentTheme.onPrimary,
                            ),
                          ),
                          MySpacing.height(12),
                          MyText.bodyMedium(
                            "Why is the Site Down?",
                            fontWeight: 600,
                          ),
                          MySpacing.height(12),
                          MyText.bodyMedium(
                            "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
