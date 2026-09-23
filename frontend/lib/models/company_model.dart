class CompanyModel {
  final int companyId;
  final String companyCode;
  final String companyKey;

  CompanyModel({
    required this.companyId,
    required this.companyCode,
    required this.companyKey,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['company_id'] ?? 0,
      companyCode: json['company_code'] ?? '',
      companyKey: json['company_key'] ?? '',
    );
  }
}
