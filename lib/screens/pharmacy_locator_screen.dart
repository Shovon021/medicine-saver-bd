import 'package:flutter/material.dart';

// DISABLED for APK build - geolocator dependency removed
class PharmacyLocatorScreen extends StatefulWidget {
  const PharmacyLocatorScreen({super.key});

  @override
  State<PharmacyLocatorScreen> createState() => _PharmacyLocatorScreenState();
}

class _PharmacyLocatorScreenState extends State<PharmacyLocatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Locator'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Pharmacy Locator',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'This feature is temporarily disabled\nto ensure app compatibility.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
