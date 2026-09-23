import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';

class NavigationItem extends StatefulWidget {
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final String? route;
  final double? fontSize;

  const NavigationItem({
    super.key,
    this.iconData,
    required this.title,
    this.isCondensed = false,
    this.route,
    this.fontSize = 14,
  });

  @override
  State<NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> with UIMixin {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    // Thử dùng Get.currentRoute của GetX thay cho UrlService
    String currentRoute = Get.currentRoute;
    bool isActive = currentRoute == widget.route;
    // In ra console để debug xem 2 giá trị có thực sự khớp nhau không
    // debugPrint("Current: $currentRoute | WidgetRoute: ${widget.route}");

    return GestureDetector(
      onTap: () {
        // 1. Đóng Drawer nếu đang mở ở màn hình Mobile / Tablet
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop(); // Hoặc dùng Get.back();
        }

        // 2. Chuyển route
        if (widget.route != null) {
          Get.toNamed(widget.route!);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: MyContainer(
          color: (isHover || isActive)
              ? leftBarTheme.activeItemBackground
              : Colors.transparent,
          margin: MySpacing.xy(8, 2),
          borderRadiusAll: 0,
          padding: isActive ? MySpacing.xy(4, 12) : MySpacing.xy(2, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.iconData != null)
                Center(
                  child: Icon(
                    widget.iconData,
                    color: (isHover || isActive)
                        ? leftBarTheme.activeItemColor
                        : leftBarTheme.labelColor,
                    size: 20,
                  ),
                ),
              if (!widget.isCondensed)
                Flexible(fit: FlexFit.loose, child: MySpacing.width(16)),
              if (!widget.isCondensed)
                Expanded(
                  flex: 3,
                  child: MyText.labelLarge(
                    widget.title,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    fontWeight: isActive ? 600 : 500,
                    fontSize: isActive ? widget.fontSize! + 1 : widget.fontSize,
                    color: (isHover || isActive)
                        ? leftBarTheme.activeItemColor
                        : leftBarTheme.labelColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
