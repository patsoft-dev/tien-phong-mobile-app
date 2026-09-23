class SiteModel {
  final int? SiteID;
  final String? SiteCD;
  final String? Descr;

  SiteModel({this.SiteID, this.SiteCD, this.Descr});

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      SiteID: json['SiteID'] as int?,
      SiteCD: json['SiteCD']?.toString(),
      Descr: json['Descr']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'SiteID': SiteID, 'SiteCD': SiteCD, 'Descr': Descr};
  }
}

class LocationModel {
  final int? LocationID;
  final String? LocationCD;
  final String? LocationDescr;

  LocationModel({this.LocationID, this.LocationCD, this.LocationDescr});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      LocationID: json['LocationID'] as int?,
      LocationCD: json['LocationCD']?.toString(),
      LocationDescr: json['LocationDescr']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LocationID': LocationID,
      'LocationCD': LocationCD,
      'LocationDescr': LocationDescr,
    };
  }
}

class StockTakeModel {
  final String? date;
  final String? idSite;
  final String? siteName;
  final List<StockTakeLineModel> lines;

  StockTakeModel({
    this.date,
    this.idSite,
    this.siteName,
    this.lines = const [],
  });

  StockTakeModel copyWith({
    String? date,
    String? idSite,
    String? siteName,
    List<StockTakeLineModel>? lines,
  }) {
    return StockTakeModel(
      date: date ?? this.date,
      idSite: idSite ?? this.idSite,
      siteName: siteName ?? this.siteName,
      lines: lines ?? this.lines,
    );
  }

  factory StockTakeModel.fromJson(Map<String, dynamic> json) {
    return StockTakeModel(
      date: json['date']?.toString(),
      idSite: json['idSite']?.toString(),
      siteName: json['siteName']?.toString(),
      lines: json['lines'] != null && json['lines'] is List
          ? (json['lines'] as List)
                .map(
                  (e) => StockTakeLineModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'idSite': idSite,
      'siteName': siteName,
      'lines': lines.map((e) => e.toJson()).toList(),
    };
  }
}

class StockTakeLineModel {
  final String? idLocation;
  final String? maLocator;
  final String? locationName;
  final String? maVatTu;
  final String? tenVatTu;
  final String? soLo;
  final num? soLuong;

  StockTakeLineModel({
    this.idLocation,
    this.maLocator,
    this.locationName,
    this.maVatTu,
    this.tenVatTu,
    this.soLo,
    this.soLuong,
  });

  StockTakeLineModel copyWith({
    String? idLocation,
    String? maLocator,
    String? locationName,
    String? maVatTu,
    String? tenVatTu,
    String? soLo,
    num? soLuong,
  }) {
    return StockTakeLineModel(
      idLocation: idLocation ?? this.idLocation,
      maLocator: maLocator ?? this.maLocator,
      locationName: locationName ?? this.locationName,
      maVatTu: maVatTu ?? this.maVatTu,
      tenVatTu: tenVatTu ?? this.tenVatTu,
      soLo: soLo ?? this.soLo,
      soLuong: soLuong ?? this.soLuong,
    );
  }

  factory StockTakeLineModel.fromJson(Map<String, dynamic> json) {
    return StockTakeLineModel(
      idLocation: json['idLocation']?.toString(),
      maLocator: json['maLocator']?.toString(),
      locationName: json['locationName']?.toString(),
      maVatTu: json['maVatTu']?.toString(),
      tenVatTu: json['tenVatTu']?.toString(),
      soLo: json['soLo']?.toString(),
      soLuong: json['soLuong'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idLocation': idLocation,
      'maLocator': maLocator,
      'locationName': locationName,
      'maVatTu': maVatTu,
      'tenVatTu': tenVatTu,
      'soLo': soLo,
      'soLuong': soLuong,
    };
  }
}
