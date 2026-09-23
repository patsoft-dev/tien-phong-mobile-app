import 'dart:convert';
import 'package:qr_app/services/printer/printer_model.dart';

class ZplTicketService {
  /// Giải mã Base64 an toàn cho ZPL
  static String _decodeBase64(String value) {
    if (value.trim().isEmpty) return '';
    try {
      return utf8.decode(base64.decode(value));
    } catch (_) {
      return value;
    }
  }

  /// Định dạng chuỗi ngày tháng (yyyy-MM-ddTHH:mm:ss -> dd/MM/yyyy)
  static String _formatDate(String rawDate) {
    if (rawDate.trim().isEmpty) return '';
    try {
      final d = DateTime.parse(rawDate);
      final day = d.day.toString().padLeft(2, '0');
      final month = d.month.toString().padLeft(2, '0');
      return '$day/$month/${d.year}';
    } catch (_) {
      return rawDate;
    }
  }

  /// Render chuỗi lệnh ZPL cho Tem Nhận Diện (Internal Label)
  static String generateInternalLabelZPL(PrintInternalTicketItem data) {
    final nsxFormatted = _formatDate(data.NSX);
    final hsdFormatted = _formatDate(data.HSD);
    final netWeightVal = _decodeBase64(data.netweight);
    final grossWeightVal = _decodeBase64(data.grossweight);

    return '''
^XA
^CI28
^CW1,E:NOTOSANS-REGULAR.TTF

^FX --- KHUNG NGOÀI TỔNG THỂ ---
^FO20,30^GB740,360,2^FS

^FX --- TIÊU ĐỀ: TEM NHẬN DIỆN ---
^FO20,30^GB580,40,2^FS
^FO20,40^A1N,24,24^FB580,1,0,C^FDTEM NHẬN DIỆN^FS

^FX --- ĐƯỜNG DỌC CHIA KHUNG DƯỚI TIÊU ĐỀ BÊN PHẢI ---
^FO600,30^GB1,190,2^FS

^FX --- QR CODE LOT (BÊN PHẢI, BỎ CHỮ, DỊCH SANG PHẢI) ---
^FO620,50^BQN,2,4
^FDQA,${data.qRCode}^FS

^FX --- NỘI DUNG CHI TIẾT (BÊN TRÁI) ---
^FX Hàng 1: Ngày SX & HSD
^FO30,80^A1N,18,18^FDNgày SX:^FS
^FO130,80^A1N,18,18^FD$nsxFormatted^FS

^FO280,80^A1N,18,18^FDHSD:^FS
^FO340,80^A1N,18,18^FD$hsdFormatted^FS

^FX Hàng 2: LSX
^FO30,105^A1N,18,18^FDLSX:^FS
^FO130,105^A1N,18,18^FD${data.LSX} ${data.sttCuon}^FS

^FX Hàng 3: TL Net & TL Gross
^FO30,130^A1N,18,18^FDTL Net:^FS
^FO130,130^A1N,18,18^FD$netWeightVal kg^FS

^FO280,130^A1N,18,18^FDTL Gross:^FS
^FO370,130^A1N,18,18^FD$grossWeightVal kg^FS

^FX Hàng 4: Khách hàng (Hỗ trợ xuống dòng tự động tối đa 2 dòng, độ rộng 450px)
^FO30,155^A1N,18,18^FDKhách hàng:^FS
^FO130,155^A1N,18,18^FB450,2,0,L^FD${data.khachHang}^FS

^FX Hàng 5: Máy (Tự động lùi Y xuống tùy theo độ dài Khách hàng bên trên)
^FO30,195^A1N,18,18^FDMáy:^FS
^FO130,195^A1N,18,18^FD${data.may}^FS

^FX Hàng 6: ID/Mô tả (Hỗ trợ xuống dòng tự động tối đa 2 dòng, độ rộng 450px)
^FO30,220^A1N,18,18^FDID/Mô tả:^FS
^FO130,220^A1N,18,18^FB450,2,0,L^FD${data.maVT} - ${data.quyCach}^FS

^FX --- CHỮ KÝ PHÍA DƯỚI (ĐÃ BỎ BORDER ĐƯỜNG KẺ VÀ ĐẨY LÊN TRÊN) ---
^FO40,295^A1N,18,18^FDThợ thổi^FS
^FO400,295^A1N,18,18^FDTổ trưởng/ Kỹ thuật^FS

^XZ
''';
  }

