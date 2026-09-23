import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';

class MyModal extends StatelessWidget {
  final String title;
  final Widget content;
  final double? maxWidth; // Đổi sang nullable để nhận mặc định theo màn hình
  final double minWidth;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final bool isLoading;
  final List<Widget>? customActions;

  const MyModal({
    super.key,
    required this.title,
    required this.content,
    this.maxWidth, // Nếu truyền giá trị sẽ lấy giá trị đó, không truyền sẽ mặc định 95% width
    this.minWidth = 250,
    this.cancelText,
    this.confirmText,
    this.onCancel,
    this.onConfirm,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.isLoading = false,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      // Bỏ margin mặc định của Dialog để có thể tràn ra sát lề 95%
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Chiều rộng mặc định bằng 95% màn hình nếu không truyền maxWidth
          maxWidth: maxWidth ?? (screenWidth * 0.95),
          minWidth: minWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header Heading
            Padding(
              padding: MySpacing.xy(16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyText.titleMedium(
                      title,
                      fontWeight: 700,
                      fontSize: 17,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: contentTheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // 2. Content Body (Có cuộn nếu nội dung dài)
            Flexible(
              child: SingleChildScrollView(
                padding: MySpacing.all(10),
                child: content,
              ),
            ),

            const Divider(height: 1),

            // 3. Footer Action Buttons (Căn bên phải theo giao diện mẫu)
            Padding(
              padding: MySpacing.all(10),
              child: customActions != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: customActions!,
                    )
                  : _buildDefaultButtons(contentTheme),
            ),
          ],
        ),
      ),
    );
  }

  /// Nút thao tác mặc định
  Widget _buildDefaultButtons(dynamic contentTheme) {
    final List<Widget> actions = [];

    // Nút Hủy / Đóng
    if (cancelText != null) {
      actions.add(
        MyContainer(
          onTap: onCancel ?? () => Get.back(),
          color: cancelButtonColor ?? contentTheme.secondary.withAlpha(36),
          padding: MySpacing.xy(24, 16),
          borderRadiusAll: 4,
          child: MyText.bodySmall(
            cancelText!,
            fontWeight: 600,
            fontSize: 15,
            color: contentTheme.secondary,
          ),
        ),
      );
    }

    if (cancelText != null && confirmText != null) {
      actions.add(MySpacing.width(12));
    }

    // Nút Lưu / Xác nhận
    if (confirmText != null) {
      actions.add(
        MyContainer(
          onTap: isLoading ? null : onConfirm,
          color: confirmButtonColor ?? contentTheme.primary,
          padding: MySpacing.xy(24, 16),
          borderRadiusAll: 4,
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: contentTheme.onPrimary,
                  ),
                )
              : MyText.bodySmall(
                  confirmText!,
                  fontWeight: 600,
                  fontSize: 15,
                  color: contentTheme.onPrimary,
                ),
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: actions);
  }
}
