class SellerRevenueModel {
  final double totalRevenue;

  const SellerRevenueModel({required this.totalRevenue});

  factory SellerRevenueModel.fromJson(Map<String, dynamic> json) {
    final rawValue = json['totalRevenue'];
    return SellerRevenueModel(
      totalRevenue: rawValue is num
          ? rawValue.toDouble()
          : double.tryParse(rawValue?.toString() ?? '') ?? 0,
    );
  }
}
