import 'package:flutter/material.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_text.dart';

class MyCombodate extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String formatPattern;

  const MyCombodate({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText = "Chọn ngày",
    this.firstDate,
    this.lastDate,
    this.formatPattern = "dd/MM/yyyy",
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    if (formatPattern == "yyyy-MM-dd") {
      return "$year-$month-$day";
    }
    // Mặc định dd/MM/yyyy
    return "$day/$month/$year";
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return MyContainer.bordered(
      onTap: () => _selectDate(context),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      borderRadiusAll: 4,
      borderColor: contentTheme.border,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText.bodyMedium(
            value != null ? _formatDate(value!) : hintText,
            color: value != null
                ? contentTheme.onBackground
                : contentTheme.secondary,
            fontWeight: value != null ? 500 : 400,
          ),
          Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: contentTheme.secondary,
          ),
        ],
      ),
    );
  }
}
