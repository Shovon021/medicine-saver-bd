import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'database_helper.dart';

/// Service to check for and download medicine database updates from Supabase.
class DatabaseUpdateService {
  static final DatabaseUpdateService instance = DatabaseUpdateService._();
  DatabaseUpdateService._();

  static const String _versionKey = 'db_version';
  static const String _dbFileName = 'medicines.db';

  final _supabase = Supabase.instance.client;

  /// Checks if a database update is available.
  /// Returns the new version number if update available, null otherwise.
  Future<int?> checkForUpdate() async {
    try {
      // Get local version
      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getInt(_versionKey) ?? 1;

      // Get remote version from Supabase
      final response = await _supabase
          .from('app_config')
          .select('value')
          .eq('key', 'db_version')
          .single();

      final remoteVersion = int.tryParse(response['value'] ?? '1') ?? 1;

      if (remoteVersion > localVersion) {
        return remoteVersion;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to check for updates: $e');
      return null;
    }
  }

  /// Downloads and installs a new database version.
  /// Returns true if update was successful.
  Future<bool> downloadUpdate(int newVersion) async {
    try {
      // Download the new database from Supabase Storage
      final response = await _supabase.storage
          .from('app-assets')
          .download('databases/medicines_v$newVersion.db');

      // Get local database path
      final documentsDir = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDir.path, _dbFileName);

      // Close the database connection to release the file lock
      await DatabaseHelper.instance.close();

      // Write new database file
      final dbFile = File(dbPath);
      await dbFile.writeAsBytes(response);

      // Update local version
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_versionKey, newVersion);

      debugPrint('Database updated to version $newVersion');
      return true;
    } catch (e) {
      debugPrint('Failed to download update: $e');
      return false;
    }
  }

  /// Gets the current local database version.
  Future<int> getLocalVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_versionKey) ?? 1;
  }
}
