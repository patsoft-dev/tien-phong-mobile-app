import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/ui/components/forms/form_editor_controller.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/utils/my_shadow.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb_item.dart';
import 'package:qr_app/helper/widgets/my_card.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/views/layout/layout.dart';

import '../../../../helper/widgets/responsive.dart';

class FormEditorScreen extends StatefulWidget {
  const FormEditorScreen({super.key});

  @override
  State<FormEditorScreen> createState() => _FormEditorScreenState();
}

class _FormEditorScreenState extends State<FormEditorScreen> with UIMixin {
  FormEditorController controller = Get.put(FormEditorController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'editor_controller',
      builder: (controller) {
        return Layout(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.titleMedium(
                    "Form Editor",
                    fontSize: 18,
                    fontWeight: 600,
                  ),
                  MyBreadcrumb(
                    children: [
                      MyBreadcrumbItem(name: 'Form'),
                      MyBreadcrumbItem(name: 'Form Editor'),
                    ],
                  ),
                ],
              ),
              MySpacing.height(flexSpacing),
              MyCard(
                borderRadiusAll: 12,
                shadow: MyShadow(
                  elevation: .5,
                  position: MyShadowPosition.bottom,
                ),
                paddingAll: 20,
                child: Column(
                  children: [
                    QuillSimpleToolbar(
                      controller: controller.quillController,
                      config: QuillSimpleToolbarConfig(),
                    ),
                    SizedBox(
                      height: 300,
                      child: QuillEditor.basic(
                        controller: controller.quillController,
                        config: QuillEditorConfig(
                          showCursor: true,
                          expands: false,
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
