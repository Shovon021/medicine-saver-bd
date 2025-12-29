/// Represents a branded medicine product.
class Brand {
  final int id;
  final String name;
  final int genericId;
  final String? genericName; // Joined from generics table
  final int? manufacturerId;
  final String? manufacturerName; // Joined from manufacturers table
  final String? strength;
  final String? dosageForm;
  final double? price;
  final String? packSize;

  Brand({
    required this.id,
    required this.name,
    required this.genericId,
    this.genericName,
    this.manufacturerId,
    this.manufacturerName,
    this.strength,
    this.dosageForm,
    this.price,
    this.packSize,
  });

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      id: map['id'] as int,
      name: map['name'] as String,
      genericId: map['generic_id'] as int,
      genericName: map['generic_name'] as String?,
      manufacturerId: map['manufacturer_id'] as int?,
      manufacturerName: map['manufacturer_name'] as String?,
      strength: map['strength'] as String?,
      dosageForm: map['dosage_form'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      packSize: map['pack_size'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'generic_id': genericId,
      'manufacturer_id': manufacturerId,
      'strength': strength,
      'dosage_form': dosageForm,
      'price': price,
      'pack_size': packSize,
    };
  }
}
