/// Represents a generic drug component (e.g., Esomeprazole, Omeprazole).
class Generic {
  final int id;
  final String name;
  final String? indication;
  final String? dosageInfo;
  final String? sideEffects;

  Generic({
    required this.id,
    required this.name,
    this.indication,
    this.dosageInfo,
    this.sideEffects,
  });

  factory Generic.fromMap(Map<String, dynamic> map) {
    return Generic(
      id: map['id'] as int,
      name: map['name'] as String,
      indication: map['indication'] as String?,
      dosageInfo: map['dosage_info'] as String?,
      sideEffects: map['side_effects'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'indication': indication,
      'dosage_info': dosageInfo,
      'side_effects': sideEffects,
    };
  }
}
