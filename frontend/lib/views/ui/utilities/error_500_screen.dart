import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:qr_app/controller/ui/utilities/error_500_controller.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';

class Error500Screen extends StatefulWidget {
  const Error500Screen({super.key});

  @override
  State<Error500Screen> createState() => _Error500ScreenState();
}

class _Error500ScreenState extends State<Error500Screen> with UIMixin {
  late Error500Controller controller;

  @override
  void initState() {
    controller = Get.put(Error500Controller());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: MySpacing.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText('500', fontSize: 100, fontWeight: 700),
                  MySpacing.height(20),
                  MyText.bodyLarge(
                    'INTERNAL SERVER ERROR',
                    letterSpacing: 1,
                    fontWeight: 700,
                    textAlign: TextAlign.center,
                  ),
                  MySpacing.height(12),

                  MyText.bodyMedium(
                    'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque.',
                    muted: true,
                    textAlign: TextAlign.center,
                  ),
                  MySpacing.height(32),
                  MyContainer(
                    onTap: () {
                      Get.back();
                    },
                    color: contentTheme.primary,
                    paddingAll: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          RemixIcons.arrow_left_line,
                          color: contentTheme.onPrimary,
                          size: 16,
                        ),
                        MySpacing.width(12),
                        MyText.labelMedium(
                          'Back to home',
                          color: contentTheme.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
