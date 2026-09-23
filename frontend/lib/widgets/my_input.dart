import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:remixicon/remixicon.dart';

class MyInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onScanTap;
  final bool showScanIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final int debounceTime;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? iconColor;
  final Color? borderColor;
  final double borderRadius;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const MyInput({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onScanTap,
    this.showScanIcon = false,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onChanged,
    this.debounceTime = 300,
    this.validator,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.iconColor,
    this.borderColor,
    this.borderRadius = 4.0,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.focusNode,
  });

  @override
  State<MyInput> createState() => _MyInputState();
}

class _MyInputState extends State<MyInput> with UIMixin {
  late bool _obscureText;
  Timer? _debounceTimer;

  // 💡 Key và FocusNode quản lý tự động cuộn màn hình
  final GlobalKey _inputKey = GlobalKey();
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    } else {
      _effectiveFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  /// 💡 Tự động đẩy màn hình lên khi Focus vào input bị bàn phím che
  void _onFocusChange() {
    if (_effectiveFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _inputKey.currentContext != null) {
          Scrollable.ensureVisible(
            _inputKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment:
                0.3, // Căn vị trí ô input ở khoảng 30% phía trên bàn phím
          );
        }
      });
    }
  }

  /// Xử lý Debounce cho sự kiện onChanged
  void _handleOnChanged(String value) {
    if (widget.onChanged == null) return;

    if (widget.debounceTime <= 0) {
      widget.onChanged!(value);
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceTime), () {
      if (mounted) {
        widget.onChanged!(value);
      }
    });
  }

  /// Xử lý render danh sách icon ở phía sau (Suffix Icons)
  Widget? _buildSuffixIcon(Color effectiveIconColor) {
    if (widget.isPassword) {
      return InkWell(
        onTap: () => setState(() => _obscureText = !_obscureText),
        child: Icon(
          _obscureText ? RemixIcons.eye_off_line : RemixIcons.eye_line,
          color: effectiveIconColor,
          size: 20,
        ),
      );
    }

    final bool hasScan = widget.showScanIcon || widget.onScanTap != null;
    final bool hasSuffix = widget.suffixIcon != null;

    if (!hasScan && !hasSuffix) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasSuffix)
          InkWell(
            onTap: widget.onSuffixTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                widget.suffixIcon,
                color: effectiveIconColor,
                size: 20,
              ),
            ),
          ),
        if (hasScan)
          InkWell(
            onTap: widget.onScanTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Icon(
                RemixIcons.qr_code_line,
                color: effectiveIconColor,
                size: 20,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = widget.textColor ?? contentTheme.onBackground;
    final effectiveHintColor =
        widget.hintColor ?? contentTheme.onBackground.withOpacity(0.4);
    final effectiveIconColor =
        widget.iconColor ?? contentTheme.onBackground.withOpacity(0.6);
    final effectiveFillColor = widget.enabled
        ? (widget.fillColor ?? contentTheme.cardBackground)
        : contentTheme.onBackground.withOpacity(0.05);

    // 💡 TapRegion: Bấm bất kỳ đâu ngoài vùng này sẽ đóng bàn phím
    return TapRegion(
      onTapOutside: (_) {
        if (_effectiveFocusNode.hasFocus) {
          _effectiveFocusNode.unfocus();
        }
      },
      child: Column(
        key: _inputKey, // 💡 Gán Key để Scrollable.ensureVisible tìm vị trí
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelText != null) ...[
            Text(
              widget.labelText!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: effectiveTextColor,
              ),
            ),
            MySpacing.height(8),
          ],
          TextFormField(
            controller: widget.controller,
            focusNode: _effectiveFocusNode,
            initialValue: widget.controller == null
                ? widget.initialValue
                : null,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            onChanged: _handleOnChanged,
            validator: widget.validator,
            readOnly: widget.readOnly,
            enabled: widget.enabled,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: effectiveTextColor,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: 14,
                color: effectiveHintColor,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: effectiveFillColor,
              contentPadding: MySpacing.all(16),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: effectiveIconColor, size: 20)
                  : null,
              suffixIcon: _buildSuffixIcon(effectiveIconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor ?? contentTheme.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor ?? contentTheme.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: contentTheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
