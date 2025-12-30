class PriceReport {
  final String id;
  final String userId;
  final String medicineName;
  final int? medicineId;
  final double pricePaid;
  final double? mrp;
  final String? pharmacyName;
  final String? locationArea;
  final DateTime createdAt;
  final int upvotes;
  final bool isVerified;

  PriceReport({
    required this.id,
    required this.userId,
    required this.medicineName,
    this.medicineId,
    required this.pricePaid,
    this.mrp,
    this.pharmacyName,
    this.locationArea,
    required this.createdAt,
    this.upvotes = 0,
    this.isVerified = false,
  });

  factory PriceReport.fromMap(Map<String, dynamic> map) {
    return PriceReport(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      medicineName: map['medicine_name'] ?? '',
      medicineId: map['medicine_id'],
      pricePaid: (map['price_paid'] as num).toDouble(),
      mrp: map['mrp'] != null ? (map['mrp'] as num).toDouble() : null,
      pharmacyName: map['pharmacy_name'],
      locationArea: map['location_area'],
      createdAt: DateTime.parse(map['created_at']),
      upvotes: map['upvotes'] ?? 0,
      isVerified: map['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'medicine_name': medicineName,
      'medicine_id': medicineId,
      'price_paid': pricePaid,
      'mrp': mrp,
      'pharmacy_name': pharmacyName,
      'location_area': locationArea,
      // 'created_at' and 'id' are handled by Supabase
    };
  }
}
