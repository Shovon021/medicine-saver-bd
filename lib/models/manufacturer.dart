/// Represents a pharmaceutical manufacturer.
class Manufacturer {
  final int id;
  final String name;
  final String? country;

  Manufacturer({
    required this.id,
    required this.name,
    this.country,
  });

  factory Manufacturer.fromMap(Map<String, dynamic> map) {
    return Manufacturer(
      id: map['id'] as int,
      name: map['name'] as String,
      country: map['country'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
    };
  }
}
