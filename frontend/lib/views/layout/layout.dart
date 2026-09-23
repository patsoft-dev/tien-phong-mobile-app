import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/layout/layout_controller.dart';
import 'package:qr_app/helper/widgets/my_responsive.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/views/layout/left_bar.dart';
import 'package:qr_app/views/layout/top_bar.dart';

class Layout extends StatefulWidget {
  final Widget? child;

  const Layout({super.key, this.child});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  // Đăng ký LayoutController với GetX
  late final LayoutController controller;
  @override
  void initState() {
    super.initState();
    controller = Get.put(LayoutController());
  }

  @override
  Widget build(BuildContext context) {
    return MyResponsive(
      builder: (BuildContext context, _, screenMT) {
        return GetBuilder<LayoutController>(
          init: controller,
          builder: (controller) {
            return mainScreen();
          },
        );
      },
    );
  }

  Widget mainScreen() {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: const LeftBar(),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [];
        },
        body: SingleChildScrollView(
          padding: MySpacing.all(20),
          key: controller.scrollKey,
          child: widget.child,
        ),
      ),
    );
  }
}
