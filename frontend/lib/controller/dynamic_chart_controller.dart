import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/dynamic_chart_model.dart';

/// Controller cho biểu đồ Cột, Ngang, Stacked
class DynamicChartController extends GetxController {
  final String title;
  final List<String> seriesNames;
  final List<DynamicChartRow> dataSource;
  final List<Color>? colors;

  DynamicChartController({
    required this.title,
    required this.seriesNames,
    required this.dataSource,
    this.colors,
  });

  // Getter tự động chuyển đổi dữ liệu cho Progress Chart khi cần
  List<ProgressData> get progressData {
    return dataSource.map((row) {
      return ProgressData(
        label: row.x,
        current: row.values.isNotEmpty ? row.values[0] : 0,
        total: row.values.length > 1 ? row.values[1] : 100,
      );
    }).toList();
  }

  List<Color> get chartColors =>
      colors ??
      [Colors.blue, Colors.orange, Colors.green, Colors.red, Colors.purple];

  double getMaxValue() {
    double max = 0;
    for (var row in dataSource) {
      for (var value in row.values) {
        if (value > max) {
          max = value.toDouble();
        }
      }
    }
    // Nếu tất cả bằng 0, trả về một mốc mặc định (ví dụ 10) để tránh lỗi biểu đồ
    return max == 0 ? 10 : max;
  }
}

/// Controller cho biểu đồ Tròn (Fix lỗi valueLabel bạn gặp phải)
class DynamicPieController extends GetxController {
  final String title;
  final String? valueLabel;
  final List<DynamicPieData> pieDataSource;
  final List<Color>? colors;

  DynamicPieController({
    required this.title,
    this.valueLabel,
    required this.pieDataSource,
    this.colors,
  });

  List<Color> get chartColors =>
      colors ??
      [
        const Color(0xFF929DFB),
        const Color(0xFFF698D9),
        Colors.orange,
        Colors.green,
      ];
}

/// Controller cho các bảng dữ liệu (Table)
class DynamicTableController extends GetxController {
  final String title;
  final List<String> columnLabels;
  final List<DynamicTableRow> data;

  DynamicTableController({
    required this.title,
    required this.columnLabels,
    required this.data,
  });
}
