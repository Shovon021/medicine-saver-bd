import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/theme.dart';
import '../services/prescription_scanner_service.dart';

import '../services/database_helper.dart';
import '../models/models.dart';
import 'details_screen.dart';


class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = false;

  List<Map<String, dynamic>> _matchedMedicines = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Prescription Scanner'),
      ),
      body: Column(
        children: [
          // SCANNER AREA
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/scan_overlay.png'), // Placeholder
                opacity: 0.3,
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isScanning)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 60, color: Colors.white),
                    onPressed: _startScan,
                  ),
                const SizedBox(height: 10),
                Text(
                  _isScanning ? 'Processing...' : 'Tap to Scan Prescription',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          // RESULTS AREA
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected Medicines',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  if (_matchedMedicines.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        itemCount: _matchedMedicines.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final med = _matchedMedicines[index];
                          return Card(
                            child: ListTile(
                              leading: FaIcon(FontAwesomeIcons.pills, color: AppColors.primaryAccent),
                              title: Text(med['brand_name'] ?? 'Unknown'),
                              subtitle: Text(med['generic_name'] ?? ''),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                final brand = med['brand'] as Brand;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(
                                      brandName: brand.name,
                                      genericName: brand.genericName ?? '',
                                      manufacturer: brand.manufacturerName ?? '',
                                      strength: brand.strength ?? '',
                                      dosageForm: brand.dosageForm ?? '',
                                      price: brand.price ?? 0.0,
                                      packSize: brand.packSize,
                                      isVerified: brand.verified,
                                      indication: null, // Will be fetched in details
                                      sideEffects: null,
                                      brandId: brand.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.filePrescription, size: 40, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No medicines found yet.\nTake a clear photo of the box or list.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    
    // 1. Scan image
    final texts = await PrescriptionScannerService.instance.scanPrescription();
    
    // 2. Search DB (Real fuzzy search)
    List<Map<String, dynamic>> matches = [];
    
    try {
      for (String text in texts) {
        // Search DB for each recognized line
        final brands = await DatabaseHelper.instance.searchBrands(text);
        if (brands.isNotEmpty) {
           // We found a medicine! Add the best match to results
           final bestMatch = brands.first;
           matches.add({
             'brand': bestMatch, // Full object for navigation
             'brand_name': bestMatch.name,
             'generic_name': bestMatch.genericName,
             'confidence': 'High'
           });
        }
      }
    } catch (e) {
      debugPrint('DB Search Error: $e');
    }

    if (mounted) {
      setState(() {
        _matchedMedicines = matches;
        _isScanning = false;
      });
    }
  }
}
