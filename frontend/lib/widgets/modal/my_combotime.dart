import 'package:flutter/material.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_text.dart';

class MyCombotime extends StatelessWidget {
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final String hintText;

  const MyCombotime({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText = "Chọn giờ",
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return MyContainer.bordered(
      onTap: () => _selectTime(context),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      borderRadiusAll: 4,
      borderColor: contentTheme.secondary.withValues(alpha: 0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText.bodyMedium(
            value != null ? _formatTime(value!) : hintText,
            color: value != null
                ? contentTheme.onBackground
                : contentTheme.secondary,
            fontWeight: value != null ? 500 : 400,
          ),
          Icon(
            Icons.access_time_outlined,
            size: 16,
            color: contentTheme.secondary,
          ),
        ],
      ),
    );
  }
}
