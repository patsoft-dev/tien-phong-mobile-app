import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';

enum BannerType { success, error, info }

class MyBannerNotification {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    BannerType type = BannerType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onClose,
  }) {
    // Ẩn banner cũ nếu đang hiển thị
    hide();

    final contentTheme = AdminTheme.theme.contentTheme;
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case BannerType.success:
        backgroundColor = contentTheme.success;
        icon = RemixIcons.checkbox_circle_line;
        break;
      case BannerType.error:
        backgroundColor = contentTheme.danger;
        icon = RemixIcons.error_warning_line;
        break;
      case BannerType.info:
      default:
        backgroundColor = contentTheme.info;
        icon = RemixIcons.information_line;
        break;
    }

    _currentEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top:
              MediaQuery.of(context).padding.top +
              8, // Tránh SafeArea/Thanh trạng thái
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: MySpacing.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  MySpacing.width(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyText.bodyMedium(
                          title,
                          fontWeight: 700,
                          color: Colors.white,
                        ),
                        if (message.isNotEmpty) ...[
                          MySpacing.height(4),
                          MyText.bodySmall(
                            message,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      RemixIcons.close_line,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      hide();
                      if (onClose != null) onClose();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Chèn vào Overlay cao nhất của App
    Overlay.of(context, rootOverlay: true).insert(_currentEntry!);

    // Tự động đóng sau duration
    if (duration != Duration.zero) {
      Future.delayed(duration, () {
        hide();
        if (onClose != null) onClose();
      });
    }
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
