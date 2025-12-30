import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'cabinet_service.dart';

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String message;
  final int itemsPushed;
  final int itemsPulled;

  SyncResult({
    required this.success,
    required this.message,
    this.itemsPushed = 0,
    this.itemsPulled = 0,
  });
}

class SyncService {
  static final SyncService instance = SyncService._();
  SyncService._();

  final _supabase = Supabase.instance.client;

  /// Checks if device has internet connectivity
  Future<bool> _hasConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  /// Syncs local cabinet with cloud (Two-way sync)
  /// Returns a SyncResult with details about the sync operation
  Future<SyncResult> sync() async {
    // Check if user is logged in
    if (!AuthService.instance.isLoggedIn) {
      return SyncResult(
        success: false,
        message: 'Please sign in to sync your cabinet',
      );
    }

    // Check network connectivity
    if (!await _hasConnectivity()) {
      return SyncResult(
        success: false,
        message: 'No internet connection. Please try again later.',
      );
    }

    try {
      final pushCount = await _pushToCloud();
      final pullCount = await _pullFromCloud();

      return SyncResult(
        success: true,
        message: 'Sync complete!',
        itemsPushed: pushCount,
        itemsPulled: pullCount,
      );
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      return SyncResult(
        success: false,
        message: 'Server error: ${e.message}',
      );
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return SyncResult(
        success: false,
        message: 'Authentication error. Please sign in again.',
      );
    } catch (e) {
      debugPrint('Sync failed: $e');
      return SyncResult(
        success: false,
        message: 'Sync failed. Please try again.',
      );
    }
  }

  /// Uploads local medicines to Supabase
  /// Returns the number of items pushed
  Future<int> _pushToCloud() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return 0;

    final localMedicines = CabinetService.instance.medicines;
    int count = 0;

    for (var medicine in localMedicines) {
      try {
        await _supabase.from('user_cabinet').upsert({
          'user_id': user.id,
          'brand_name': medicine.brandName,
          'generic_name': medicine.genericName,
          'manufacturer': medicine.manufacturer,
          'strength': medicine.strength,
          'dosage_form': medicine.dosageForm,
          'price': medicine.price,
          'notes': medicine.notes,
          'saved_at': medicine.savedAt.toIso8601String(),
        }, onConflict: 'user_id, brand_name, strength');
        count++;
      } catch (e) {
        debugPrint('Failed to push ${medicine.brandName}: $e');
      }
    }

    return count;
  }

  /// Downloads medicines from Supabase to local
  /// Returns the number of new items pulled
  Future<int> _pullFromCloud() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return 0;

    final response = await _supabase
        .from('user_cabinet')
        .select()
        .eq('user_id', user.id);

    final List<dynamic> data = response;
    int count = 0;

    for (var item in data) {
      final medicine = SavedMedicine(
        brandName: item['brand_name'] ?? '',
        genericName: item['generic_name'] ?? '',
        manufacturer: item['manufacturer'] ?? '',
        strength: item['strength'] ?? '',
        dosageForm: item['dosage_form'] ?? '',
        price: (item['price'] ?? 0).toDouble(),
        savedAt: DateTime.parse(item['saved_at']),
        notes: item['notes'],
      );

      // Add to local if not exists
      final added = await CabinetService.instance.addMedicine(medicine);
      if (added) count++;
    }

    return count;
  }
}
