import 'dart:convert';

/// MODEL TEM NHẬN DIỆN (TEM NỘI BỘ)
class PrintInternalTicketItem {
  final String NSX;
  final String HSD;
  final String LSX;
  final String soCT;
  final String sttCuon;
  final String netweight;
  final String grossweight;
  final String khachHang;
  final String may;
  final String quyCach;
  final String maVT;
  final String qRCode;

  PrintInternalTicketItem({
    required this.NSX,
    required this.HSD,
    required this.LSX,
    required this.soCT,
    required this.sttCuon,
    required this.netweight,
    required this.grossweight,
    required this.khachHang,
    required this.may,
    required this.quyCach,
    required this.maVT,
    required this.qRCode,
  });

  /// Factory chuyển đổi từ Map (JSON) sang Object
  /// Xử lý map key linh hoạt (hỗ trợ cả chữ hoa/thường)
  factory PrintInternalTicketItem.fromJson(Map<String, dynamic> json) {
    return PrintInternalTicketItem(
      NSX: json['NSX']?.toString() ?? json['ngaySx']?.toString() ?? '',
      HSD: json['HSD']?.toString() ?? json['hsd']?.toString() ?? '',
      LSX: json['lSX']?.toString() ?? json['LSX']?.toString() ?? '',
      soCT: json['sCT']?.toString() ?? json['soCT']?.toString() ?? '',
      sttCuon: json['sTTCuon']?.toString() ?? json['sttCuon']?.toString() ?? '',
      netweight: json['netweight']?.toString() ?? '',
      grossweight: json['grossweight']?.toString() ?? '',
      khachHang: json['khachHang']?.toString() ?? '',
      may: json['may']?.toString() ?? json['tenMay']?.toString() ?? '',
      quyCach: json['quyCach']?.toString() ?? '',
      maVT: json['maVT']?.toString() ?? json['refNbr']?.toString() ?? '',
      qRCode: json['qRCode']?.toString() ?? json['qrCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NSX': NSX,
      'HSD': HSD,
      'lSX': LSX,
      'sCT': soCT,
      'sTTCuon': sttCuon,
      'netweight': netweight,
      'grossweight': grossweight,
      'khachHang': khachHang,
      'may': may,
      'quyCach': quyCach,
      'maVT': maVT,
      'qRCode': qRCode,
    };
  }
}

/// MODEL TEM THƯƠNG MẠI
class PrintCommercialTicketItem {
  final String NSX;
  final String addressCompany;
  final String ngaySx;
  final String hsd;
  final String LSX;
  final String SoLo;
  final String refNbr;
  final dynamic netweight;
  final dynamic grossweight;
  final String khachHang;
  final String maMay;
  final String tenMay;
  final String quyCach;
  final String tenHang;
  final String moTa;
  final String XuatXu;
  final String BaoQuan;
  final String CanhBao;
  final String qrCode;

  PrintCommercialTicketItem({
    required this.NSX,
    required this.addressCompany,
    required this.ngaySx,
    required this.hsd,
    required this.LSX,
    required this.SoLo,
    required this.refNbr,
    required this.netweight,
    required this.grossweight,
    required this.khachHang,
    required this.maMay,
    required this.tenMay,
    required this.quyCach,
    required this.tenHang,
    required this.moTa,
    required this.XuatXu,
    required this.BaoQuan,
    required this.CanhBao,
    required this.qrCode,
  });

  factory PrintCommercialTicketItem.fromJson(Map<String, dynamic> json) {
    return PrintCommercialTicketItem(
      NSX: json['NSX']?.toString() ?? '',
      addressCompany: json['addressCompany']?.toString() ?? '',
      ngaySx: json['ngaySx']?.toString() ?? '',
      hsd: json['hsd']?.toString() ?? '',
      LSX: json['LSX']?.toString() ?? '',
      SoLo: json['SoLo']?.toString() ?? '',
      refNbr: json['refNbr']?.toString() ?? '',
      netweight: json['netweight'] ?? 0,
      grossweight: json['grossweight'] ?? 0,
      khachHang: json['khachHang']?.toString() ?? '-',
      maMay: json['maMay']?.toString() ?? '',
      tenMay: json['tenMay']?.toString() ?? '',
      quyCach: json['quyCach']?.toString() ?? '-',
      tenHang: json['tenHang']?.toString() ?? '',
      moTa: json['moTa']?.toString() ?? '',
      XuatXu: json['XuatXu']?.toString() ?? '',
      BaoQuan: json['BaoQuan']?.toString() ?? '',
      CanhBao: json['CanhBao']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NSX': NSX,
      'addressCompany': addressCompany,
      'ngaySx': ngaySx,
      'hsd': hsd,
      'LSX': LSX,
      'SoLo': SoLo,
      'refNbr': refNbr,
      'netweight': netweight,
      'grossweight': grossweight,
      'khachHang': khachHang,
      'maMay': maMay,
      'tenMay': tenMay,
      'quyCach': quyCach,
      'tenHang': tenHang,
      'moTa': moTa,
      'XuatXu': XuatXu,
      'BaoQuan': BaoQuan,
      'CanhBao': CanhBao,
      'qrCode': qrCode,
    };
  }
}
