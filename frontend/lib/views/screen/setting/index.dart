import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/theme/theme_customizer.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/services/printer/print_service.dart';
import 'package:qr_app/views/layout/app_scaffold.dart';
import 'package:qr_app/views/layout/top_bar.dart';
import 'package:qr_app/views/screen/qr_scanner_screen.dart';
import 'package:qr_app/views/screen/setting/modal/bluetooth_scan_modal.dart';
import 'package:qr_app/views/screen/setting/modal/setting_ip_printer_modal.dart';
import 'package:remixicon/remixicon.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isScanModeEnabled = false;
  String? _scannedResult;
  String? _selectedBluetoothDevice;
  String? _configuredIpPrinter;

  @override
  void initState() {
    super.initState();
    _initPrinterSettings();
  }

  /// Đọc thông tin cấu hình máy in đã lưu bất đồng bộ
  Future<void> _initPrinterSettings() async {
    final btDevice = await PrintService.connectedBluetoothDevice;
    final ip = await PrintService.zebraPrinterIp;
    final port = await PrintService.zebraPrinterPort;

    if (mounted) {
      setState(() {
        _selectedBluetoothDevice = btDevice;
        if (ip.isNotEmpty) {
          _configuredIpPrinter = "$ip:$port";
        }
      });
    }
  }

  Future<void> _openQRScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _scannedResult = result;
      });
    }
  }

  Future<void> _openBluetoothScanner() async {
    // BluetoothScanModal trả về định dạng Map {name: ..., mac: ...} hoặc chuỗi kết quả
    final result = await BluetoothScanModal.show(context);

    if (result != null) {
      // Đọc thông tin cài đặt mới
      await _initPrinterSettings();
    }
  }

  Future<void> _openIpPrinterSetting() async {
    final result = await SettingIpPrinterModal.show(context);

    if (result != null) {
      if (mounted) {
        setState(() {
          _configuredIpPrinter = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (context, notifier, child) {
        final contentTheme = AdminTheme.theme.contentTheme;
        final isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;

        return AppScaffold(
          isScrollable: true,
          bodyBuilder: (context, openDrawer) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(title: "Cài đặt", showBackButton: true, actions: []),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Mở Camera Quét Mã QR
                      // Card(
                      //   elevation: 0.5,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: ListTile(
                      //     titleAlignment: ListTileTitleAlignment.center,
                      //     leading: Icon(
                      //       RemixIcons.qr_scan_2_line,
                      //       color: contentTheme.primary,
                      //     ),
                      //     title: MyText.bodyMedium(
                      //       "Mở Camera Quét Mã QR",
                      //       fontWeight: 600,
                      //       color: contentTheme.onBackground,
                      //     ),
                      //     subtitle: MyText.bodySmall(
                      //       "Chạm vào đây để khởi động quét mã",
                      //       color: Colors.grey,
                      //     ),
                      //     trailing: const Icon(RemixIcons.arrow_right_s_line),
                      //     onTap: _openQRScanner,
                      //   ),
                      // ),
                      // MySpacing.height(8),

                      // 2. Card Hiển thị Kết quả Quét QR
                      // if (_scannedResult != null) ...[
                      //   Card(
                      //     color: contentTheme.primary.withOpacity(0.1),
                      //     elevation: 0.5,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(16.0),
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Row(
                      //             children: [
                      //               Icon(
                      //                 RemixIcons.checkbox_circle_line,
                      //                 color: contentTheme.primary,
                      //               ),
                      //               MySpacing.width(8),
                      //               MyText.bodyMedium(
                      //                 "Kết quả quét mã:",
                      //                 fontWeight: 700,
                      //                 color: contentTheme.primary,
                      //               ),
                      //             ],
                      //           ),
                      //           MySpacing.height(8),
                      //           SelectableText(
                      //             _scannedResult!,
                      //             style: TextStyle(
                      //               fontSize: 15,
                      //               fontWeight: FontWeight.w500,
                      //               color: contentTheme.onBackground,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      //   MySpacing.height(8),
                      // ],

                      // 3. Card Quét Thiết Bị Bluetooth
                      Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          titleAlignment: ListTileTitleAlignment.center,
                          leading: Icon(
                            RemixIcons.bluetooth_line,
                            color: contentTheme.onBackground,
                          ),
                          title: MyText.bodyMedium(
                            "Tìm kiếm thiết bị Bluetooth",
                            fontWeight: 600,
                            color: contentTheme.onBackground,
                          ),
                          subtitle: MyText.bodySmall(
                            _selectedBluetoothDevice ??
                                "Đang chọn: Chưa chọn thiết bị nào",
                            color: _selectedBluetoothDevice != null
                                ? contentTheme.onBackground
                                : Colors.grey,
                          ),
                          trailing: const Icon(RemixIcons.arrow_right_s_line),
                          onTap: _openBluetoothScanner,
                        ),
                      ),
                      MySpacing.height(8),

                      // 4. Card Cấu hình Máy in IP (Zebra)
                      Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          titleAlignment: ListTileTitleAlignment.center,
                          leading: Icon(
                            RemixIcons.printer_line,
                            color: contentTheme.onBackground,
                          ),
                          title: MyText.bodyMedium(
                            "Cấu hình máy in IP (Zebra)",
                            fontWeight: 600,
                            color: contentTheme.onBackground,
                          ),
                          subtitle: MyText.bodySmall(
                            _configuredIpPrinter != null
                                ? "Đã cấu hình: $_configuredIpPrinter"
                                : "Chưa cấu hình địa chỉ IP máy in",
                            color: _configuredIpPrinter != null
                                ? contentTheme.onBackground
                                : Colors.grey,
                          ),
                          trailing: const Icon(RemixIcons.arrow_right_s_line),
                          onTap: _openIpPrinterSetting,
                        ),
                      ),
                      MySpacing.height(8),

                      // 5. Switch Chế độ quét
                      // Card(
                      //   elevation: 0.5,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: SwitchListTile(
                      //   titleAlignment: ListTileTitleAlignment.center,
                      //     value: _isScanModeEnabled,
                      //     activeColor: Theme.of(context).primaryColor,
                      //     secondary: Icon(
                      //       RemixIcons.settings_4_line,
                      //       color: contentTheme.onBackground,
                      //     ),
                      //     title: MyText.bodyMedium(
                      //       "Cài đặt chế độ quét tự động",
                      //       fontWeight: 600,
                      //       color: contentTheme.onBackground,
                      //     ),
                      //     onChanged: (bool value) {
                      //       setState(() {
                      //         _isScanModeEnabled = value;
                      //       });
                      //     },
                      //   ),
                      // ),
                      // MySpacing.height(8),

                      // 6. Switch Theme
                      Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SwitchListTile(
                          value: isDark,
                          activeColor: Theme.of(context).primaryColor,
                          secondary: Icon(
                            isDark ? RemixIcons.sun_line : RemixIcons.moon_line,
                            color: contentTheme.onBackground,
                          ),
                          title: MyText.bodyMedium(
                            "Chế độ sáng / tối",
                            fontWeight: 600,
                            color: contentTheme.onBackground,
                          ),
                          onChanged: (bool value) {
                            final newTheme = value
                                ? ThemeMode.dark
                                : ThemeMode.light;

                            ThemeCustomizer.setTheme(newTheme);
                            AdminTheme.setTheme();
                            Get.changeThemeMode(newTheme);

                            Provider.of<AppNotifier>(
                              context,
                              listen: false,
                            ).notifyListeners();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
