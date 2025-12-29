import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// PIN-based security service for Cabinet protection
/// Uses flutter_secure_storage (already installed) instead of local_auth biometric
class SecurityService {
  static final SecurityService instance = SecurityService._();
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'cabinet_pin';
  static const _pinEnabledKey = 'pin_enabled';
  
  SecurityService._();
  
  /// Check if PIN is enabled
  Future<bool> isPinEnabled() async {
    final enabled = await _storage.read(key: _pinEnabledKey);
    return enabled == 'true';
  }
  
  /// Set up a new PIN
  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    await _storage.write(key: _pinEnabledKey, value: 'true');
  }
  
  /// Remove PIN protection
  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _pinEnabledKey);
  }
  
  /// Verify PIN
  Future<bool> verifyPin(String enteredPin) async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin == enteredPin;
  }
  
  /// Main authentication method - shows PIN dialog if enabled
  /// Returns true if authenticated (PIN correct or PIN not enabled)
  Future<bool> authenticate() async {
    final enabled = await isPinEnabled();
    if (!enabled) {
      return true; // No PIN set, allow access
    }
    // If PIN is enabled, the UI will show a dialog to enter it
    // This method is called from cabinet_screen which handles the UI
    return false; // Requires PIN verification
  }
}
