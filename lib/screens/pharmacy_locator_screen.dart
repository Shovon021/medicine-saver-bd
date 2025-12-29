import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';

/// Pharmacy Locator Screen - Opens Google Maps to find nearby pharmacies
/// Uses url_launcher instead of heavy geolocator dependency
class PharmacyLocatorScreen extends StatefulWidget {
  const PharmacyLocatorScreen({super.key});

  @override
  State<PharmacyLocatorScreen> createState() => _PharmacyLocatorScreenState();
}

class _PharmacyLocatorScreenState extends State<PharmacyLocatorScreen> {
  bool _isLoading = false;

  Future<void> _openNearbyPharmacies() async {
    setState(() => _isLoading = true);
    
    // Open Google Maps with pharmacy search
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/pharmacy+near+me');
    
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Google Maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchPharmacyByArea(String area) async {
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/pharmacy+in+$area+Bangladesh');
    
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Pharmacy'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main CTA Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 64,
                      color: AppColors.primaryAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Find Pharmacies Near You',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Opens Google Maps to show pharmacies in your area',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSubtle),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _openNearbyPharmacies,
                        icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.map),
                        label: Text(_isLoading ? 'Opening...' : 'Open Google Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Popular Areas Section
            Text(
              'Or search by area:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Dhaka',
                'Chittagong',
                'Sylhet',
                'Rajshahi',
                'Khulna',
                'Gazipur',
                'Gulshan',
                'Dhanmondi',
                'Mirpur',
                'Uttara',
              ].map((area) => ActionChip(
                label: Text(area),
                avatar: const Icon(Icons.local_pharmacy, size: 18),
                onPressed: () => _searchPharmacyByArea(area),
              )).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Pharmacy Chains
            Text(
              'Popular Pharmacy Chains:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildPharmacyChainTile('Lazz Pharma', 'lazz+pharma'),
            _buildPharmacyChainTile('Drug International', 'drug+international+pharmacy'),
            _buildPharmacyChainTile('Model Pharmacy', 'model+pharmacy+bangladesh'),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyChainTile(String name, String searchTerm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.1),
          child: Icon(Icons.local_pharmacy, color: AppColors.primaryAccent),
        ),
        title: Text(name),
        subtitle: const Text('Find locations'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final Uri uri = Uri.parse('https://www.google.com/maps/search/$searchTerm');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
