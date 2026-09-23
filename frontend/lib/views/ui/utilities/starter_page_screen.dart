import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/ui/utilities/starter_page_controller.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb_item.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/views/layout/layout.dart';

class StarterPageScreen extends StatefulWidget {
  const StarterPageScreen({super.key});

  @override
  State<StarterPageScreen> createState() => _StarterPageScreenState();
}

class _StarterPageScreenState extends State<StarterPageScreen> with UIMixin {
  late StarterPageController controller;

  @override
  void initState() {
    controller = Get.put(StarterPageController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium("Starter", fontSize: 18, fontWeight: 600),
              MyBreadcrumb(
                children: [
                  MyBreadcrumbItem(name: 'Utilities'),
                  MyBreadcrumbItem(name: 'Starter'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
