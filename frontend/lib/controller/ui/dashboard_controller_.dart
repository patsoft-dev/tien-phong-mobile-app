import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:qr_app/controller/my_controller.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';

import '../../models/chart_model.dart';

enum TimeRange { all, oneMonth, sixMonths, oneYear }

class DashboardController extends MyController with UIMixin {
  TimeRange selectedRange = TimeRange.oneMonth;
  late List<ChartSampleData> socialSource;
  String selectedXLabel = 'Total';
  String selectedYLabel = '341';
  late MapShapeSource selectionMapSource;
  // late List<StateElectionDetails> stateWiseElectionResult;
  late List<MapColorMapper> colorMappers;
  int selectedIndex = -1;

  TooltipBehavior? tooltipBehavior;

  void onSelectTime(TimeRange value) {
    selectedRange = value;
    update();
  }

  String labelFor(TimeRange range) {
    switch (range) {
      case TimeRange.all:
        return 'ALL';
      case TimeRange.oneMonth:
        return '1M';
      case TimeRange.sixMonths:
        return '6M';
      case TimeRange.oneYear:
        return '1Y';
    }
  }

  String selectedMonth = 'MAY';

  final Map<String, String> months = {
    'MAY': 'May',
    'AP': 'April',
    'MA': 'March',
    'FE': 'February',
    'JA': 'January',
    'DE': 'December',
  };

  final List<ChartSampleData> chartData =
      [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ].map((month) {
        final random = Random();
        final y = random.nextInt(70) + 1;
        return ChartSampleData(x: month, y: y, yValue: y * 100);
      }).toList();

  final TooltipBehavior chart = TooltipBehavior(
    enable: true,
    format: 'point.x : point.yValue1 : point.yValue2',
  );
  @override
  // Giả định bạn đã định nghĩa class VietnamRevenueDetails và MapColorMapper ở ngoài class.
  void onInit() {
    // 1. Dữ liệu Doanh thu Việt Nam
    List<VietnamRevenueDetails> vietnamRevenueData = <VietnamRevenueDetails>[
      // Miền Bắc
      const VietnamRevenueDetails(
        provinceName: 'Hà Nội',
        revenueValue: 45.5,
        label: 'HN',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Hải Phòng',
        revenueValue: 28.0,
        label: 'HP',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Quảng Ninh',
        revenueValue: 32.7,
        label: 'QN',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Lào Cai',
        revenueValue: 10.1,
        label: 'LC',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Thái Nguyên',
        revenueValue: 18.5,
        label: 'TN',
      ),
      // Miền Trung
      const VietnamRevenueDetails(
        provinceName: 'Đà Nẵng',
        revenueValue: 38.2,
        label: 'ĐN',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Thừa Thiên Huế',
        revenueValue: 15.0,
        label: 'TTH',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Khánh Hòa',
        revenueValue: 22.9,
        label: 'KH',
      ),
      // Miền Nam
      const VietnamRevenueDetails(
        provinceName: 'Hồ Chí Minh',
        revenueValue: 55.0,
        label: 'HCM',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Đồng Nai',
        revenueValue: 41.3,
        label: 'ĐN',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Bình Dương',
        revenueValue: 48.8,
        label: 'BD',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Cần Thơ',
        revenueValue: 17.6,
        label: 'CT',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Kiên Giang',
        revenueValue: 12.4,
        label: 'KG',
      ),

      // Bổ sung hai quần đảo
      const VietnamRevenueDetails(
        provinceName: 'Hoàng Sa',
        revenueValue: 0.5,
        label: 'HS',
      ),
      const VietnamRevenueDetails(
        provinceName: 'Trường Sa',
        revenueValue: 0.5,
        label: 'TS',
      ),
    ];

    colorMappers = <MapColorMapper>[
      // RẤT CAO: > 50 Tỷ (Blue 900)
      const MapColorMapper(
        from: 50.0,
        to: 60.0, // Đặt giới hạn trên cao hơn giá trị max (55.0) một chút
        color: Color(0xFF0D47A1),
        text: 'Rất Cao (> 50 Tỷ)',
      ),
      // CAO: 30 - 50 Tỷ (Blue 400)
      const MapColorMapper(
        from: 30.0,
        to: 50.0,
        color: Color(0xFF42A5F5),
        text: 'Cao (30 - 50 Tỷ)',
      ),
      // TRUNG BÌNH: 15 - 30 Tỷ (Orange 500)
      const MapColorMapper(
        from: 15.0,
        to: 30.0,
        color: Color(0xFFFF9800),
        text: 'TB (15 - 30 Tỷ)',
      ),
      // THẤP: < 15 Tỷ (Red 600)
      const MapColorMapper(
        from: 0.0,
        to: 15.0,
        color: Color(0xFFE53935),
        text: 'Thấp (0 - 15 Tỷ)',
      ),
    ];
    tooltipBehavior = TooltipBehavior(
      enable: true,
      format: 'point.x : point.y',
    );

    socialSource = [
      ChartSampleData(
        x: 'Facebook',
        y: 10,
        text: '67%',
        pointColor: const Color.fromRGBO(248, 177, 149, 1.0),
      ),
      ChartSampleData(
        x: 'Tweeter',
        y: 11,
        text: '55%',
        pointColor: contentTheme.info,
      ),
      ChartSampleData(
        x: 'Instagram',
        y: 12,
        text: '44%',
        pointColor: contentTheme.success,
      ),
    ];

    // 3. Cấu hình MapShapeSource
    selectionMapSource = MapShapeSource.asset(
      'assets/data/vn_geo.json',
      shapeDataField: 'name', // Khớp với trường 'name' trong GeoJSON
      dataCount: vietnamRevenueData.length,

      // Ánh xạ Tên tỉnh để khớp với GeoJSON
      primaryValueMapper: (int index) => vietnamRevenueData[index].provinceName,

      // Ánh xạ Giá trị Doanh thu để tô màu
      shapeColorValueMapper: (int index) {
        return vietnamRevenueData[index].revenueValue;
      },

      // Áp dụng bảng màu đã chỉnh sửa
      shapeColorMappers: colorMappers,

      // Nhãn hiển thị trên bản đồ (ví dụ: mã tỉnh)
      dataLabelMapper: (int index) => vietnamRevenueData[index].label!,
    );

    super.onInit();
  }
}

class StateElectionDetails {
  const StateElectionDetails({
    required this.totalVoters,
    this.state,
    this.stateCode,
    this.party,
    this.candidate,
    this.votes,
    this.percentage,
  });

  final String? state;
  final String? stateCode;
  final double totalVoters;
  final String? party;
  final String? candidate;
  final double? votes;
  final double? percentage;
}

class VietnamRevenueDetails {
  const VietnamRevenueDetails({
    required this.provinceName, // Tên tỉnh/thành - PHẢI MATCH với trường 'name' trong vn_geo.json
    required this.revenueValue, // Giá trị dùng để tô màu
    this.label, // Nhãn hiển thị trên bản đồ (ví dụ: mã tỉnh)
  });

  final String provinceName;
  final double revenueValue;
  final String? label;
}