  /// Render chuỗi lệnh ZPL cho Tem Thương Mại (Commercial Label)
  static String generateCommercialLabelZPL(PrintCommercialTicketItem data) {
    final ngaySxFormatted = _formatDate(data.ngaySx);
    final xuatXuStr = data.XuatXu.isEmpty ? 'Việt Nam' : data.XuatXu;
    final baoQuanStr = data.BaoQuan.isEmpty ? 'Nơi khô thoáng' : data.BaoQuan;
    final canhBaoStr = data.CanhBao.isEmpty
        ? 'Tránh nhiệt độ cao'
        : data.CanhBao;

    return '''
^XA
^CI28
^CW1,E:NOTOSANS-REGULAR.TTF

^FX --- KHUNG NGOÀI TỔNG THỂ VÀ ĐƯỜNG KẺ NGANG ĐẦU TIÊN ---
^FO20,50^GB760,430,2^FS
^FO20,140^GB760,1,2^FS

^FX --- THÔNG TIN NHÀ SẢN XUẤT (PHÍA TRÊN) ---
^FO30,60^A1N,18,18^FB740,1,0,L^FDNSX: ${data.NSX}^FS
^FO30,95^A1N,18,18^FB740,2,0,L^FDĐịa chỉ: ${data.addressCompany}^FS

^FX --- Ô KHUNG VÀ QR CODE WEB (BÊN PHẢI) ---
^FO610,140^GB1,140,2^FS
^FO610,280^GB170,1,2^FS
^FO630,148^BQN,2,4
^FDQA,${data.qrCode}^FS

^FX --- THÔNG TIN SẢN PHẨM PHẦN TRÊN (BÊN TRÁI QR CODE) ---
^FO30,150^A1N,18,18^FDNgày sx:^FS
^FO150,150^A1N,18,18^FD$ngaySxFormatted^FS

^FO30,175^A1N,18,18^FDHSD:^FS
^FO150,175^A1N,18,18^FD${data.hsd}^FS

^FO30,200^A1N,18,18^FDLSX:^FS
^FO150,200^A1N,18,18^FD${data.LSX} ${data.refNbr}^FS

^FO30,225^A1N,18,18^FDTL(NW):^FS
^FO150,225^A1N,18,18^FD${data.netweight} kg^FS
^FO310,225^A1N,18,18^FDTL (GW):^FS
^FO400,225^A1N,18,18^FD${data.grossweight} kg^FS

^FX Tên hàng (Giới hạn 440px để không che QR code, cho phép xuống 2 dòng)
^FO30,250^A1N,18,18^FDTên hàng:^FS
^FO150,250^A1N,18,18^FB440,2,0,L^FD${data.tenHang}^FS

^FX --- THÔNG TIN PHẦN DƯỚI (RỘNG TOÀN MÀN HÌNH, CHO PHÉP XUỐNG DÒNG) ---
^FX Mô tả
^FO30,290^A1N,18,18^FDMô tả:^FS
^FO150,290^A1N,18,18^FB610,2,0,L^FD${data.moTa}^FS

^FX Xuất xứ
^FO30,330^A1N,18,18^FDXuất xứ:^FS
^FO150,330^A1N,18,18^FB610,1,0,L^FD$xuatXuStr^FS

^FX Bảo quản
^FO30,360^A1N,18,18^FDBảo quản:^FS
^FO150,360^A1N,18,18^FB610,2,0,L^FD$baoQuanStr^FS

^FX Cảnh báo
^FO30,410^A1N,18,18^FDCảnh báo:^FS
^FO150,410^A1N,18,18^FB610,2,0,L^FD$canhBaoStr^FS

^XZ
''';
  }
}
