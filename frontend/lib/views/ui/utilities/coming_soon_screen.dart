import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/ui/utilities/coming_soon_controller.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/images.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> with UIMixin {
  late ComingSoonController controller;

  @override
  void initState() {
    controller = Get.put(ComingSoonController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        String strDigits(int n) => n.toString().padLeft(2, '0');
        final days = strDigits(controller.myDuration.inDays);
        final hours = strDigits(controller.myDuration.inHours.remainder(24));
        final minutes = strDigits(
          controller.myDuration.inMinutes.remainder(60),
        );
        final seconds = strDigits(
          controller.myDuration.inSeconds.remainder(60),
        );

        return Scaffold(
          body: Stack(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              MyContainer(
                height: double.infinity,
                width: double.infinity,
                paddingAll: 0,
                child: Image.asset(Images.bg, fit: BoxFit.fill),
              ),
              MyContainer(color: contentTheme.dark.withValues(alpha: 0.6)),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MySpacing.height(60),
                    Image.asset(Images.logoLight),
                    MySpacing.height(40),
                    MyText.titleLarge(
                      'Let\'s get started with Upzet',
                      color: contentTheme.onPrimary,
                    ),
                    MySpacing.height(20),
                    MyText.bodyMedium(
                      "It will be as simple as Occidental in fact it will be Occidental",
                      color: contentTheme.light,
                    ),
                    MySpacing.height(60),
                    Wrap(
                      runSpacing: 24,
                      spacing: 24,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        timerContainer(days),
                        timerContainer(hours),
                        timerContainer(minutes),
                        timerContainer(seconds),
                      ],
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

  Widget timerContainer(String timing) {
    return MyContainer(
      height: 100,
      width: 120,
      paddingAll: 0,
      borderRadiusAll: 8,
      child: Center(
        child: MyText.titleLarge(timing, fontSize: 32, key: ValueKey(timing)),
      ),
    );
  }
}
