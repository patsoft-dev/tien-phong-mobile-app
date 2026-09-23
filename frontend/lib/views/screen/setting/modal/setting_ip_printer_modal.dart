import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/services/printer/print_service.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_modal.dart';
import 'package:remixicon/remixicon.dart';

class SettingIpPrinterModal extends StatefulWidget {
  const SettingIpPrinterModal({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingIpPrinterModal(),
    );
  }

  @override
  State<SettingIpPrinterModal> createState() => _SettingIpPrinterModalState();
}

class _SettingIpPrinterModalState extends State<SettingIpPrinterModal> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  bool _isLoading = true;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  /// Khởi tạo dữ liệu bất đồng bộ
  Future<void> _loadCurrentConfig() async {
    final ip = await PrintService.zebraPrinterIp;
    final port = await PrintService.zebraPrinterPort;

    if (mounted) {
      setState(() {
        _ipController.text = ip;
        _portController.text = port.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  /// Hàm kết nối Socket và lấy phản hồi trực tiếp từ máy in qua IP
  Future<Map<String, dynamic>> _testAndGetPrinterResponse(
    String ip,
    int port,
  ) async {
    Socket? socket;
    try {
      // 1. Mở kết nối Socket tới IP & Port (Timeout 3 giây)
      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 3),
      );

      final Completer<String> responseCompleter = Completer<String>();

      // 2. Lắng nghe dữ liệu phản hồi từ máy in
      final subscription = socket.listen(
        (List<int> data) {
          final response = utf8.decode(data, allowMalformed: true);
          if (!responseCompleter.isCompleted) {
            responseCompleter.complete(response);
          }
        },
        onError: (error) {
          if (!responseCompleter.isCompleted) {
            responseCompleter.completeError(error);
          }
        },
      );

      // 3. Gửi lệnh kiểm tra trạng thái Host Status (~HS của Zebra/CPCL)
      socket.add(utf8.encode("~HS\r\n"));
      await socket.flush();

      // 4. Chờ phản hồi trong 2 giây
      String responseData = "";
      try {
        responseData = await responseCompleter.future.timeout(
          const Duration(seconds: 2),
        );
      } catch (_) {
        // Nếu máy in nhận lệnh nhưng không trả lời (chỉ nhận stream 1 chiều), vẫn ghi nhận kết nối TCP thành công
        responseData = "Kết nối cổng IP $port thành công (Sẵn sàng in)";
      }

      await subscription.cancel();
      await socket.close();

      return {
        'success': true,
        'message': responseData.trim().isNotEmpty
            ? responseData.trim()
            : "Kết nối thành công tới máy in!",
      };
    } catch (e) {
      socket?.destroy();
      return {
        'success': false,
        'message': "Không tìm thấy máy in tại $ip:$port. Chi tiết: $e",
      };
    }
  }

  Future<void> _onSave() async {
    final ip = _ipController.text.trim();
    final portStr = _portController.text.trim();
    final port = int.tryParse(portStr) ?? 9100;

    if (ip.isEmpty) {
      MyBannerNotification.show(
        context,
        title: "Cảnh báo!",
        message: "Vui lòng nhập địa chỉ IP máy in!",
        type: BannerType.error,
      );
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    // Thực hiện kiểm tra kết nối và nhận phản hồi từ máy in
    final result = await _testAndGetPrinterResponse(ip, port);

    if (!mounted) return;

    setState(() {
      _isConnecting = false;
    });

    if (result['success'] == true) {
      // Lưu cấu hình vào SharedPreferences nếu kết nối thành công
      await PrintService.saveZebraConfig(ip, port);
      MyBannerNotification.show(
        context,
        title: "Thành công!",
        message: "Đã tìm thấy máy in và kết nối!",
        type: BannerType.success,
      );

      // Đóng Modal sau khi thông báo
      Navigator.of(context).pop("$ip:$port");
    } else {
      MyBannerNotification.show(
        context,
        title: "Lỗi kết nối!",
        message: "${result['message']}",
        type: BannerType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return MyModal(
      title: "CẤU HÌNH MÁY IN IP (ZEBRA/UNITECH)",
      content: _isLoading
          ? SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: contentTheme.primary),
              ),
            )
          : SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodySmall(
                    "ĐỊA CHỈ IP MÁY IN",
                    fontWeight: 700,
                    color: contentTheme.cardTextMuted,
                  ),
                  MySpacing.height(6),
                  TextField(
                    controller: _ipController,
                    enabled: !_isConnecting,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      hintText: "VD: 192.168.1.100",
                      prefixIcon: Icon(
                        RemixIcons.global_line,
                        color: contentTheme.primary,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  MySpacing.height(16),
                  MyText.bodySmall(
                    "CỔNG KẾT NỐI (PORT)",
                    fontWeight: 700,
                    color: contentTheme.cardTextMuted,
                  ),
                  MySpacing.height(6),
                  TextField(
                    controller: _portController,
                    enabled: !_isConnecting,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Mặc định: 9100",
                      prefixIcon: Icon(
                        RemixIcons.router_line,
                        color: contentTheme.primary,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      customActions: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: MyContainer(
                  onTap: _isConnecting
                      ? null
                      : () => Navigator.of(context).pop(),
                  color: contentTheme.danger,
                  padding: MySpacing.xy(16, 10),
                  borderRadiusAll: 12,
                  child: Center(
                    child: MyText.bodyMedium(
                      "Hủy",
                      fontWeight: 600,
                      color: contentTheme.onDanger,
                    ),
                  ),
                ),
              ),
              MySpacing.width(12),
              Expanded(
                child: MyContainer(
                  onTap: (_isLoading || _isConnecting) ? null : _onSave,
                  color: contentTheme.primary,
                  padding: MySpacing.xy(16, 10),
                  borderRadiusAll: 12,
                  child: Center(
                    child: _isConnecting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: contentTheme.onPrimary,
                            ),
                          )
                        : MyText.bodyMedium(
                            "Kiểm tra & Kết nối",
                            fontWeight: 600,
                            color: contentTheme.onPrimary,
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
