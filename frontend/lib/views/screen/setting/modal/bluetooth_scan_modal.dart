import 'dart:async';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/services/printer/print_service.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_modal.dart';
import 'package:remixicon/remixicon.dart';

class PrinterDeviceItem {
  final String name;
  final String macOrId;

  PrinterDeviceItem({required this.name, required this.macOrId});
}

class BluetoothScanModal extends StatefulWidget {
  const BluetoothScanModal({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const BluetoothScanModal(),
    );
  }

  @override
  State<BluetoothScanModal> createState() => _BluetoothScanModalState();
}

class _BluetoothScanModalState extends State<BluetoothScanModal> {
  List<PrinterDeviceItem> _devices = [];
  PrinterDeviceItem? _selectedDevice;
  bool _isConnected = false;
  bool _isLoading = false;
  String _connectingMac = "";
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    if (Platform.isIOS) {
      ble.FlutterBluePlus.stopScan();
    }
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    setState(() => _isLoading = true);

    try {
      // 1. Kiểm tra quyền trên Android
      if (Platform.isAndroid) {
        bool hasPermission = await PrintService.requestBluetoothPermissions();
        if (!hasPermission) {
          if (mounted) _showPermissionDialog();
          return;
        }
      }

      // 2. Khôi phục máy in đã lưu & trạng thái kết nối
      bool isConnected = await PrintBluetoothThermal.connectionStatus;
      final savedMac = await PrintService.getBluetoothMac();

      if (savedMac != null && savedMac.isNotEmpty) {
        final savedDevice = PrinterDeviceItem(
          name: "Máy in đã lưu",
          macOrId: savedMac,
        );

        setState(() {
          _devices.add(savedDevice);
          if (isConnected) {
            _selectedDevice = savedDevice;
            _isConnected = true;
          }
        });
      }

      // 3. Lấy danh sách máy in
      await _getDevices();

      // 4. Trên Android: Nếu danh sách máy in trống (chưa ghép nối máy in nào), mở popup gợi ý vào Cài đặt Bluetooth
      if (Platform.isAndroid && _devices.isEmpty && mounted) {
        _showOpenBluetoothSettingsDialog();
      }
    } catch (e) {
      debugPrint("Lỗi khởi tạo Bluetooth: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// MỞ TRỰC TIẾP TRANG CÀI ĐẶT BLUETOOTH TRÊN ANDROID
  Future<void> _openSystemBluetoothSettings() async {
    if (Platform.isAndroid) {
      try {
        const intent = AndroidIntent(
          action: 'android.settings.BLUETOOTH_SETTINGS',
        );
        await intent.launch();
      } catch (e) {
        debugPrint("Không thể mở Cài đặt Bluetooth: $e");
        await openAppSettings();
      }
    }
  }

  /// DIALOG HỎI NGƯỜI DÙNG MỞ CÀI ĐẶT BLUETOOTH TRÊN ANDROID
  void _showOpenBluetoothSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chưa có máy in ghép nối"),
        content: const Text(
          "Ứng dụng chưa tìm thấy máy in nào. Vui lòng mở Cài đặt Bluetooth của điện thoại để ghép nối (Pair) máy in trước.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openSystemBluetoothSettings();
            },
            child: const Text("Mở Cài đặt Bluetooth"),
          ),
        ],
      ),
    );
  }

  /// QUÉT VÀ LẤY MÁY IN
  Future<void> _getDevices() async {
    setState(() => _isLoading = true);

    await _scanSubscription?.cancel();

    try {
      if (Platform.isIOS) {
        // --- GIỮ NGUYÊN HOÀN TOÀN LOGIC XỬ LÝ TRÊN IOS ---
        if (await ble.FlutterBluePlus.isSupported == false) {
          debugPrint("Bluetooth không hỗ trợ trên thiết bị này");
          return;
        }

        _scanSubscription = ble.FlutterBluePlus.scanResults.listen((results) {
          if (!mounted) return;

          for (ble.ScanResult r in results) {
            final deviceName = r.device.platformName.isNotEmpty
                ? r.device.platformName
                : r.advertisementData.advName;

            if (deviceName.isNotEmpty) {
              final macOrId = r.device.remoteId.str;
              final index = _devices.indexWhere((d) => d.macOrId == macOrId);

              setState(() {
                if (index != -1) {
                  _devices[index] = PrinterDeviceItem(
                    name: deviceName,
                    macOrId: macOrId,
                  );
                  if (_selectedDevice?.macOrId == macOrId) {
                    _selectedDevice = _devices[index];
                  }
                } else {
                  _devices.add(
                    PrinterDeviceItem(name: deviceName, macOrId: macOrId),
                  );
                }
              });
            }
          }
        });

        await ble.FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 4),
        );
        await Future.delayed(const Duration(seconds: 4));
      } else {
        // --- XỬ LÝ TRÊN ANDROID: LẤY CÁC THIẾT BỊ ĐÃ GHÉP NỐI (PAIRED) ---
        final List<BluetoothInfo> bondedDevices =
            await PrintBluetoothThermal.pairedBluetooths;

        setState(() {
          for (var d in bondedDevices) {
            final mac = d.macAdress;
            final name = d.name.isNotEmpty ? d.name : "Máy in Bluetooth";
            final index = _devices.indexWhere((item) => item.macOrId == mac);

            if (index != -1) {
              _devices[index] = PrinterDeviceItem(name: name, macOrId: mac);
              if (_selectedDevice?.macOrId == mac) {
                _selectedDevice = _devices[index];
              }
            } else {
              _devices.add(PrinterDeviceItem(name: name, macOrId: mac));
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Lỗi quét Bluetooth: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cần cấp quyền Bluetooth"),
        content: const Text(
          "Ứng dụng cần quyền Bluetooth để tìm và kết nối máy in. Vui lòng bật trong Cài đặt.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              _getDevices();
              Navigator.pop(context);
            },
            child: const Text("Bỏ qua nếu đã cấp quyền"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Mở Cài đặt ứng dụng"),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleConnect(PrinterDeviceItem device) async {
    setState(() => _connectingMac = device.macOrId);

    try {
      if (_isConnected && _selectedDevice?.macOrId == device.macOrId) {
        await PrintBluetoothThermal.disconnect;
        await PrintService.saveBluetoothMac("");
        setState(() {
          _isConnected = false;
          _selectedDevice = null;
        });
      } else {
        bool connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: device.macOrId,
        );

        if (connected) {
          bool actualStatus = await PrintBluetoothThermal.connectionStatus;
          if (actualStatus) {
            await PrintService.saveBluetoothMac(device.macOrId);
          }

          setState(() {
            _isConnected = actualStatus;
            _selectedDevice = device;
          });

          if (mounted) {
            MyBannerNotification.show(
              context,
              title: actualStatus ? "Thành công!" : "Lỗi!",
              message: actualStatus
                  ? "Kết nối thành công với ${device.name}"
                  : "Kết nối không ổn định!",
              type: actualStatus ? BannerType.success : BannerType.error,
            );
          }
        } else {
          if (mounted) {
            MyBannerNotification.show(
              context,
              title: "Lỗi!",
              message: "Kết nối thất bại tới ${device.name}!",
              type: BannerType.error,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi kết nối: $e");
    } finally {
      if (mounted) setState(() => _connectingMac = "");
    }
  }

  Future<void> _printTestTicket() async {
    if (!await PrintBluetoothThermal.connectionStatus) {
      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Lỗi!",
          message: "Máy in hiện chưa kết nối!",
          type: BannerType.error,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await PrintService.printTestConnection(
        deviceName: _selectedDevice?.name,
        macAddress: _selectedDevice?.macOrId,
      );

      if (mounted) {
        MyBannerNotification.show(
          context,
          title: success ? "Thành công!" : "Thất bại!",
          message: success
              ? "Đã in phiếu thử thành công!"
              : "Gửi lệnh in thất bại!",
          type: success ? BannerType.success : BannerType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Lỗi!",
          message: "Lỗi in thử: $e",
          type: BannerType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onClose() {
    if (_isConnected && _selectedDevice != null) {
      Navigator.of(
        context,
      ).pop("${_selectedDevice!.name} (${_selectedDevice!.macOrId})");
    } else {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return MyModal(
      title: "TÌM MÁY IN BLUETOOTH",
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyText.bodySmall(
                    Platform.isIOS
                        ? "THIẾT BỊ DÒ TÌM ĐƯỢC (iOS)"
                        : "DANH SÁCH MÁY IN ĐÃ GHÉP NỐI",
                    fontWeight: 700,
                    color: contentTheme.cardTextMuted,
                  ),
                ),
                Row(
                  children: [
                    if (Platform.isAndroid) ...[
                      InkWell(
                        onTap: _openSystemBluetoothSettings,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Row(
                            children: [
                              Icon(
                                RemixIcons.bluetooth_line,
                                color: contentTheme.primary,
                                size: 16,
                              ),
                              MySpacing.width(4),
                              MyText.bodySmall(
                                "Cài đặt Bluetooth",
                                color: contentTheme.primary,
                                fontWeight: 600,
                              ),
                            ],
                          ),
                        ),
                      ),
                      MySpacing.width(8),
                    ],
                    IconButton(
                      icon: Icon(
                        RemixIcons.refresh_line,
                        color: contentTheme.primary,
                        size: 20,
                      ),
                      onPressed: _getDevices,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            MySpacing.height(8),

            if (Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: MyText.bodySmall(
                  "* Vui lòng ghép nối máy in trong Cài đặt Bluetooth trước, sau đó bấm nút Làm mới.",
                  color: Colors.orange.shade700,
                  fontSize: 11,
                ),
              ),

            if (_isLoading) ...[
              LinearProgressIndicator(
                color: contentTheme.primary,
                backgroundColor: contentTheme.primary.withOpacity(0.2),
                minHeight: 2,
              ),
              MySpacing.height(8),
            ],

            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: _devices.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyText.bodyMedium(
                              _isLoading
                                  ? "Đang tải danh sách..."
                                  : "Chưa có thiết bị nào trong danh sách.",
                              textAlign: TextAlign.center,
                              color: contentTheme.onBackground.withOpacity(0.6),
                            ),
                            if (Platform.isAndroid && !_isLoading) ...[
                              MySpacing.height(12),
                              ElevatedButton.icon(
                                onPressed: _openSystemBluetoothSettings,
                                icon: const Icon(
                                  RemixIcons.bluetooth_line,
                                  size: 18,
                                ),
                                label: const Text("Mở Cài đặt Bluetooth"),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        final isCurrentConnected =
                            _isConnected &&
                            _selectedDevice?.macOrId == device.macOrId;
                        final isConnectingThis =
                            _connectingMac == device.macOrId;

                        return MyContainer(
                          onTap: () => _toggleConnect(device),
                          margin: const EdgeInsets.only(bottom: 8.0),
                          padding: MySpacing.all(12),
                          borderRadiusAll: 8,
                          color: contentTheme.cardBackground,
                          bordered: true,
                          borderColor: isCurrentConnected
                              ? Colors.green
                              : contentTheme.border,
                          child: Row(
                            children: [
                              Icon(
                                RemixIcons.printer_line,
                                color: isCurrentConnected
                                    ? Colors.green
                                    : contentTheme.primary,
                                size: 22,
                              ),
                              MySpacing.width(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.bodyMedium(
                                      device.name,
                                      fontWeight: 600,
                                      color: contentTheme.onBackground,
                                    ),
                                    MyText.bodySmall(
                                      "ID/MAC: ${device.macOrId}",
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                              if (isConnectingThis)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrentConnected
                                        ? Colors.green.withOpacity(0.1)
                                        : contentTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: MyText.bodySmall(
                                    isCurrentConnected
                                        ? "Đã kết nối"
                                        : "Kết nối",
                                    fontWeight: 600,
                                    color: isCurrentConnected
                                        ? Colors.green
                                        : contentTheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      customActions: [
        Expanded(
          child: Row(
            children: [
              if (_isConnected) ...[
                Expanded(
                  child: MyContainer(
                    onTap: _printTestTicket,
                    color: contentTheme.primary,
                    padding: MySpacing.xy(16, 10),
                    borderRadiusAll: 12,
                    child: Center(
                      child: MyText.bodyMedium(
                        "In thử",
                        fontWeight: 600,
                        color: contentTheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                MySpacing.width(12),
              ],
              Expanded(
                child: MyContainer(
                  onTap: _onClose,
                  color: contentTheme.danger,
                  padding: MySpacing.xy(16, 10),
                  borderRadiusAll: 12,
                  child: Center(
                    child: MyText.bodyMedium(
                      "Đóng",
                      fontWeight: 600,
                      color: contentTheme.onDanger,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
