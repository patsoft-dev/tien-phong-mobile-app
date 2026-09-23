import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/layout/layout_controller.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/views/layout/left_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget Function(BuildContext context, VoidCallback openDrawer)
  bodyBuilder;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final Widget? floatingActionButton;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AppScaffold({
    super.key,
    required this.bodyBuilder,
    this.isScrollable = true,
    this.padding,
    this.floatingActionButton,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    Get.isRegistered<LayoutController>()
        ? Get.find<LayoutController>()
        : Get.put(LayoutController());

    final key = scaffoldKey ?? GlobalKey<ScaffoldState>();

    return Scaffold(
      key: key,
      drawer: const LeftBar(),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Builder(
          builder: (childContext) {
            void openDrawer() {
              key.currentState?.openDrawer();
            }

            final content = bodyBuilder(childContext, openDrawer);

            return isScrollable
                ? SingleChildScrollView(
                    // padding: padding ?? MySpacing.all(8),
                    child: content,
                  )
                : Padding(padding: padding ?? EdgeInsets.zero, child: content);
          },
        ),
      ),
    );
  }
}
