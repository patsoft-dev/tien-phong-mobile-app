import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/ui/utilities/pricing_controller.dart';
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
import 'package:qr_app/helper/widgets/my_text_style.dart';
import 'package:qr_app/helper/widgets/responsive.dart';
import 'package:qr_app/views/layout/layout.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> with UIMixin {
  late PricingController controller;

  @override
  void initState() {
    controller = Get.put(PricingController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Pricing",
                      fontSize: 18,
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Utilities'),
                        MyBreadcrumbItem(name: 'Pricing'),
                      ],
                    ),
                  ],
                ),
                MySpacing.height(flexSpacing),
                MyText.titleLarge('Choose your pricing plan', fontWeight: 600),
                MySpacing.height(12),
                MyText.bodyMedium(
                  "To achieve this, it would be necessary to have uniform grammar, pronunciation and more common words If several languages coalesce",
                ),
                MySpacing.height(20),
                MyFlex(
                  children: controller.cards.mapIndexed((index, element) {
                    final card = controller.cards[index];
                    return MyFlexItem(
                      sizes: 'lg-3',
                      child: MyCard(
                        shadow: MyShadow(elevation: 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: contentTheme.primary,
                                  child: FaIcon(
                                    card.icon,
                                    color: contentTheme.onPrimary,
                                    size: 20,
                                  ),
                                ),
                                MySpacing.width(16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText.bodyLarge(
                                        card.title,
                                        fontWeight: 700,
                                      ),
                                      MyText.bodyMedium(
                                        card.subtitle,
                                        muted: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            MySpacing.height(16),
                            Divider(),
                            Padding(
                              padding: MySpacing.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text: '\$${card.price}',
                                        style: MyTextStyle.titleLarge(
                                          fontWeight: 600,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '/m',
                                            style: MyTextStyle.bodyMedium(
                                              muted: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  MyContainer(
                                    onTap: () {},
                                    color: contentTheme.primary,
                                    child: MyText.labelMedium(
                                      'Sign up Now',
                                      color: contentTheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MySpacing.height(12),
                            Center(
                              child: MyText.bodyMedium(
                                'Plan Features :',
                                fontWeight: 700,
                              ),
                            ),
                            MySpacing.height(12),
                            ...card.features.map(
                              (feature) => Padding(
                                padding: MySpacing.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: contentTheme.primary,
                                      size: 18,
                                    ),
                                    MySpacing.width(8),
                                    Expanded(child: MyText.bodyMedium(feature)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
