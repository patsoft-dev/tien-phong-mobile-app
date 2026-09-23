import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/ui/utilities/faqs_controller.dart';
import 'package:qr_app/helper/utils/my_shadow.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb_item.dart';
import 'package:qr_app/helper/widgets/my_card.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_flex.dart';
import 'package:qr_app/helper/widgets/my_flex_item.dart';
import 'package:qr_app/helper/widgets/my_list_extension.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/helper/widgets/responsive.dart';
import 'package:qr_app/views/layout/layout.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> with UIMixin {
  late FaqsController controller;

  @override
  void initState() {
    controller = Get.put(FaqsController());
    super.initState();
  }

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
                  MyText.titleMedium("Faqs", fontSize: 18, fontWeight: 600),
                  MyBreadcrumb(
                    children: [
                      MyBreadcrumbItem(name: 'Utilities'),
                      MyBreadcrumbItem(name: 'Faqs'),
                    ],
                  ),
                ],
              ),
              MySpacing.height(flexSpacing),
              MyCard(
                shadow: MyShadow(elevation: 1),
                child: Column(
                  children: [
                    Center(
                      child: MyFlex(
                        children: controller.cards.mapIndexed((index, element) {
                          InfoCardItem item = controller.cards[index];
                          return MyFlexItem(
                            sizes: 'lg-2',
                            child: MyCard.bordered(
                              onTap: item.onTap,
                              borderRadiusAll: 4,
                              shadow: MyShadow(elevation: 0.1),
                              padding: MySpacing.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 36,
                                    color: contentTheme.primary,
                                  ),
                                  MySpacing.height(20),
                                  MyText.bodyMedium(
                                    item.title,
                                    textAlign: TextAlign.center,
                                    fontWeight: 600,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    MySpacing.height(Get.height * 0.09),
                    MyFlex(
                      runSpacing: 40,
                      spacing: 40,
                      children: controller.faqs.mapIndexed((index, element) {
                        final faqs = controller.faqs[index];
                        return MyFlexItem(
                          sizes: 'lg-5',
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyContainer.rounded(
                                color: contentTheme.primary,
                                paddingAll: 8,
                                child: MyText.labelMedium(
                                  faqs['number'],
                                  color: contentTheme.onPrimary,
                                ),
                              ),
                              MySpacing.width(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.bodyMedium(
                                      faqs['question'],
                                      fontWeight: 700,
                                    ),
                                    MySpacing.height(8),
                                    MyText.bodyMedium(faqs['answer']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    MySpacing.height(Get.height * 0.07),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText.titleMedium(
                          "Can't find what you are looking for?",
                          fontWeight: 600,
                        ),
                        MySpacing.height(12),
                        MyText.bodyMedium(
                          'To achieve this, it would be necessary to have uniform grammar, pronunciation and more common words if several languages coalesce',
                        ),
                        MySpacing.height(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyContainer(
                              onTap: () {},
                              color: contentTheme.danger,
                              paddingAll: 12,
                              child: MyText.labelMedium(
                                'Email Us',
                                color: contentTheme.onDanger,
                              ),
                            ),
                            MySpacing.width(12),
                            MyContainer(
                              onTap: () {},
                              color: contentTheme.primary,
                              paddingAll: 12,
                              child: MyText.labelMedium(
                                'Send us a tweet',
                                color: contentTheme.onDanger,
                              ),
                            ),
                          ],
                        ),
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
}
