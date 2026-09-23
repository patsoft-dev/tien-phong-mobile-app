import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:qr_app/services/printer/printer_model.dart';

/// SERVICE RENDER CPCL CHUẨN MÁY IN UNITECH SP320
class CpclTicketService {
  static const int labelWidthPx = 576;
  static const int labelHeightPx = 500;

  static const int borderLeft = 0;
  static const int borderTop = 10;
  static const int borderRight = 555;
  static const int borderBottom = 380;

  /// Bỏ dấu tiếng Việt bằng RegExp
  static String removeVietnameseAccents(String str) {
    if (str.isEmpty) return str;
    const vietnamese = [
      'aàáạảãâầấậẩẫăằắặẳẵ',
      'eèéẹẻẽêềếệểễ',
      'iìíịỉĩ',
      'oòóọỏõôồốộổỗơờớợởỡ',
      'uùúụủũưừứựửữ',
      'yỳýỵỷỹ',
      'dđ',
      'AÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ',
      'EÈÉẸẺẼÊỀẾỆỂỄ',
      'IÌÍỊỈĨ',
      'OÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ',
      'UÙÚỤỦŨƯỪỨỰỬỮ',
      'YỲÝỴỶỸ',
      'DĐ',
    ];

    for (var group in vietnamese) {
      final baseChar = group[0];
      final regex = RegExp('[${group.substring(1)}]');
      str = str.replaceAll(regex, baseChar);
    }
    return str;
  }

  static List<int> generateInternalCPCLBytes(PrintInternalTicketItem item) {
    String cpclString = formatPrintTicketCPCL(item);
    debugPrint("--> CPCL Command (Tem Nhan Dien):\n$cpclString");
    return List<int>.from(utf8.encode(cpclString));
  }

  static List<int> generateCommercialCPCLBytes(PrintCommercialTicketItem item) {
    String cpclString = formatPrintCommercialTicketCPCL(item);
    debugPrint("--> CPCL Command (Tem Thuong Mai):\n$cpclString");
    return List<int>.from(utf8.encode(cpclString));
  }

