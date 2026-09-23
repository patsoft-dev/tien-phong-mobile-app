/// Model 1: Đọc response từ API /api/Discrete/getDiscrete
class DiscreteModel {
  final int? discrete_id;
  final String? discrete_nbr;
  final int? inventory_id;
  final String? status;

  DiscreteModel({
    this.discrete_id,
    this.discrete_nbr,
    this.inventory_id,
    this.status,
  });

  factory DiscreteModel.fromJson(Map<String, dynamic> json) {
    return DiscreteModel(
      discrete_id: json['discrete_id'] as int?,
      discrete_nbr: json['discrete_nbr']?.toString(),
      inventory_id: json['inventory_id'] as int?,
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discrete_id': discrete_id,
      'discrete_nbr': discrete_nbr,
      'inventory_id': inventory_id,
      'status': status,
    };
  }
}

/// Model 2: Đọc response từ API getInventoryByID
class InventoryModel {
  final int? inventoryId;
  final String? inventoryCd;
  final String? descr;
  final String? baseUnit;

  InventoryModel({
    this.inventoryId,
    this.inventoryCd,
    this.descr,
    this.baseUnit,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      inventoryId: json['InventoryID'] as int?,
      inventoryCd: json['InventoryCD']?.toString(),
      descr: json['Descr']?.toString(),
      baseUnit: json['BaseUnit']?.toString(),
    );
  }
}

/// Model 3: Model tổng hợp dùng cho UI Screen
class ProduceModel {
  final int? header_id;
  final String? ref_nbr;
  final String? date;
  final int? company_id;
  final int? branch_id;
  final int? discrete_id;
  final String? discrete_nbr;
  final int? inventory_id;
  final String? inventory_cd;
  final String? inventory_name;
  final String? object_code_lookup;
  final String? object_name_lookup;
  final String? doc_descr;
  final String? created_by_id;
  final String? last_modified_by_id;
  final bool? is_upload;
  final List<ProduceLineModel> lines;

  ProduceModel({
    this.header_id,
    this.ref_nbr,
    this.date,
    this.company_id,
    this.branch_id,
    this.discrete_id,
    this.discrete_nbr,
    this.inventory_id,
    this.inventory_cd,
    this.inventory_name,
    this.object_code_lookup,
    this.object_name_lookup,
    this.doc_descr,
    this.created_by_id,
    this.last_modified_by_id,
    this.is_upload,
    this.lines = const [],
  });

  ProduceModel copyWith({
    String? ref_nbr,
    String? discrete_nbr,
    String? discrete_id,
    int? inventory_id,
    String? inventory_cd,
    String? inventory_name,
    String? object_code_lookup,
    String? object_name_lookup,
    String? doc_descr,
    bool? is_upload,
    List<ProduceLineModel>? lines,
  }) {
    return ProduceModel(
      ref_nbr: ref_nbr ?? this.ref_nbr,
      discrete_nbr: discrete_nbr ?? this.discrete_nbr,
      inventory_id: inventory_id ?? this.inventory_id,
      inventory_cd: inventory_cd ?? this.inventory_cd,
      inventory_name: inventory_name ?? this.inventory_name,
      object_code_lookup: object_code_lookup ?? this.object_code_lookup,
      object_name_lookup: object_name_lookup ?? this.object_name_lookup,
      doc_descr: doc_descr ?? this.doc_descr,
      is_upload: is_upload ?? this.is_upload,
      lines: lines ?? this.lines,
    );
  }

  factory ProduceModel.fromJson(Map<String, dynamic> json) {
    return ProduceModel(
      header_id: json['header_id'] as int?,
      ref_nbr: json['ref_nbr']?.toString(),
      date: json['date']?.toString(),
      company_id: json['company_id'] as int?,
      branch_id: json['branch_id'] as int?,
      discrete_id: json['discrete_id'] as int?,
      discrete_nbr: json['discrete_nbr']?.toString(),
      inventory_id: json['inventory_id'] as int?,
      inventory_cd: json['inventory_cd']?.toString(),
      inventory_name: json['inventory_name']?.toString(),
      object_code_lookup: json['object_code_lookup']?.toString(),
      object_name_lookup: json['object_name_lookup']?.toString(),
      doc_descr: json['doc_descr']?.toString(),
      created_by_id: json['created_by_id']?.toString(),
      last_modified_by_id: json['last_modified_by_id']?.toString(),
      is_upload: json['is_upload'] is bool ? json['is_upload'] as bool : null,
      lines: json['lines'] != null && json['lines'] is List
          ? (json['lines'] as List)
                .map(
                  (e) => ProduceLineModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'header_id': header_id,
      'ref_nbr': ref_nbr,
      'date': date,
      'company_id': company_id,
      'branch_id': branch_id,
      'discrete_id': discrete_id,
      'discrete_nbr': discrete_nbr,
      'inventory_id': inventory_id,
      'inventory_cd': inventory_cd,
      'inventory_name': inventory_name,
      'object_code_lookup': object_code_lookup,
      'object_name_lookup': object_name_lookup,
      'doc_descr': doc_descr,
      'created_by_id': created_by_id,
      'last_modified_by_id': last_modified_by_id,
      'is_upload': is_upload,
      'lines': lines.map((e) => e.toJson()).toList(),
    };
  }
}

class ProduceLineModel {
  final int? line_id,
      header_id,
      discrete_id,
      inventory_id,
      company_id,
      line_nbr;
  final num? base_qty, physical_qty, gross_weight, add_weight;
  final String? lot_nbr,
      base_unit,
      line_descr,
      object_code_lookup,
      object_name_lookup;
  final String? lot_manufacture_date,
      lot_expire_date,
      created_by_id,
      last_modified_by_id;

