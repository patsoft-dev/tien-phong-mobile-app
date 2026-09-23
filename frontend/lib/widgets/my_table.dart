import 'package:flutter/material.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_card.dart';
import 'package:qr_app/helper/widgets/my_text.dart';

class TableColumn {
  final String name;
  final String label;
  final double? width;

  TableColumn({required this.name, required this.label, this.width});
}

class MyTable<T> extends StatelessWidget {
  final List<T> data;
  final List<TableColumn> columns;
  final void Function(T item, int index)? onRowPress;
  final Widget Function(String columnName, T item, int index)? renderCell;
  final double borderRadius;
  final String emptyText;
  final double? minHeight;

  const MyTable({
    super.key,
    required this.data,
    required this.columns,
    this.onRowPress,
    this.renderCell,
    this.borderRadius = 0,
    this.emptyText = 'Không có dữ liệu',
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;
    final borderColor = contentTheme.border.withOpacity(0.5);

    return MyCard(
      paddingAll: 0,
      borderRadiusAll: borderRadius,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Lấy chiều cao tối thiểu (ưu tiên minHeight truyền vào, nếu không thì lấy theo khung chứa còn lại)
          final calculatedMinHeight = minHeight ?? constraints.maxHeight;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: calculatedMinHeight.isInfinite
                    ? 300
                    : calculatedMinHeight,
              ),
              child: IntrinsicHeight(
                child: data.isEmpty
                    ? _buildEmptyState(contentTheme, borderColor)
                    : _buildDataTable(contentTheme, borderColor),
              ),
            ),
          );
        },
      ),
    );
  }

  // 1. Giao diện Bảng dữ liệu
  // my_table.dart

  Widget _buildDataTable(dynamic contentTheme, Color borderColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 8,
        showCheckboxColumn: false,
        border: TableBorder(
          horizontalInside: BorderSide(color: borderColor, width: 0.8),
          verticalInside: BorderSide(color: borderColor, width: 0.8),
        ),
        headingRowColor: WidgetStateProperty.all(contentTheme.primary),
        columns: columns.map((col) {
          return DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: SizedBox(
              width: col.width,
              child: MyText.titleMedium(
                col.label,
                fontWeight: 600,
                fontSize: 16,
                color: contentTheme.onPrimary,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),

        // my_table.dart
        // my_table.dart
        rows: List.generate(data.length, (index) {
          final item = data[index];
          return DataRow(
            cells: columns.map((col) {
              // Xác định căn chỉnh của Container theo cột (cột line_descr sẽ căn trái)
              final Alignment cellAlignment = col.name == "line_descr"
                  ? Alignment.centerLeft
                  : Alignment.center;

              return DataCell(
                InkWell(
                  onTap: onRowPress != null
                      ? () => onRowPress!(item, index)
                      : null,
                  child: Container(
                    width: col.width,
                    alignment: cellAlignment, // ✅ Căn chỉnh theo từng cột
                    child: renderCell != null
                        ? renderCell!(col.name, item, index)
                        : _defaultRenderCell(col.name, item, index),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }

  // 2. Giao diện khi không có dữ liệu (Border xám nhạt ở dưới Header)
  Widget _buildEmptyState(dynamic contentTheme, Color borderColor) {
    return Column(
      children: [
        // Header Bảng
        Container(
          color: contentTheme.primary,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              horizontalMargin: 8,
              headingRowColor: WidgetStateProperty.all(contentTheme.primary),
              columns: columns.map((col) {
                return DataColumn(
                  headingRowAlignment: MainAxisAlignment.center,
                  label: SizedBox(
                    width: col.width,
                    child: MyText.titleMedium(
                      col.label,
                      fontWeight: 600,
                      fontSize: 16,
                      color: contentTheme.onPrimary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
              rows: const [],
            ),
          ),
        ),

        // Vùng hiển thị Empty Message chiếm trọn phần chiều cao còn lại
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: borderColor, width: 0.8),
                right: BorderSide(color: borderColor, width: 0.8),
                bottom: BorderSide(color: borderColor, width: 0.8),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: MyText.bodyMedium(
                  emptyText,
                  color: contentTheme.onBackground.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: 500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultRenderCell(String columnName, T item, int index) {
    if (columnName == 'STT') {
      return MyText.bodySmall('${index + 1}', fontSize: 14);
    }

    dynamic value;
    if (item is Map) {
      value = item[columnName];
    } else {
      try {
        value = (item as dynamic).toJson()[columnName];
      } catch (_) {
        value = '';
      }
    }

    return MyText.bodySmall(value?.toString() ?? '', fontSize: 14);
  }
}