  /// FORMAT TEM NHẬN DIỆN (TEM NỘI BỘ)
  static String formatPrintTicketCPCL(PrintInternalTicketItem item) {
    StringBuffer cpcl = StringBuffer();

    _appendHeader(cpcl);

    final headerBottomY = borderTop + 32;
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 5 0 150 ${borderTop + 5} TEM NHAN DIEN");
    cpcl.writeln("SETBOLD 0");

    final qrBoxLeft = 420;
    final qrBoxBottom = headerBottomY + 125;
    cpcl.writeln("LINE $qrBoxLeft $headerBottomY $qrBoxLeft $qrBoxBottom 1");
    cpcl.writeln("LINE $qrBoxLeft $qrBoxBottom $borderRight $qrBoxBottom 1");

    cpcl.writeln("BARCODE QR ${qrBoxLeft + 18} ${headerBottomY + 8} M 2 U 4");
    cpcl.writeln("MA,${item.qRCode}");
    cpcl.writeln("ENDQR");

    final nsxDate = _formatDate(item.NSX);
    final hsdDate = _formatDate(item.HSD);
    final netweightVal = _decodeBase64(item.netweight);
    final grossweightVal = _decodeBase64(item.grossweight);
    final khachHangVal = removeVietnameseAccents(item.khachHang);
    final mayVal = removeVietnameseAccents(item.may);
    final quyCachVal = removeVietnameseAccents(item.quyCach);

    int currentY = headerBottomY + 8;
    const int stepY = 24;
    const int valX = borderLeft + 85;

    // Hàng 1 (Dùng Font 7 chuẩn SP320)
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 6} $currentY NSX:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 55} $currentY $nsxDate");

    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 200} $currentY HSD:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 265} $currentY $hsdDate");

    // Hàng 2
    currentY += stepY;
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 6} $currentY LSX:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln(
      "TEXT 7 0 ${borderLeft + 55} $currentY ${item.LSX} ${item.sttCuon}",
    );

    // Hàng 3
    currentY += stepY;
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 6} $currentY TL Net:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 $valX $currentY $netweightVal kg");

    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 200} $currentY Gross:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 285} $currentY $grossweightVal kg");

    // Hàng 4
    currentY += stepY;
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 6} $currentY Khach Hang:");
    cpcl.writeln("SETBOLD 0");
    currentY = _appendWrappedText(
      cpcl,
      khachHangVal,
      borderLeft + 140,
      currentY,
      22,
    );

    // Hàng 5
    currentY += stepY;
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 6} $currentY May:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 $valX $currentY $mayVal");

    // Hàng 6
    currentY += stepY;
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 6} $currentY ID/Mo ta:");
    cpcl.writeln("SETBOLD 0");
    currentY = _appendWrappedText(
      cpcl,
      "${item.maVT} - $quyCachVal",
      borderLeft + 135,
      currentY,
      30,
    );

    final int dynamicFooterY = (currentY + 28 > 205) ? (currentY + 28) : 205;

    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 15} $dynamicFooterY Tho thoi");
    cpcl.writeln(
      "TEXT 7 0 ${borderLeft + 250} $dynamicFooterY To truong/ Ky thuat",
    );
    cpcl.writeln("SETBOLD 0");

    final lineY = dynamicFooterY + 30;
    cpcl.writeln("LINE ${borderLeft + 15} $lineY ${borderLeft + 120} $lineY 1");
    cpcl.writeln(
      "LINE ${borderLeft + 250} $lineY ${borderLeft + 430} $lineY 1",
    );

    final dynamicBorderBottom = (lineY + 15 > borderBottom)
        ? (lineY + 15)
        : borderBottom;

    _appendBorders(cpcl, dynamicBorderBottom, headerBottomY: headerBottomY);

    return cpcl.toString();
  }

  /// FORMAT TEM THƯƠNG MẠI
  static String formatPrintCommercialTicketCPCL(
    PrintCommercialTicketItem item,
  ) {
    StringBuffer cpcl = StringBuffer();

    _appendHeader(cpcl);

    int currentY = borderTop + 6;
    const int stepY = 22;
    const int labelX = borderLeft + 6;
    const int valueX = borderLeft + 120;

    final nsxName = removeVietnameseAccents(
      item.NSX.isEmpty ? "Cong Ty TNHH Bao Bi Tan Phong" : item.NSX,
    );
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY NSX:");
    cpcl.writeln("SETBOLD 0");
    currentY = _appendWrappedText(
      cpcl,
      nsxName,
      borderLeft + 60,
      currentY,
      24,
      maxLines: 2,
      lineSpacing: 18,
    );

    currentY += stepY;
    final addressStr = removeVietnameseAccents(
      item.addressCompany.isEmpty
          ? "284/1 Hoa Binh, Phuong Phu Thanh, TP.Ho Chi Minh"
          : item.addressCompany,
    );

    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY Dia chi:");
    cpcl.writeln("SETBOLD 0");
    currentY = _appendWrappedText(
      cpcl,
      addressStr,
      borderLeft + 100,
      currentY,
      24,
      maxLines: 2,
      lineSpacing: 18,
    );

    final headerDividerY = currentY + 22;
    cpcl.writeln(
      "LINE $borderLeft $headerDividerY $borderRight $headerDividerY 1",
    );

    final qrBoxLeft = 380;
    final qrBoxBottom = headerDividerY + 125;

    cpcl.writeln("LINE $qrBoxLeft $headerDividerY $qrBoxLeft $qrBoxBottom 1");
    cpcl.writeln("LINE $qrBoxLeft $qrBoxBottom $borderRight $qrBoxBottom 1");

    if (item.qrCode.isNotEmpty) {
      cpcl.writeln(
        "BARCODE QR ${qrBoxLeft + 12} ${headerDividerY + 8} M 2 U 4",
      );
      cpcl.writeln("MA,${item.qrCode}");
      cpcl.writeln("ENDQR");
    } else {
      cpcl.writeln("TEXT 7 0 ${qrBoxLeft + 30} ${headerDividerY + 45} QR Web");
    }

    currentY = headerDividerY + 6;

    final ngaySxStr = _formatDate(item.ngaySx);
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY Ngay sx:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 $valueX $currentY $ngaySxStr");

    currentY += stepY;
    final hsdStr = removeVietnameseAccents(
      item.hsd.isEmpty ? "3 nam tu NSX" : item.hsd,
    );
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY HSD:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 $valueX $currentY $hsdStr");

    currentY += stepY;
    final lsxFull = "${removeVietnameseAccents(item.LSX)} ${item.refNbr}"
        .trim();
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY LSX:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 $valueX $currentY $lsxFull");

    currentY += stepY;
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY TL(NW):");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 $valueX $currentY ${item.netweight} kg");

    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 ${borderLeft + 215} $currentY TL (GW):");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln(
      "TEXT 7 0 ${borderLeft + 295} $currentY ${item.grossweight} kg",
    );

    currentY += stepY;
    final tenHangStr = removeVietnameseAccents(item.tenHang);
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY Ten hang:");
    cpcl.writeln("SETBOLD 0");

    int tenHangMaxLen = (currentY < qrBoxBottom) ? 18 : 28;
    currentY = _appendWrappedText(
      cpcl,
      tenHangStr,
      valueX,
      currentY,
      tenHangMaxLen,
      maxLines: 2,
      lineSpacing: 18,
    );

    currentY += stepY;
    final moTaStr = removeVietnameseAccents(
      item.moTa.isEmpty ? "-" : item.moTa,
    );
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY Mo ta:");
    cpcl.writeln("SETBOLD 0");

    int moTaMaxLen = (currentY < qrBoxBottom) ? 18 : 28;
    currentY = _appendWrappedText(
      cpcl,
      moTaStr,
      valueX,
      currentY,
      moTaMaxLen,
      maxLines: 2,
      lineSpacing: 18,
    );

    currentY += stepY;
    final xuatXuStr = removeVietnameseAccents(
      item.XuatXu.isEmpty ? "Viet Nam" : item.XuatXu,
    );
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY Xuat xu:");
    cpcl.writeln("SETBOLD 0");
    cpcl.writeln("TEXT 7 0 $valueX $currentY $xuatXuStr");

    currentY += stepY;
    final baoQuanStr = removeVietnameseAccents(
      item.BaoQuan.isEmpty ? "Noi kho thoang" : item.BaoQuan,
    );
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY Bao quan:");
    cpcl.writeln("SETBOLD 0");
    currentY = _appendWrappedText(
      cpcl,
      baoQuanStr,
      valueX,
      currentY,
      28,
      maxLines: 2,
      lineSpacing: 18,
    );

    currentY += stepY;
    final canhBaoStr = removeVietnameseAccents(
      item.CanhBao.isEmpty ? "Tranh nhiet do cao" : item.CanhBao,
    );
    cpcl.writeln("SETBOLD 1");
    cpcl.writeln("TEXT 7 0 $labelX $currentY Canh bao:");
    cpcl.writeln("SETBOLD 0");
    currentY = _appendWrappedText(
      cpcl,
      canhBaoStr,
      valueX,
      currentY,
      28,
      maxLines: 2,
      lineSpacing: 18,
    );

    final int dynamicBorderBottom = (currentY + 28 > borderBottom)
        ? (currentY + 28)
        : borderBottom;

    _appendBorders(cpcl, dynamicBorderBottom);

    return cpcl.toString();
  }

  // --- PRIVATE HELPERS ---

  static void _appendHeader(StringBuffer cpcl) {
    cpcl.writeln("! 0 200 200 $labelHeightPx 1");
    cpcl.writeln("PAGE-WIDTH $labelWidthPx");
    cpcl.writeln("IN-OFFSET 0");
    cpcl.writeln("MARGIN 0 0");
    cpcl.writeln("CL");
  }

  static void _appendBorders(
    StringBuffer cpcl,
    int bottomY, {
    int? headerBottomY,
  }) {
    cpcl.writeln("LINE $borderLeft $borderTop $borderRight $borderTop 2");
    cpcl.writeln("LINE $borderLeft $bottomY $borderRight $bottomY 2");
    cpcl.writeln("LINE $borderLeft $borderTop $borderLeft $bottomY 2");
    cpcl.writeln("LINE $borderRight $borderTop $borderRight $bottomY 2");
    if (headerBottomY != null) {
      cpcl.writeln(
        "LINE $borderLeft $headerBottomY $borderRight $headerBottomY 1",
      );
    }
    cpcl.writeln("FORM");
    cpcl.writeln("PRINT");
  }

  static int _appendWrappedText(
    StringBuffer cpcl,
    String text,
    int x,
    int startY,
    int maxCharsPerLine, {
    int maxLines = 99,
    int lineSpacing = 20,
  }) {
    List<String> lines = _wrapText(text, maxCharsPerLine);
    if (maxLines < lines.length) {
      lines = lines.take(maxLines).toList();
    }

    int currentY = startY;
    for (int i = 0; i < lines.length; i++) {
      if (i > 0) currentY += lineSpacing;
      cpcl.writeln("TEXT 7 0 $x $currentY ${lines[i]}");
    }
    return currentY;
  }

  static String _decodeBase64(String base64Str) {
    try {
      return utf8.decode(base64.decode(base64Str));
    } catch (_) {
      return base64Str;
    }
  }

  static String _formatDate(String rawDate) {
    if (rawDate.trim().isEmpty) return "";
    try {
      final d = DateTime.parse(rawDate);
      final day = d.day.toString().padLeft(2, '0');
      final month = d.month.toString().padLeft(2, '0');
      return "$day/$month/${d.year}";
    } catch (_) {
      return rawDate;
    }
  }

  static List<String> _wrapText(String text, int maxLength) {
    List<String> lines = [];
    while (text.length > maxLength) {
      int spaceIndex = text.lastIndexOf(' ', maxLength);
      if (spaceIndex == -1) spaceIndex = maxLength;
      lines.add(text.substring(0, spaceIndex).trim());
      text = text.substring(spaceIndex).trim();
    }
    if (text.isNotEmpty) {
      lines.add(text);
    }
    return lines;
  }
}
