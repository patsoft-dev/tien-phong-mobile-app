import 'package:flutter/material.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:remixicon/remixicon.dart';

class MyDropdown<T> extends StatelessWidget with UIMixin {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? iconColor;
  final Color? borderColor;
  final double borderRadius;

  const MyDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.validator,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.iconColor,
    this.borderColor,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Khởi tạo màu sắc linh hoạt theo Theme
    final effectiveTextColor = textColor ?? contentTheme.onBackground;
    final effectiveHintColor =
        hintColor ?? contentTheme.onBackground.withOpacity(0.4);
    final effectiveIconColor =
        iconColor ?? contentTheme.onBackground.withOpacity(0.6);
    final effectiveFillColor =
        fillColor ?? contentTheme.onBackground.withOpacity(0.05);
    final effectiveBorderColor = borderColor ?? contentTheme.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: effectiveTextColor,
            ),
          ),
          MySpacing.height(8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          dropdownColor: contentTheme.background,
          isExpanded: true,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: effectiveTextColor,
          ),
          icon: Icon(RemixIcons.arrow_down_s_line, color: effectiveHintColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: effectiveHintColor,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: effectiveFillColor,
            contentPadding: MySpacing.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: effectiveIconColor, size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: contentTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: contentTheme.danger),
            ),
          ),
        ),
      ],
    );
  }
}
