import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:remixicon/remixicon.dart';

class TopBar extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const TopBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (context, notifier, child) {
        final topBarTheme = AdminTheme.theme.topBarTheme;

        return Container(
          height: 60,
          padding: MySpacing.x(8),
          decoration: BoxDecoration(
            color: topBarTheme.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. NÚT BÊN TRÁI
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  showBackButton
                      ? RemixIcons.arrow_left_line
                      : RemixIcons.menu_2_line,
                  color: topBarTheme.onBackground,
                  size: 28,
                ),
                onPressed: () {
                  if (showBackButton) {
                    if (onBackPressed != null) {
                      onBackPressed!();
                    } else {
                      // KIỂM TRA ROUTE STACK:
                      // Nếu có thể pop về trang trước trong stack thì dùng Get.back()
                      if (Navigator.of(context).canPop()) {
                        Get.back();
                      } else {
                        // Nếu Stack bị rỗng (do load lại hoặc navigate dạng replace), ép về trang chính
                        Get.offNamed('/produce-list');
                      }
                    }
                  } else {
                    Scaffold.of(context).openDrawer();
                  }
                },
              ),

              MySpacing.width(16),

              // 2. CHÍNH GIỮA: Tiêu đề
              Expanded(
                child: MyText.titleMedium(
                  title,
                  fontWeight: 700,
                  color: topBarTheme.onBackground,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 18,
                ),
              ),

              // 3. BÊN PHẢI: Actions
              if (actions != null && actions!.isNotEmpty)
                Row(mainAxisSize: MainAxisSize.min, children: actions!),
            ],
          ),
        );
      },
    );
  }
}
