import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';

/// Screen for finding nearby pharmacies using Google Maps.
class PharmacyLocatorScreen extends StatefulWidget {
  const PharmacyLocatorScreen({super.key});

  @override
  State<PharmacyLocatorScreen> createState() => _PharmacyLocatorScreenState();
}

class _PharmacyLocatorScreenState extends State<PharmacyLocatorScreen> {
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  // Sample pharmacy data for Bangladesh
  // In production, this would come from Google Places API or a local database
  final List<Pharmacy> _nearbyPharmacies = [
    Pharmacy(
      name: 'Lazz Pharma',
      address: 'House 12, Road 5, Dhanmondi, Dhaka',
      distance: 0.5,
      rating: 4.5,
      phone: '01711-123456',
      isOpen: true,
    ),
    Pharmacy(
      name: 'Square Pharmacy',
      address: 'Mirpur Road, Dhaka',
      distance: 1.2,
      rating: 4.3,
      phone: '01712-234567',
      isOpen: true,
    ),
    Pharmacy(
      name: 'Apollo Pharmacy',
      address: 'Gulshan Circle 2, Dhaka',
      distance: 2.1,
      rating: 4.7,
      phone: '01713-345678',
      isOpen: false,
    ),
    Pharmacy(
      name: 'Medicine Corner',
      address: 'Mohammadpur, Dhaka',
      distance: 3.5,
      rating: 4.0,
      phone: '01714-456789',
      isOpen: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled. Please enable GPS.';
          _isLoading = false;
        });
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission permanently denied. Please enable in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
        // In production, would fetch nearby pharmacies based on position
      });
    } catch (e) {
      setState(() {
        _error = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openInMaps(Pharmacy pharmacy) async {
    final query = Uri.encodeComponent('${pharmacy.name} pharmacy ${pharmacy.address}');
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  Future<void> _searchNearbyPharmacies() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Getting your location...')),
      );
      await _getCurrentLocation();
      return;
    }

    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;
    final url = 'https://www.google.com/maps/search/pharmacy/@$lat,$lng,15z';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPharmacy(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Pharmacy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Location Status Banner
          _buildLocationBanner(),

          // Search in Maps Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _searchNearbyPharmacies,
                icon: const Icon(Icons.map),
                label: const Text('Open in Google Maps'),
              ),
            ),
          ),

          // Pharmacy List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _buildPharmacyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBanner() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: AppColors.primaryAccent.withValues(alpha: 0.1),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Getting your location...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_currentPosition != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: AppColors.success.withValues(alpha: 0.1),
        child: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Location found! Showing nearby pharmacies.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _nearbyPharmacies.length,
      itemBuilder: (context, index) {
        final pharmacy = _nearbyPharmacies[index];
        return _buildPharmacyCard(pharmacy);
      },
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openInMaps(pharmacy),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pharmacy.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pharmacy.isOpen
                            ? AppColors.success.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pharmacy.isOpen ? 'Open' : 'Closed',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: pharmacy.isOpen ? AppColors.success : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSubtle),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pharmacy.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSubtle,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Distance
                    Icon(Icons.directions_walk, size: 16, color: AppColors.primaryAccent),
                    const SizedBox(width: 4),
                    Text(
                      '${pharmacy.distance} km',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 16),
                    // Rating
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      pharmacy.rating.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    // Call Button
                    IconButton(
                      icon: const Icon(Icons.phone_outlined),
                      color: AppColors.primaryAccent,
                      onPressed: () => _callPharmacy(pharmacy.phone),
                      tooltip: 'Call',
                    ),
                    // Directions Button
                    IconButton(
                      icon: const Icon(Icons.directions_outlined),
                      color: AppColors.primaryAccent,
                      onPressed: () => _openInMaps(pharmacy),
                      tooltip: 'Directions',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Represents a pharmacy location.
class Pharmacy {
  final String name;
  final String address;
  final double distance;
  final double rating;
  final String phone;
  final bool isOpen;

  Pharmacy({
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.phone,
    required this.isOpen,
  });
}
