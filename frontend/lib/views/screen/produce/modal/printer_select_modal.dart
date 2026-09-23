import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/services/printer/print_service.dart';
import 'package:qr_app/services/printer/printer_model.dart';
import 'package:qr_app/views/screen/setting/index.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_dropdown.dart';
import 'package:qr_app/widgets/my_modal.dart';
import 'package:remixicon/remixicon.dart';

class SelectPrinterModal extends StatefulWidget {
  const SelectPrinterModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SelectPrinterModal(),
    );
  }

  @override
  State<SelectPrinterModal> createState() => _SelectPrinterModalState();
}

class _SelectPrinterModalState extends State<SelectPrinterModal> {
  bool _isChecking = true;
  bool _isPrinting = false;

  List<String> _availablePrinters = [];
  final List<String> _templateTypes = ["Tem nội bộ", "Tem thương mại"];

  String? _selectedPrinter;
  String _selectedTemplate = "Tem nội bộ";

  bool get _isZebraPrinter => _selectedPrinter == "IP Zebra ZT410";

  @override
  void initState() {
    super.initState();
    _checkPrinterConnections();
  }

  Future<void> _checkPrinterConnections() async {
    setState(() => _isChecking = true);
    final List<String> detectedPrinters = [];

    // 1. Kiểm tra Bluetooth Unitech
    final isBluetoothConnected =
        await PrintService.checkBluetoothPrinterConnected();
    if (isBluetoothConnected) {
      final deviceName = await PrintService.connectedBluetoothDevice;
      detectedPrinters.add(deviceName ?? "Bluetooth Unitech SP320");
    }

    // 2. Kiểm tra IP Zebra ZT410
    final isZebraConnected = await PrintService.checkZebraPrinterConnected();
    if (isZebraConnected) {
      detectedPrinters.add("IP Zebra ZT410");
    }

    if (mounted) {
      setState(() {
        _availablePrinters = detectedPrinters;
        _selectedPrinter = _availablePrinters.isNotEmpty
            ? _availablePrinters.first
            : null;
        _isChecking = false;
      });
    }
  }

  /// CHUẨN HÓA LẠI TÊN CÁC KEY TRONG MOCK DATA
  /// Mock Data cho Tem Nhận Diện / Tem Nội Bộ
  Map<String, dynamic> _getMockPrintData() {
    return {
      'NSX': '2026-09-21T00:00:00.000',
      'HSD': '2027-09-21T00:00:00.000',
      'lSX': 'LSX-998822',
      'sCT': 'CT-001',
      'sTTCuon': '01',
      'netweight': 'MjUuMA==', // Base64 mã hóa chuỗi "25.0"
      'grossweight': 'MjUuNQ==', // Base64 mã hóa chuỗi "25.5"
      'khachHang': 'CÔNG TY TNHH ABC CÔNG TY TNHH ABC ád dsdsa 123 123123  123',
      'may': 'Máy 01',
      'quyCach': '50mm x 30mm 50mm x 30mm 50mm x 30mm 50mm x 30mm',
      'maVT': '01.0000012',
      'qRCode': 'LSX-998822|CT-001|25.0',
    };
  }

  /// Mock Data cho Tem Thương Mại (NEW)
  Map<String, dynamic> _getMockCommercialData() {
    return {
      "NSX": "Công Ty TNHH Bao Bì Tấn Phong Bao Bì Tấn Phong",
      "addressCompany": "284/1 Hòa Bình, Phường Phú Thạnh, TP.Hồ Chí Minh",
      "ngaySx": "2026-04-01T00:00:00.000",
      "hsd": "3 năm từ NSX",
      "LSX": "LSX2601.0001",
      "SoLo": "LSX2601.0001",
      "refNbr": "001",
      "netweight": 100,
      "grossweight": 102,
      "khachHang": "-",
      "maMay": "",
      "tenMay": "",
      "quyCach": "-",
      "tenHang": "01.000021- Bao HDPE Bao HDPE 123 1234 123 1234",
      "moTa": "B......",
      "XuatXu": "Việt Nam",
      "BaoQuan": "Nơi khô thoáng Nơi khô thoáng Nơi khô thoáng",
      "CanhBao": "Tránh nhiệt độ cao Tránh nhiệt độ cao Tránh nhiệt độ cao",
      "qrCode": "https://tanphongpack.com",
    };
  }

