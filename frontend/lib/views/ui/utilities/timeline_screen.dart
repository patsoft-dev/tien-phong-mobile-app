import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/controller/ui/utilities/timeline_controller.dart';
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

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with UIMixin {
  late TimelineController controller;

  @override
  void initState() {
    controller = Get.put(TimelineController());
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
                  MyText.titleMedium("TimiLine", fontSize: 18, fontWeight: 600),
                  MyBreadcrumb(
                    children: [
                      MyBreadcrumbItem(name: 'Utilities'),
                      MyBreadcrumbItem(name: 'TimeLine'),
                    ],
                  ),
                ],
              ),
              MySpacing.height(flexSpacing),
              MyCard(
                shadow: MyShadow(elevation: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium('Horizontal Timeline', fontWeight: 600),
                    MySpacing.height(20),
                    MyFlex(
                      children: controller.items.mapIndexed((index, element) {
                        final isSelected = index == controller.selectedIndex;
                        return MyFlexItem(
                          sizes: 'lg-1.6',
                          child: MyContainer.bordered(
                            onTap: () => controller.onNavTap(index),
                            width: 160,
                            margin: MySpacing.symmetric(horizontal: 8),
                            color: isSelected
                                ? contentTheme.primary.withValues(alpha: 0.2)
                                : contentTheme.secondary.withValues(alpha: 0.1),
                            borderRadiusAll: 12,
                            border: Border.all(
                              color: isSelected
                                  ? contentTheme.primary.withValues(alpha: 0.2)
                                  : contentTheme.secondary.withValues(
                                      alpha: 0.1,
                                    ),
                              width: 2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText.bodyLarge(
                                  controller.items[index].period,
                                  color: isSelected
                                      ? contentTheme.primary
                                      : null,
                                ),
                                MySpacing.height(4),
                                MyText.labelMedium(
                                  controller.items[index].role.split(' of ')[0],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    MySpacing.height(20),
                    SizedBox(
                      height: 100,
                      child: PageView.builder(
                        controller: controller.pageController,
                        itemCount: controller.items.length,
                        onPageChanged: controller.onPageChanged,
                        itemBuilder: (context, index) {
                          final item = controller.items[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText.bodyLarge(
                                item.period,
                                fontWeight: 600,
                                color: contentTheme.primary,
                              ),
                              MySpacing.height(8),
                              MyText.bodyLarge(item.role, fontWeight: 600),
                              MySpacing.height(12),
                              MyText.bodyMedium(item.description, muted: true),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              MySpacing.height(12),
              MyCard(
                shadow: MyShadow(elevation: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium('Vertical Timeline', fontWeight: 600),
                    MySpacing.height(20),
                    ...controller.timelineEvents.asMap().entries.map((entry) {
                      final index = entry.key;
                      final event = entry.value;
                      return _buildTimelineTile(
                        event,
                        isLast: index == controller.timelineEvents.length - 1,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineTile(TimelineEvent event, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: contentTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 60,
                      color: contentTheme.secondary.withValues(alpha: 0.22),
                    ),
                ],
              ),
            ),
          ],
        ),
        MySpacing.width(12),
        Expanded(
          child: Padding(
            padding: MySpacing.bottom(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(event.date, color: contentTheme.primary),
                MySpacing.height(4),
                MyText.bodyMedium(event.title, fontWeight: 600),
                MySpacing.height(4),
                MyText.bodyMedium(event.description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
