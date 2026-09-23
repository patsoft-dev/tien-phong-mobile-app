import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/widgets/my_modal.dart';

class MyAlertModal extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final bool isLoading;

  const MyAlertModal({
    super.key,
    this.title = 'Xác nhận',
    required this.message,
    this.cancelText = 'Hủy',
    this.confirmText = 'Đồng ý',
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return MyModal(
      title: title,
      maxWidth: 500,
      cancelText: cancelText,
      confirmText: confirmText,
      onCancel: onCancel ?? () => Get.back(),
      onConfirm: onConfirm,
      confirmButtonColor:
          confirmButtonColor ?? AdminTheme.theme.contentTheme.danger,
      isLoading: isLoading,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: MyText.bodyMedium(message, fontWeight: 500, fontSize: 15),
      ),
    );
  }
}
