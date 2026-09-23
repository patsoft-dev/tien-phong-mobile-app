import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:remixicon/remixicon.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:qr_app/controller/ui/dashboard_controller.dart';
import 'package:qr_app/helper/utils/my_shadow.dart';
import 'package:qr_app/helper/utils/ui_mixins.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb.dart';
import 'package:qr_app/helper/widgets/my_breadcrumb_item.dart';
import 'package:qr_app/helper/widgets/my_card.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_flex.dart';
import 'package:qr_app/helper/widgets/my_flex_item.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/helper/widgets/my_text_style.dart';
import 'package:qr_app/helper/widgets/responsive.dart';
import 'package:qr_app/views/layout/layout.dart';

import '../../models/chart_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with UIMixin {
  late DashboardController controller;

  @override
  void initState() {
    controller = Get.put(DashboardController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.titleMedium(
                    "Dashboard",
                    fontSize: 18,
                    fontWeight: 600,
                  ),
                  MyBreadcrumb(children: [MyBreadcrumbItem(name: 'Dashboard')]),
                ],
              ),
              MySpacing.height(flexSpacing),
              MyFlex(
                children: [
                  MyFlexItem(
                    sizes: 'lg-3 md-6',
                    child: stats(
                      72,
                      'Users',
                      '2.2k',
                      '0.02%',
                      RemixIcons.arrow_right_up_line,
                    ),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6',
                    child: stats(
                      45,
                      'Views per minute',
                      '50',
                      '1.7%',
                      RemixIcons.arrow_right_up_line,
                    ),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6',
                    child: stats(
                      54,
                      'Bounce Rate',
                      '24.03%',
                      '0.01%',
                      RemixIcons.arrow_right_down_line,
                    ),
                  ),
                  // MyFlexItem(
                  //   sizes: 'lg-3 md-6',
                  //   child: MyCard(
                  //     shadow: MyShadow(elevation: 0.2),
                  //     height: 110,
                  //     child: Row(
                  //       children: [
                  //         MyContainer.rounded(
                  //           color: contentTheme.secondary.withValues(
                  //             alpha: 0.2,
                  //           ),
                  //           paddingAll: 12,
                  //           child: Icon(RemixIcons.group_line),
                  //         ),
                  //         MySpacing.width(12),
                  //         Expanded(
                  //           child: Column(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               MyText.bodyMedium("New Visitors"),
                  //               MyText.bodyLarge("435", fontWeight: 700),
                  //               Row(
                  //                 children: [
                  //                   MyText.bodyMedium(
                  //                     '0.01%',
                  //                     color: contentTheme.success,
                  //                   ),
                  //                   MySpacing.width(8),
                  //                   Icon(
                  //                     RemixIcons.arrow_right_up_line,
                  //                     size: 16,
                  //                     color: contentTheme.success,
                  //                   ),
                  //                   MySpacing.width(8),
                  //                   Expanded(
                  //                     child: MyText.bodyMedium(
                  //                       'from previews',
                  //                       maxLines: 1,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  MyFlexItem(
                    sizes: 'lg-8',
                    child: MyCard(
                      shadow: MyShadow(elevation: 1),
                      child: overview(),
                    ),
                  ),
                  // MyFlexItem(
                  //   sizes: 'lg-4',
                  //   child: MyCard(
                  //     shadow: MyShadow(elevation: 1),
                  //     child: socialSource(),
                  //   ),
                  // ),
                  // MyFlexItem(sizes: 'lg-4', child: orderStats()),
                  // MyFlexItem(sizes: 'lg-4', child: notifications()),
                  MyFlexItem(sizes: 'lg-4', child: revenueByLocation()),
                  // MyFlexItem(child: latestTransaction()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget stats(
    double percent,
    String title,
    String subTitle,
    String percentile,
    IconData icon,
  ) {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      height: 110,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: CircularPercentIndicator(
              radius: 35.0,
              lineWidth: 6.0,
              percent: percent / 100,
              center: MyText.bodyMedium(
                '${percent.toStringAsFixed(0)}%',
                fontWeight: 600,
              ),
              progressColor: contentTheme.primary,
              backgroundColor: Colors.blue.shade50,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
          MySpacing.width(12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(title),
                MyText.bodyLarge(subTitle, fontWeight: 700),
                Row(
                  children: [
                    MyText.bodyMedium(
                      percentile,
                      color: icon == RemixIcons.arrow_right_down_line
                          ? contentTheme.danger
                          : contentTheme.success,
                    ),
                    MySpacing.width(8),
                    Icon(
                      icon,
                      size: 16,
                      color: icon == RemixIcons.arrow_right_down_line
                          ? contentTheme.danger
                          : contentTheme.success,
                    ),
                    MySpacing.width(8),
                    Expanded(
                      child: MyText.bodyMedium('from previews', maxLines: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget overview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.titleMedium('overview', fontWeight: 600),
        Row(
          children: [
            // MyText.titleMedium('overview', fontWeight: 600),
            // Expanded(child: MyText.titleMedium('overview', fontWeight: 600)),
            Wrap(
              spacing: 8.0,
              children: TimeRange.values.map((range) {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: controller.selectedRange == range
                        ? contentTheme.primary.withValues(alpha: 0.2)
                        : contentTheme.secondary.withValues(alpha: 0.2),
                    side: BorderSide.none,
                    foregroundColor: controller.selectedRange == range
                        ? contentTheme.primary
                        : contentTheme.secondary.withValues(alpha: 0.2),
                    padding: MySpacing.all(2),
                    textStyle: MyTextStyle.labelMedium(fontSize: 14),
                  ),
                  onPressed: () => controller.onSelectTime(range),
                  child: MyText.bodyMedium(
                    controller.labelFor(range),
                    color: controller.selectedRange == range
                        ? contentTheme.primary
                        : contentTheme.secondary,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        MySpacing.height(12),
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          tooltipBehavior: controller.chart,
          axes: <ChartAxis>[
            NumericAxis(
              numberFormat: NumberFormat.compact(),
              majorGridLines: const MajorGridLines(width: 0),
              opposedPosition: true,
              name: 'yAxis1',
              interval: 1000,
              minimum: 0,
              maximum: 7000,
            ),
          ],
          series: [
            ColumnSeries<ChartSampleData, String>(
              animationDuration: 2000,
              width: 0.5,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              color: contentTheme.primary,
              dataSource: controller.chartData,
              xValueMapper: (ChartSampleData data, _) => data.x,
              yValueMapper: (ChartSampleData data, _) => data.y,
              name: 'Unit Sold',
            ),
            LineSeries<ChartSampleData, String>(
              animationDuration: 2000,
              animationDelay: 500,
              dataSource: controller.chartData,
              xValueMapper: (ChartSampleData data, _) => data.x,
              yValueMapper: (ChartSampleData data, _) => data.yValue,
              yAxisName: 'yAxis1',
              markerSettings: const MarkerSettings(isVisible: true),
              name: 'Total Transaction',
            ),
          ],
        ),
        Divider(),
        MyFlex(
          runAlignment: WrapAlignment.spaceBetween,
          wrapAlignment: WrapAlignment.spaceBetween,
          wrapCrossAlignment: WrapCrossAlignment.start,
          children: [
            MyFlexItem(
              sizes: 'lg-2 md-4 sm-4',
              child: _buildStatItem(
                context,
                label: 'Expenses',
                color: Colors.blue,
                amount: '\$ 8,524',
                percent: '1.2%',
                percentColor: Colors.green,
              ),
            ),
            MyFlexItem(
              sizes: 'lg-2 md-4 sm-4',
              child: _buildStatItem(
                context,
                label: 'Maintenance',
                color: Colors.grey.shade400,
                amount: '\$ 8,524',
                percent: '2.0%',
                percentColor: Colors.green,
              ),
            ),
            MyFlexItem(
              sizes: 'lg-2 md-4 sm-4',
              child: _buildStatItem(
                context,
                label: 'Profit',
                color: Colors.red,
                amount: '\$ 8,524',
                percent: '0.4%',
                percentColor: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required Color color,
    required String amount,
    required String percent,
    required Color percentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle, size: 10, color: color),
            MySpacing.width(6),
            MyText.bodyMedium(label, muted: true),
          ],
        ),
        MySpacing.height(8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: amount,
                style: MyTextStyle.bodyLarge(fontWeight: 600),
              ),
              TextSpan(text: '  '),
              WidgetSpan(
                child: Icon(Icons.arrow_drop_up, color: percentColor, size: 18),
              ),
              TextSpan(
                text: percent,
                style: MyTextStyle.bodyMedium(color: percentColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget socialSource() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MyText.titleMedium("Social Source", fontWeight: 600),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedMonth,
                  isDense: true,
                  isExpanded: false,
                  icon: Icon(Icons.keyboard_arrow_down),
                  style: MyTextStyle.labelMedium(),
                  items: controller.months.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      controller.selectedMonth = newValue!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 310,
          child: SfCircularChart(
            tooltipBehavior: controller.tooltipBehavior,
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText.bodyMedium(
                      controller.selectedXLabel,
                      fontWeight: 600,
                    ),
                    MyText.bodyMedium(
                      controller.selectedYLabel,
                      fontWeight: 600,
                    ),
                  ],
                ),
              ),
            ],
            series: <RadialBarSeries<ChartSampleData, String>>[
              RadialBarSeries<ChartSampleData, String>(
                dataSource: controller.socialSource,
                xValueMapper: (ChartSampleData data, _) => data.x,
                yValueMapper: (ChartSampleData data, _) => data.y,
                pointColorMapper: (ChartSampleData data, _) => data.pointColor,
                dataLabelMapper: (ChartSampleData data, _) => data.x,
                maximumValue: 15,
                radius: '100%',
                gap: '20%',
                cornerStyle: CornerStyle.endCurve,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 10),
                ),
                onPointTap: (ChartPointDetails details) {
                  final tappedData =
                      controller.socialSource[details.pointIndex!];
                  setState(() {
                    controller.selectedXLabel = tappedData.x;
                    controller.selectedYLabel = tappedData.text.toString();
                  });
                },
              ),
            ],
          ),
        ),
        MyFlex(
          children: [
            MyFlexItem(
              sizes: 'lg-4 md-4 sm-4',
              child: _buildSocialSource(
                icon: RemixIcons.facebook_fill,
                title: 'Facebook',
                sales: '125 sales',
                bgColor: Colors.blue,
              ),
            ),
            MyFlexItem(
              sizes: 'lg-4 md-4 sm-4',
              child: _buildSocialSource(
                icon: RemixIcons.twitter_fill,
                title: 'Twitter',
                sales: '112 sales',
                bgColor: Colors.lightBlueAccent,
              ),
            ),
            MyFlexItem(
              sizes: 'lg-4 md-4 sm-4',
              child: _buildSocialSource(
                icon: RemixIcons.instagram_fill,
                title: 'Instagram',
                sales: '104 sales',
                bgColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialSource({
    required IconData icon,
    required String title,
    required String sales,
    required Color bgColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyContainer.rounded(
          color: bgColor,
          paddingAll: 12,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        MySpacing.height(4),
        MyText.bodyMedium(title),
        MySpacing.height(4),
        MyText.bodyMedium(sales, muted: true),
      ],
    );
  }

  Widget orderStats() {
    return MyCard(
      shadow: MyShadow(elevation: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("Order Stats", fontWeight: 600),
          MySpacing.height(16),
          _buildProgressItem(
            icon: RemixIcons.checkbox_circle_line,
            label: "Completed",
            percent: 0.70,
            progressColor: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildProgressItem(
            icon: RemixIcons.calendar_2_line,
            label: "Pending",
            percent: 0.45,
            progressColor: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildProgressItem(
            icon: RemixIcons.close_circle_line,
            label: "Cancel",
            percent: 0.19,
            progressColor: Colors.red,
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatSummary("Completed", "70"),
              _buildStatSummary("Pending", "45"),
              _buildStatSummary("Cancel", "19"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatSummary(String label, String value) {
    return Column(
      children: [
        MyText.bodyMedium(label),
        MySpacing.height(4),
        MyText.bodyLarge(value, fontWeight: 600),
      ],
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required double percent,
    required Color progressColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyContainer.rounded(
          paddingAll: 12,
          color: contentTheme.secondary.withValues(alpha: 0.1),
          child: Icon(icon, color: contentTheme.primary, size: 20),
        ),
        MySpacing.width(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodyMedium(label, muted: true),
              MySpacing.height(6),
              LinearProgressIndicator(
                value: percent,
                backgroundColor: contentTheme.secondary.withValues(alpha: 0.2),
                color: progressColor,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget notifications() {
    return MyCard(
      shadow: MyShadow(elevation: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("notifications", fontWeight: 600),
          MySpacing.height(12),
          SizedBox(
            height: 238,
            child: ListView(
              children: [
                buildNotificationItem(
                  title: 'Scott Elliott',
                  message: 'If several languages coalesce',
                  time: '20 min ago',
                  avatarImage: 'assets/users/avatar-2.jpg',
                ),
                buildNotificationItem(
                  title: 'Team A',
                  message: 'Team A Meeting 9:15 AM',
                  time: '9:00 am',
                  icon: Icons.group_outlined,
                  iconColor: Colors.blue,
                ),
                buildNotificationItem(
                  title: 'Frank Martin',
                  message: 'Neque porro quisquam est',
                  time: '8:54 am',
                  avatarImage: 'assets/users/avatar-3.jpg',
                ),
                buildNotificationItem(
                  title: 'Updates',
                  message: 'It will be as simple as fact',
                  time: '27-03-2020',
                  icon: Icons.email_outlined,
                  iconColor: Colors.blue,
                ),
                buildNotificationItem(
                  title: 'Terry Garrick',
                  message: 'At vero eos et accusamus et',
                  time: '27-03-2020',
                  avatarImage: 'assets/users/avatar-4.jpg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationItem({
    required String title,
    required String message,
    required String time,
    String? avatarImage,
    IconData? icon,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: MySpacing.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: MySpacing.only(right: 12),
              child: avatarImage != null
                  ? CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage(avatarImage),
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(
                        icon ?? Icons.notifications,
                        color: iconColor ?? contentTheme.primary,
                        size: 20,
                      ),
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium(title, fontWeight: 600),
                  MyText.bodySmall(
                    message,
                    muted: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: MySpacing.only(left: 8),
              child: MyText.labelMedium(time, muted: true),
            ),
          ],
        ),
      ),
    );
  }

  // Widget revenueByLocation() {
  //   return MyCard(
  //     shadow: MyShadow(elevation: 1),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         MyText.titleMedium("Revenue by Location", fontWeight: 600),
  //         MySpacing.height(12),
  //         SizedBox(
  //           height: 237,
  //           child: SfMaps(
  //             layers: <MapLayer>[
  //               MapShapeLayer(
  //                 loadingBuilder: (BuildContext context) {
  //                   return const SizedBox(
  //                     height: 25,
  //                     width: 25,
  //                     child: CircularProgressIndicator(strokeWidth: 3),
  //                   );
  //                 },
  //                 source: controller.selectionMapSource,
  //                 zoomPanBehavior: MapZoomPanBehavior(
  //                   enablePanning: true,
  //                   enablePinching: true,
  //                   zoomLevel: 2,
  //                 ),
  //                 showDataLabels: true,
  //                 dataLabelSettings: const MapDataLabelSettings(
  //                   overflowMode: MapLabelOverflow.hide,
  //                   textStyle: TextStyle(color: Colors.black, fontSize: 9),
  //                 ),
  //                 selectedIndex: controller.selectedIndex,
  //                 strokeColor: Colors.white30,
  //                 selectionSettings: MapSelectionSettings(
  //                   color: contentTheme.primary,
  //                   strokeWidth: 2,
  //                 ),
  //                 onSelectionChanged: (int index) {
  //                   setState(() {
  //                     controller.selectedIndex =
  //                         (index == controller.selectedIndex) ? -1 : index;
  //                   });
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget revenueByLocation() {
    return MyCard(
      shadow: MyShadow(elevation: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("Revenue by Location", fontWeight: 600),
          MySpacing.height(12),
          SizedBox(
            height: 237,
            child: SfMaps(
              layers: <MapLayer>[
                MapShapeLayer(
                  loadingBuilder: (BuildContext context) {
                    return const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    );
                  },
                  source: controller.selectionMapSource,
                  zoomPanBehavior: MapZoomPanBehavior(
                    enablePanning: true,
                    enablePinching: true,
                    zoomLevel: 2,
                  ),
                  showDataLabels: true,
                  dataLabelSettings: const MapDataLabelSettings(
                    overflowMode: MapLabelOverflow.hide,
                    textStyle: TextStyle(color: Colors.black, fontSize: 9),
                  ),
                  selectedIndex: controller.selectedIndex,
                  strokeColor: Colors.white30,
                  selectionSettings: MapSelectionSettings(
                    color: contentTheme.primary,
                    strokeWidth: 2,
                  ),

                  // ĐÃ SỬA: Lắng nghe sự kiện click và kích hoạt hàm random từ controller
                  onSelectionChanged: (int index) {
                    setState(() {
                      int newIndex = (index == controller.selectedIndex)
                          ? -1
                          : index;
                      controller.selectedIndex = newIndex;

                      // Gọi hàm xử lý ngẫu nhiên từ file Controller
                      controller.randomizeOverviewData(newIndex);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget latestTransaction() {
    return MyCard(
      shadow: MyShadow(elevation: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("Latest Transaction", fontWeight: 600),
          MySpacing.height(12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 120,
              dataRowMaxHeight: 60,

              columns: [
                DataColumn(
                  label: Theme(
                    data: ThemeData(visualDensity: VisualDensity.compact),
                    child: Checkbox(value: false, onChanged: null),
                  ),
                ),
                DataColumn(
                  label: MyText.titleMedium("ID & Name", fontWeight: 600),
                ),
                DataColumn(label: MyText.titleMedium("Date", fontWeight: 600)),
                DataColumn(label: MyText.titleMedium("Price", fontWeight: 600)),
                DataColumn(
                  label: MyText.titleMedium("Quantity", fontWeight: 600),
                ),
                DataColumn(
                  label: MyText.titleMedium("Amount", fontWeight: 600),
                ),
                DataColumn(
                  label: MyText.titleMedium("Status", fontWeight: 600),
                ),
                DataColumn(
                  label: MyText.titleMedium("Action", fontWeight: 600),
                ),
              ],
              rows: [
                buildTransactionRow(
                  checked: false,
                  avatar: "assets/users/avatar-2.jpg",
                  id: "#AP1234",
                  name: "David Wiley",
                  date: "02 Nov, 2019",
                  price: "\$1,234",
                  quantity: "1",
                  amount: "\$1,234",
                  status: "Confirm",
                  statusColor: Colors.green,
                ),
                buildTransactionRow(
                  checked: false,
                  avatarText: "W",
                  id: "#AP1235",
                  name: "Walter Jones",
                  date: "04 Nov, 2019",
                  price: "\$822",
                  quantity: "2",
                  amount: "\$1,644",
                  status: "Confirm",
                  statusColor: Colors.green,
                ),
                buildTransactionRow(
                  checked: false,
                  avatar: "assets/users/avatar-3.jpg",
                  id: "#AP1236",
                  name: "Eric Ryder",
                  date: "05 Nov, 2019",
                  price: "\$1,153",
                  quantity: "1",
                  amount: "\$1,153",
                  status: "Cancel",
                  statusColor: Colors.red,
                ),
                buildTransactionRow(
                  checked: false,
                  avatar: "assets/users/avatar-6.jpg",
                  id: "#AP1237",
                  name: "Kenneth Jackson",
                  date: "06 Nov, 2019",
                  price: "\$1,365",
                  quantity: "1",
                  amount: "\$1,365",
                  status: "Confirm",
                  statusColor: Colors.green,
                ),
                buildTransactionRow(
                  checked: false,
                  avatarText: "R",
                  id: "#AP1238",
                  name: "Ronnie Spiller",
                  date: "08 Nov, 2019",
                  price: "\$740",
                  quantity: "2",
                  amount: "\$1,480",
                  status: "Pending",
                  statusColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow buildTransactionRow({
    required bool checked,
    String? avatar,
    String? avatarText,
    required String id,
    required String name,
    required String date,
    required String price,
    required String quantity,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Theme(
            data: ThemeData(visualDensity: VisualDensity.compact),
            child: Checkbox(value: checked, onChanged: (_) {}),
          ),
        ),
        DataCell(
          Row(
            children: [
              avatar != null
                  ? CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage(avatar),
                    )
                  : CircleAvatar(
                      radius: 16,
                      backgroundColor: contentTheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      child: MyText.bodyMedium(
                        avatarText ?? "?",
                        color: contentTheme.primary,
                        fontWeight: 600,
                      ),
                    ),
              MySpacing.width(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText.bodyMedium(id, fontSize: 12),
                  MyText.bodyMedium(name, fontSize: 15, fontWeight: 600),
                ],
              ),
            ],
          ),
        ),

        DataCell(MyText.bodyMedium(date)),
        DataCell(MyText.bodyMedium(price)),
        DataCell(MyText.bodyMedium(quantity)),
        DataCell(MyText.bodyMedium(amount)),
        DataCell(
          Row(
            children: [
              Icon(Icons.circle, size: 12, color: statusColor),
              MySpacing.width(4),
              MyText.bodyMedium(status),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(50, 30),
                  side: BorderSide(color: contentTheme.success),
                ),
                onPressed: () {},
                child: MyText.bodyMedium("Edit"),
              ),
              MySpacing.width(6),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(60, 30),
                  overlayColor: contentTheme.danger,
                  side: BorderSide(color: contentTheme.danger),
                ),
                onPressed: () {},
                child: MyText.labelMedium("Cancel"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