  ProduceLineModel({
    this.line_id,
    this.header_id,
    this.discrete_id,
    this.inventory_id,
    this.company_id,
    this.line_nbr,
    this.lot_nbr,
    this.base_qty,
    this.base_unit,
    this.physical_qty,
    this.gross_weight,
    this.add_weight,
    this.line_descr,
    this.object_code_lookup,
    this.object_name_lookup,
    this.lot_manufacture_date,
    this.lot_expire_date,
    this.created_by_id,
    this.last_modified_by_id,
  });

  ProduceLineModel copyWith({
    int? line_id,
    header_id,
    discrete_id,
    inventory_id,
    company_id,
    line_nbr,
    num? base_qty,
    physical_qty,
    gross_weight,
    add_weight,
    String? lot_nbr,
    base_unit,
    line_descr,
    object_code_lookup,
    object_name_lookup,
    lot_manufacture_date,
    lot_expire_date,
    created_by_id,
    last_modified_by_id,
  }) {
    return ProduceLineModel(
      line_id: line_id ?? this.line_id,
      header_id: header_id ?? this.header_id,
      discrete_id: discrete_id ?? this.discrete_id,
      inventory_id: inventory_id ?? this.inventory_id,
      company_id: company_id ?? this.company_id,
      line_nbr: line_nbr ?? this.line_nbr,
      lot_nbr: lot_nbr ?? this.lot_nbr,
      base_qty: base_qty ?? this.base_qty,
      base_unit: base_unit ?? this.base_unit,
      physical_qty: physical_qty ?? this.physical_qty,
      gross_weight: gross_weight ?? this.gross_weight,
      add_weight: add_weight ?? this.add_weight,
      line_descr: line_descr ?? this.line_descr,
      object_code_lookup: object_code_lookup ?? this.object_code_lookup,
      object_name_lookup: object_name_lookup ?? this.object_name_lookup,
      lot_manufacture_date: lot_manufacture_date ?? this.lot_manufacture_date,
      lot_expire_date: lot_expire_date ?? this.lot_expire_date,
      created_by_id: created_by_id ?? this.created_by_id,
      last_modified_by_id: last_modified_by_id ?? this.last_modified_by_id,
    );
  }

  factory ProduceLineModel.fromJson(Map<String, dynamic> json) =>
      ProduceLineModel(
        line_id: json['line_id'] as int?,
        header_id: json['header_id'] as int?,
        discrete_id: json['discrete_id'] as int?,
        inventory_id: json['inventory_id'] as int?,
        company_id: json['company_id'] as int?,
        line_nbr: json['line_nbr'] as int?,
        lot_nbr: json['lot_nbr']?.toString(),
        base_qty: json['base_qty'] as num?,
        base_unit: json['base_unit']?.toString(),
        physical_qty: json['physical_qty'] as num?,
        gross_weight: json['gross_weight'] as num?,
        add_weight: json['add_weight'] as num?,
        line_descr: json['line_descr']?.toString(),
        object_code_lookup: json['object_code_lookup']?.toString(),
        object_name_lookup: json['object_name_lookup']?.toString(),
        lot_manufacture_date: json['lot_manufacture_date']?.toString(),
        lot_expire_date: json['lot_expire_date']?.toString(),
        created_by_id: json['created_by_id']?.toString(),
        last_modified_by_id: json['last_modified_by_id']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'line_id': line_id,
    'header_id': header_id,
    'discrete_id': discrete_id,
    'inventory_id': inventory_id,
    'company_id': company_id,
    'line_nbr': line_nbr,
    'lot_nbr': lot_nbr,
    'base_qty': base_qty,
    'base_unit': base_unit,
    'physical_qty': physical_qty,
    'gross_weight': gross_weight,
    'add_weight': add_weight,
    'line_descr': line_descr,
    'object_code_lookup': object_code_lookup,
    'object_name_lookup': object_name_lookup,
    'lot_manufacture_date': lot_manufacture_date,
    'lot_expire_date': lot_expire_date,
    'created_by_id': created_by_id,
    'last_modified_by_id': last_modified_by_id,
  };
}

/// Model 2: Đọc response từ API /api/Discrete/getDiscrete
class WeighStationModel {
  final String? ObjectCode;
  final String? ObjectName;
  final String? Note;
  final String? NoteA;
  final String? CompanyID;

  WeighStationModel({
    this.ObjectCode,
    this.ObjectName,
    this.Note,
    this.NoteA,
    this.CompanyID,
  });

  factory WeighStationModel.fromJson(Map<String, dynamic> json) {
    return WeighStationModel(
      ObjectCode: json['ObjectCode']?.toString(),
      ObjectName: json['ObjectName']?.toString(),
      Note: json['Note']?.toString(),
      NoteA: json['NoteA']?.toString(),
      CompanyID: json['CompanyID']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ObjectCode': ObjectCode,
      'ObjectName': ObjectName,
      'Note': Note,
      'NoteA': NoteA,
      'CompanyID': CompanyID,
    };
  }
}
