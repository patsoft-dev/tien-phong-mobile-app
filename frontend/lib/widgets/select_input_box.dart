import 'package:flutter/material.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:remixicon/remixicon.dart';

class SelectInputBox extends StatelessWidget {
  final String? value;
  final String hintText;
  final dynamic contentTheme;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final VoidCallback? onScanQr;

  const SelectInputBox({
    super.key,
    required this.hintText,
    required this.contentTheme,
    required this.onTap,
    this.value,
    this.onClear,
    this.onScanQr,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: contentTheme.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Text hiển thị giá trị hoặc hint text
              Expanded(
                child: Text(
                  hasValue ? value! : hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasValue
                        ? contentTheme.onBackground
                        : contentTheme.onBackground.withOpacity(0.4),
                    fontSize: 13,
                    fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),

              // Icon Clear (nếu có giá trị)
              if (hasValue && onClear != null)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onClear,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      RemixIcons.close_line,
                      size: 18,
                      color: contentTheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ),

              if (hasValue && onClear != null && onScanQr != null)
                MySpacing.width(4),

              // Icon Quét QR Code
              if (onScanQr != null)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onScanQr,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      RemixIcons.qr_code_line,
                      size: 18,
                      color: contentTheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
