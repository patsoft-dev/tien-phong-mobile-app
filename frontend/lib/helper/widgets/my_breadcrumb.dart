import 'package:qr_app/helper/widgets/my_breadcrumb_item.dart';
import 'package:qr_app/helper/widgets/my_constant.dart';
import 'package:qr_app/helper/widgets/my_responsive.dart';
import 'package:qr_app/helper/widgets/my_router.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:flutter/material.dart';

class MyBreadcrumb extends StatelessWidget {
  final List<MyBreadcrumbItem> children;
  final bool hideOnMobile;

  MyBreadcrumb({super.key, required this.children, this.hideOnMobile = true}) {
    if (MyConstant.constant.defaultBreadCrumbItem != null) {
      children.insert(0, MyConstant.constant.defaultBreadCrumbItem!);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < children.length; i++) {
      var item = children[i];
      if (item.active || item.route == null) {
        list.add(
          MyText.labelMedium(
            children[i].name,
            fontWeight: 500,
            fontSize: 13,
            letterSpacing: 0,
          ),
        );
      } else {
        list.add(
          InkWell(
            onTap: () => {
              if (item.route != null)
                MyRouter.pushReplacementNamed(context, item.route!),
            },
            child: MyText.labelMedium(
              children[i].name,
              fontWeight: 500,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        );
      }
      if (i < children.length - 1) {
        list.add(MySpacing.width(12));
        list.add(Icon(Icons.arrow_forward_ios_rounded, size: 10));
        list.add(MySpacing.width(12));
      }
    }
    return MyResponsive(
      builder: (_, _, type) {
        if (type.isMobile && hideOnMobile) {
          return SizedBox();
        } else {
          return Row(mainAxisSize: MainAxisSize.min, children: list);
        }
      },
    );
  }
}
