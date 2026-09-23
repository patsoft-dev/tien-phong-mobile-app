import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_app/services/printer/printer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cpcl_ticket_service.dart';
import 'zpl_ticket_service.dart';

class PrintService {
  // Key lưu trữ SharedPreferences
  static const String _keyBluetoothName = "bluetooth_printer_name";
  static const String _keyBluetoothMac = "bluetooth_printer_mac";
  static const String _keyZebraIp = 'zebra_printer_ip';
  static const String _keyZebraPort = 'zebra_printer_port';

  /// Khởi tạo cấu hình ban đầu
  static Future<void> initPrintService() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyZebraIp)) {
      await prefs.setString(_keyZebraIp, '');
    }
    if (!prefs.containsKey(_keyZebraPort)) {
      await prefs.setInt(_keyZebraPort, 9100);
    }
  }

  // ==========================================
  // QUẢN LÝ CẤU HÌNH BLUETOOTH & IP
  // ==========================================

  static Future<void> saveBluetoothName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBluetoothName, name);
  }

  static Future<String?> getBluetoothName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBluetoothName);
  }

  static Future<void> saveBluetoothMac(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBluetoothMac, mac);
  }

  static Future<String?> getBluetoothMac() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBluetoothMac);
  }

  static Future<String?> get savedBluetoothMac async => getBluetoothMac();

  static Future<String?> get connectedBluetoothDevice async =>
      getBluetoothName();

  static Future<void> saveConnectedBluetoothDevice(
    String name,
    String mac,
  ) async {
    await saveBluetoothName(name);
    await saveBluetoothMac(mac);
  }

  static Future<void> saveZebraConfig(String ip, int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyZebraIp, ip);
    await prefs.setInt(_keyZebraPort, port);
  }

  static Future<String> get zebraPrinterIp async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyZebraIp) ?? '192.168.1.100';
  }

  static Future<int> get zebraPrinterPort async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyZebraPort) ?? 9100;
  }

  // ==========================================
  // BẢO MẬT & KIỂM TRA KẾT NỐI MÁY IN
  // ==========================================

  /// Xin quyền Bluetooth
  static Future<bool> requestBluetoothPermissions() async {
    if (Platform.isIOS) {
      // 1. Kiểm tra trạng thái hiện tại trên iOS
      var status = await Permission.bluetooth.status;
      if (status.isGranted) return true;

      // 2. Nếu chưa có mới xin
      status = await Permission.bluetooth.request();
      return status.isGranted;
    }

    if (Platform.isAndroid) {
      // Trên Android, kiểm tra 2 quyền cốt lõi nhất từ Android 12 (API 31+)
      var scanStatus = await Permission.bluetoothScan.status;
      var connectStatus = await Permission.bluetoothConnect.status;

      // Nếu cả 2 quyền quét và kết nối đã được cấp -> Trả về true ngay lập tức
      if (scanStatus.isGranted && connectStatus.isGranted) {
        return true;
      }

      // Nếu chưa được cấp, mới tiến hành request
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      bool isScanOk = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      bool isConnectOk =
          statuses[Permission.bluetoothConnect]?.isGranted ?? false;

      // Nếu máy chạy Android cũ (< Android 12), bluetoothScan/bluetoothConnect sẽ tự động pass,
      // lúc này mới cần fallback kiểm tra Permission.bluetooth cũ
      if (!isScanOk && !isConnectOk) {
        var legacyBt = await Permission.bluetooth.status;
        if (legacyBt.isGranted) return true;

        var legacyReq = await Permission.bluetooth.request();
        return legacyReq.isGranted;
      }

      return isScanOk && isConnectOk;
    }

    return false;
  }

  /// Kiểm tra kết nối Bluetooth (Thực tế & Auto Reconnect)
  static Future<bool> checkBluetoothPrinterConnected() async {
    try {
      bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (isConnected) return true;

      final savedMac = await getBluetoothMac();
      if (savedMac != null && savedMac.isNotEmpty) {
        bool reconnected = await PrintBluetoothThermal.connect(
          macPrinterAddress: savedMac,
        );
        return reconnected;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi kiểm tra kết nối Bluetooth: $e");
      return false;
    }
  }

  /// Kiểm tra máy in Zebra kết nối qua IP
  static Future<bool> checkZebraPrinterConnected() async {
    Socket? socket;
    try {
      final ip = await zebraPrinterIp;
      final port = await zebraPrinterPort;

      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 2),
      );
      await socket.close();
      return true;
    } catch (_) {
      socket?.destroy();
      return false;
    }
  }

  // ==========================================
  // EXECUTOR IN THỬ & IN NHÃN TỰ ĐỘNG
  // ==========================================

  /// In thử kết nối Bluetooth (CPCL Test)
  static Future<bool> printTestConnection({
    String? deviceName,
    String? macAddress,
  }) async {
    try {
      bool isConnected = await checkBluetoothPrinterConnected();
      if (!isConnected) {
        debugPrint("❌ Máy in Bluetooth chưa được kết nối!");
        return false;
      }

      final String name = deviceName ?? 'Unitech SP320';
      final String cpclCommand =
          "! 0 200 200 200 1\r\n"
          "PAGE-WIDTH 400\r\n"
          "TEXT 4 0 20 20 TEST PRINT OK\r\n"
          "TEXT 7 0 20 70 Device: $name\r\n"
          "FORM\r\n"
          "PRINT\r\n";

      List<int> bytes = List<int>.from(utf8.encode(cpclCommand));
      bool result = await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint("--> Kết quả gửi lệnh in thử: $result");
      return result;
    } catch (e) {
      debugPrint("❌ Lỗi ngoại lệ khi in thử: $e");
      return false;
    }
  }

  /// In tem nhận diện Bluetooth (CPCL)
  static Future<bool> printInternalLabel(PrintInternalTicketItem item) async {
    try {
      bool isConnected = await checkBluetoothPrinterConnected();
      if (!isConnected) {
        debugPrint("❌ Máy in Bluetooth chưa được kết nối!");
        return false;
      }

      List<int> bytes = CpclTicketService.generateInternalCPCLBytes(item);
      bool result = await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint("--> Kết quả gửi lệnh in tem nội bộ (Bluetooth): $result");
      return result;
    } catch (e) {
      debugPrint("❌ Lỗi khi gửi bytes lệnh in CPCL tem nội bộ: $e");
      return false;
    }
  }

  /// In tem thương mại Bluetooth (CPCL)
  static Future<bool> printCommercialLabel(
    PrintCommercialTicketItem item,
  ) async {
    try {
      bool isConnected = await checkBluetoothPrinterConnected();
      if (!isConnected) {
        debugPrint("❌ Máy in Bluetooth chưa được kết nối!");
        return false;
      }

      List<int> bytes = CpclTicketService.generateCommercialCPCLBytes(item);
      bool result = await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint("--> Kết quả gửi lệnh in tem thương mại (Bluetooth): $result");
      return result;
    } catch (e) {
      debugPrint("❌ Lỗi khi gửi bytes lệnh in CPCL tem thương mại: $e");
      return false;
    }
  }

  /// Gửi chuỗi Raw ZPL tới IP
  static Future<bool> sendZplToIP(String zplData) async {
    Socket? socket;
    try {
      final ip = await zebraPrinterIp;
      final port = await zebraPrinterPort;

      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.add(utf8.encode(zplData));
      await socket.flush();
      await socket.close();
      return true;
    } catch (e) {
      debugPrint("❌ Lỗi gửi lệnh IP Zebra: $e");
      socket?.destroy();
      return false;
    }
  }

  /// In Tem Nội Bộ Zebra IP (ZPL)
  static Future<bool> printInternalLabelZebra(
    PrintInternalTicketItem item,
  ) async {
    String zpl = ZplTicketService.generateInternalLabelZPL(item);
    return await sendZplToIP(zpl);
  }

  /// In Tem Thương Mại Zebra IP (ZPL)
  static Future<bool> printCommercialLabelZebra(
    PrintCommercialTicketItem item,
  ) async {
    String zpl = ZplTicketService.generateCommercialLabelZPL(item);
    return await sendZplToIP(zpl);
  }
}
