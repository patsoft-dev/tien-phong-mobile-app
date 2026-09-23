import 'package:qr_app/helper/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import 'package:qr_app/controller/ui/components/forms/form_validation_controller.dart';
import 'package:qr_app/helper/theme/app_theme.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/utils/my_shadow.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb_item.dart';
import 'package:qr_app/helper/widgets/my_button.dart';
import 'package:qr_app/helper/widgets/my_card.dart';
import 'package:qr_app/helper/widgets/my_flex.dart';
import 'package:qr_app/helper/widgets/my_flex_item.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/helper/widgets/my_text_style.dart';
import 'package:qr_app/views/layout/layout.dart';

class FormValidationScreen extends StatefulWidget {
  const FormValidationScreen({super.key});

  @override
  State<FormValidationScreen> createState() => _FormValidationScreenState();
}

class _FormValidationScreenState extends State<FormValidationScreen>
    with UIMixin {
  FormValidationController controller = Get.put(FormValidationController());
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
                    "Form Validation",
                    fontSize: 18,
                    fontWeight: 600,
                  ),
                  MyBreadcrumb(
                    children: [
                      MyBreadcrumbItem(name: 'Form'),
                      MyBreadcrumbItem(name: 'Form Validation'),
                    ],
                  ),
                ],
              ),
              MySpacing.height(flexSpacing),
              MyFlex(
                wrapAlignment: WrapAlignment.start,
                wrapCrossAlignment: WrapCrossAlignment.start,
                children: [
                  MyFlexItem(sizes: "lg-6 md-12", child: validation()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget validation() {
    return MyCard(
      shadow: MyShadow(elevation: 1, position: MyShadowPosition.bottom),
      paddingAll: 24,
      child: Form(
        key: controller.basicValidator.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.labelMedium("Full Name"),
            MySpacing.height(8),
            CommonValidationForm(
              hintText: "Benjamin Campbell",
              icon: RemixIcons.user_3_line,
              validator: controller.basicValidator.getValidation('full_name'),
              controller: controller.basicValidator.getController('full_name'),
              outlineInputBorder: outlineInputBorder,
            ),
            MySpacing.height(16),
            MyText.labelMedium("Email Address"),
            MySpacing.height(8),
            CommonValidationForm(
              icon: RemixIcons.mail_line,
              hintText: "demo@themesdesign.com",
              validator: controller.basicValidator.getValidation('email'),
              controller: controller.basicValidator.getController('email'),
              outlineInputBorder: outlineInputBorder,
            ),
            MySpacing.height(16),
            MyText.labelMedium("Password"),
            MySpacing.height(8),
            CommonValidationForm(
              icon: RemixIcons.lock_line,
              hintText: "******",
              validator: controller.basicValidator.getValidation('password'),
              controller: controller.basicValidator.getController('password'),
              outlineInputBorder: outlineInputBorder,
            ),
            MySpacing.height(20),
            MyText.labelMedium("Gender"),
            MySpacing.height(8),
            DropdownButtonFormField<Gender>(
              dropdownColor: theme.colorScheme.surface,
              menuMaxHeight: 200,
              items: Gender.values
                  .map(
                    (gender) => DropdownMenuItem<Gender>(
                      value: gender,
                      child: MyText.labelMedium(gender.name.capitalize!),
                    ),
                  )
                  .toList(),
              icon: Icon(RemixIcons.arrow_drop_down_line, size: 20),
              decoration: InputDecoration(
                hintText: "Select gender",
                hintStyle: MyTextStyle.bodySmall(xMuted: true),
                border: outlineInputBorder,
                enabledBorder: outlineInputBorder,
                focusedBorder: focusedInputBorder,
                isCollapsed: true,
                isDense: true,
                contentPadding: MySpacing.all(12),
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              onChanged: controller.basicValidator.onChanged<Object?>('gender'),
              validator: controller.basicValidator.getValidation<Gender?>(
                'gender',
              ),
            ),
            MySpacing.height(16),
            MyText.labelMedium("City"),
            MySpacing.height(8),
            CommonValidationForm(
              icon: Remix.building_2_line,
              hintText: "City",
              validator: controller.basicValidator.getValidation('city'),
              controller: controller.basicValidator.getController('city'),
              outlineInputBorder: outlineInputBorder,
            ),
            MySpacing.height(16),
            MyText.labelMedium("State"),
            MySpacing.height(8),
            CommonValidationForm(
              icon: Remix.building_3_line,
              hintText: "State",
              validator: controller.basicValidator.getValidation('state'),
              controller: controller.basicValidator.getController('state'),
              outlineInputBorder: outlineInputBorder,
            ),
            MySpacing.height(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyButton(
                  onPressed: controller.onResetBasicForm,
                  elevation: 0,
                  padding: MySpacing.xy(20, 16),
                  backgroundColor: contentTheme.secondary,
                  borderRadiusAll: 8,
                  child: MyText.bodySmall(
                    'Clear',
                    color: contentTheme.onSecondary,
                  ),
                ),
                MySpacing.width(16),
                MyButton(
                  onPressed: controller.onSubmitBasicForm,
                  elevation: 0,
                  padding: MySpacing.xy(20, 16),
                  backgroundColor: contentTheme.primary,
                  borderRadiusAll: 8,
                  child: MyText.bodySmall(
                    'Submit',
                    color: contentTheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* Common Text Field For Validation */
class CommonValidationForm extends StatelessWidget {
  const CommonValidationForm({
    super.key,
    required this.controller,
    required this.outlineInputBorder,
    this.validator,
    this.hintText,
    this.icon,
  });

  final IconData? icon;
  final String? hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final OutlineInputBorder outlineInputBorder;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: MyTextStyle.bodySmall(xMuted: true),
        border: outlineInputBorder,
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        contentPadding: MySpacing.all(16),
        prefixIcon: icon == null ? SizedBox() : Icon(icon, size: 20),
        isCollapsed: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }
}
