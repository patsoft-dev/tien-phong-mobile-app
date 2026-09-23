import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:qr_app/controller/ui/utilities/error_404_controller.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';

class Error404Screen extends StatefulWidget {
  const Error404Screen({super.key});

  @override
  State<Error404Screen> createState() => _Error404ScreenState();
}

class _Error404ScreenState extends State<Error404Screen> with UIMixin {
  late Error404Controller controller;

  @override
  void initState() {
    controller = Get.put(Error404Controller());
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
              child: Padding(
                padding: MySpacing.symmetric(vertical: 40, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyText('4', fontSize: 100, fontWeight: 700),
                        Icon(
                          Icons.sentiment_very_satisfied,
                          size: 80,
                          color: contentTheme.primary,
                        ),
                        MyText('4', fontSize: 100, fontWeight: 700),
                      ],
                    ),
                    MySpacing.height(20),

                    MyText.titleLarge(
                      'Sorry, page not found',
                      letterSpacing: 1,
                      fontWeight: 700,
                      textAlign: TextAlign.center,
                    ),
                    MySpacing.height(12),
                    MyText.bodyLarge(
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
          ),
        );
      },
    );
  }
}
