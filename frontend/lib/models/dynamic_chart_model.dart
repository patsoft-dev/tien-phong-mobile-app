import 'package:flutter/material.dart';

/// Dữ liệu dòng chung cho Bar, Stacked, và Line Chart
class DynamicChartRow {
  final String x;
  final List<num> values;

  DynamicChartRow({required this.x, required this.values});
}

/// Dữ liệu cho Pie Chart (Biểu đồ tròn)
class DynamicPieData {
  final String label;
  final num value;
  final Color? color;
  final String? valueLabel;

  DynamicPieData({
    required this.label,
    required this.value,
    this.color,
    this.valueLabel,
  });
}

/// Dữ liệu cho các thẻ thống kê nhanh (Stat Cards)
class DashboardStatData {
  final double percent;
  final String title;
  final String subTitle;
  final String? percentile;
  final IconData icon;
  final Color? color;

  DashboardStatData({
    required this.percent,
    required this.title,
    required this.subTitle,
    this.percentile,
    required this.icon,
    this.color,
  });
}

/// Dữ liệu cho các bảng danh sách (Top List Table)
class DynamicTableRow {
  final String code;
  final String name;
  final double value;
  final Map<String, dynamic>? extraData;

  DynamicTableRow({
    required this.code,
    required this.name,
    required this.value,
    this.extraData,
  });
}

/// Dữ liệu chuyên biệt cho Progress Chart
class ProgressData {
  final String label;
  final num current;
  final num total;

  ProgressData({
    required this.label,
    required this.current,
    required this.total,
  });
}
