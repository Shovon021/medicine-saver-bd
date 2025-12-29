import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user's saved medicines ("My Cabinet").
class CabinetService {
  static final CabinetService instance = CabinetService._init();
  static const String _storageKey = 'my_cabinet';
  
  SharedPreferences? _prefs;
  List<SavedMedicine> _medicines = [];
  
  CabinetService._init();

  /// Initialize the service and load saved medicines.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadMedicines();
  }

  /// Get all saved medicines.
  List<SavedMedicine> get medicines => List.unmodifiable(_medicines);

  /// Check if a medicine is saved.
  bool isSaved(String brandName) {
    return _medicines.any((m) => m.brandName.toLowerCase() == brandName.toLowerCase());
  }

  /// Add a medicine to cabinet.
  Future<bool> addMedicine(SavedMedicine medicine) async {
    if (isSaved(medicine.brandName)) {
      return false; // Already saved
    }

    _medicines.add(medicine);
    await _saveMedicines();
    return true;
  }

  /// Remove a medicine from cabinet.
  Future<bool> removeMedicine(String brandName) async {
    final initialLength = _medicines.length;
    _medicines.removeWhere((m) => m.brandName.toLowerCase() == brandName.toLowerCase());
    
    if (_medicines.length != initialLength) {
      await _saveMedicines();
      return true;
    }
    return false;
  }

  /// Toggle saved status of a medicine.
  Future<bool> toggleSaved(SavedMedicine medicine) async {
    if (isSaved(medicine.brandName)) {
      await removeMedicine(medicine.brandName);
      return false; // Now unsaved
    } else {
      await addMedicine(medicine);
      return true; // Now saved
    }
  }

  /// Clear all saved medicines.
  Future<void> clearAll() async {
    _medicines.clear();
    await _saveMedicines();
  }

  /// Load medicines from storage.
  Future<void> _loadMedicines() async {
    final String? jsonString = _prefs?.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      _medicines = [];
      return;
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _medicines = jsonList.map((j) => SavedMedicine.fromJson(j)).toList();
    } catch (e) {
      _medicines = [];
    }
  }

  /// Save medicines to storage.
  Future<void> _saveMedicines() async {
    final String jsonString = json.encode(_medicines.map((m) => m.toJson()).toList());
    await _prefs?.setString(_storageKey, jsonString);
  }
}

/// Represents a saved medicine in user's cabinet.
class SavedMedicine {
  final String brandName;
  final String genericName;
  final String manufacturer;
  final String strength;
  final String dosageForm;
  final double price;
  final DateTime savedAt;
  final String? notes;

  SavedMedicine({
    required this.brandName,
    required this.genericName,
    required this.manufacturer,
    required this.strength,
    required this.dosageForm,
    required this.price,
    DateTime? savedAt,
    this.notes,
  }) : savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'brandName': brandName,
        'genericName': genericName,
        'manufacturer': manufacturer,
        'strength': strength,
        'dosageForm': dosageForm,
        'price': price,
        'savedAt': savedAt.toIso8601String(),
        'notes': notes,
      };

  factory SavedMedicine.fromJson(Map<String, dynamic> json) => SavedMedicine(
        brandName: json['brandName'] ?? '',
        genericName: json['genericName'] ?? '',
        manufacturer: json['manufacturer'] ?? '',
        strength: json['strength'] ?? '',
        dosageForm: json['dosageForm'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
        notes: json['notes'],
      );
}
