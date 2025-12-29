import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static final SecurityService instance = SecurityService._();
  SecurityService._();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Check if device supports biometrics
  Future<bool> get canCheckBiometrics async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  // Trigger Biometric Prompt
  Future<bool> authenticate() async {
    try {
      _isAuthenticated = await _auth.authenticate(
        localizedReason: 'Scan fingerprint to unlock your Medicine Cabinet',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN fallback
        ),
      );
      return _isAuthenticated;
    } on PlatformException {
      return false;
    }
  }

  // Store a simplified 4-digit PIN for non-biometric devices
  Future<void> setAppPin(String pin) async {
    await _storage.write(key: 'app_pin', value: pin);
  }

  Future<bool> verifyAppPin(String pin) async {
    final storedPin = await _storage.read(key: 'app_pin');
    if (storedPin == null) return true; // No PIN set yet
    return storedPin == pin;
  }
}