  Future<void> _handleExecutePrint() async {
    if (_selectedPrinter == null) {
      MyBannerNotification.show(
        context,
        title: "Lỗi",
        message: "Vui lòng chọn máy in!",
        type: BannerType.error,
      );
      return;
    }

    setState(() => _isPrinting = true);
    bool success = false;

    try {
      if (_isZebraPrinter) {
        // --- XỬ LÝ MÁY IN ZEBRA (ZPL - IP) ---
        if (_selectedTemplate == "Tem nội bộ") {
          final dummyData = _getMockPrintData();
          final internalItem = PrintInternalTicketItem.fromJson(dummyData);

          success = await PrintService.printInternalLabelZebra(internalItem);
        } else {
          // In Tem Thương Mại qua Zebra IP
          final commercialData = _getMockCommercialData();
          final commercialItem = PrintCommercialTicketItem.fromJson(
            commercialData,
          );

          success = await PrintService.printCommercialLabelZebra(
            commercialItem,
          );
        }
      } else {
        // --- XỬ LÝ MÁY IN BLUETOOTH UNITECH SP320 (CPCL) ---
        if (_selectedTemplate == "Tem nội bộ") {
          final dummyData = _getMockPrintData();
          final internalItem = PrintInternalTicketItem.fromJson(dummyData);

          success = await PrintService.printInternalLabel(internalItem);
        } else {
          // In Tem Thương Mại qua Bluetooth SP320
          final commercialData = _getMockCommercialData();
          final commercialItem = PrintCommercialTicketItem.fromJson(
            commercialData,
          );

          success = await PrintService.printCommercialLabel(commercialItem);
        }
      }

      if (mounted) {
        MyBannerNotification.show(
          context,
          title: success ? "Thành công!" : "Lỗi!",
          message: success ? "In thành công!" : "Lỗi khi gửi lệnh tới máy in!",
          type: success ? BannerType.success : BannerType.error,
        );
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi thực thi lệnh in: $e");
      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Lỗi!",
          message: "Có lỗi xảy ra: $e",
          type: BannerType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  void _navigateToSettings() {
    Get.back();
    Get.to(() => const SettingScreen());
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return MyModal(
      title: "CẤU HÌNH IN",
      content: _isChecking
          ? SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(color: contentTheme.primary),
              ),
            )
          : _availablePrinters.isEmpty
          ? _buildNoPrinterState(contentTheme)
          : _buildPrinterConfigForm(contentTheme),
      customActions: [
        Expanded(
          child: Row(
            children: [
              if (_availablePrinters.isNotEmpty) ...[
                Expanded(
                  child: MyContainer(
                    onTap: _isPrinting ? null : _handleExecutePrint,
                    color: _isPrinting
                        ? contentTheme.primary.withOpacity(0.6)
                        : contentTheme.primary,
                    padding: MySpacing.xy(16, 10),
                    borderRadiusAll: 12,
                    child: Center(
                      child: _isPrinting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: contentTheme.onPrimary,
                              ),
                            )
                          : MyText.bodyMedium(
                              "Thực hiện IN",
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
                  onTap: _navigateToSettings,
                  color: contentTheme.secondary,
                  padding: MySpacing.xy(16, 10),
                  borderRadiusAll: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        RemixIcons.settings_3_line,
                        size: 18,
                        color: contentTheme.onSecondary,
                      ),
                      MySpacing.width(6),
                      MyText.bodyMedium(
                        "Cài đặt",
                        fontWeight: 600,
                        color: contentTheme.onSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoPrinterState(dynamic contentTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MySpacing.height(12),
        Icon(
          RemixIcons.printer_cloud_line,
          size: 48,
          color: contentTheme.danger,
        ),
        MySpacing.height(12),
        MyText.bodyMedium(
          "Chưa phát hiện thiết bị máy in nào!",
          fontWeight: 600,
          color: contentTheme.onBackground,
          textAlign: TextAlign.center,
        ),
        MySpacing.height(4),
        MyText.bodySmall(
          "Vui lòng kết nối máy in Bluetooth hoặc thiết lập IP máy in Zebra trong phần Cài đặt.",
          color: contentTheme.cardTextMuted,
          textAlign: TextAlign.center,
        ),
        MySpacing.height(12),
      ],
    );
  }

  Widget _buildPrinterConfigForm(dynamic contentTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodySmall(
          "MÁY IN",
          fontWeight: 700,
          color: contentTheme.cardTextMuted,
        ),
        MySpacing.height(6),
        MyDropdown<String>(
          items: _availablePrinters
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          value: _selectedPrinter,
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedPrinter = val;
              });
            }
          },
        ),
        MySpacing.height(14),
        MyText.bodySmall(
          "MẪU IN",
          fontWeight: 700,
          color: contentTheme.cardTextMuted,
        ),
        MySpacing.height(6),
        MyDropdown<String>(
          items: _templateTypes
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          value: _selectedTemplate,
          onChanged: (val) {
            if (val != null) setState(() => _selectedTemplate = val);
          },
        ),
      ],
    );
  }
}
