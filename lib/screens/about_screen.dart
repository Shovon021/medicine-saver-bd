import 'package:flutter/material.dart';
import '../config/theme.dart';

/// About screen showing app info and database stats
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryAccent,
                    child: const Icon(Icons.medical_services, size: 50, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // App Name
            Text(
              'Medicine Saver BD',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            
            // Version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Find affordable medicine alternatives',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSubtle,
              ),
            ),
            const SizedBox(height: 32),
            
            // Database Stats
            _buildSectionTitle(context, 'Database Statistics'),
            const SizedBox(height: 12),
            _buildStatsCard(context),
            const SizedBox(height: 24),
            
            // Data Source
            _buildSectionTitle(context, 'Data Source'),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.source,
              title: 'Kaggle Medicine Dataset',
              subtitle: 'Comprehensive Bangladesh medicine database',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.update,
              title: 'Last Updated',
              subtitle: 'December 2024',
            ),
            const SizedBox(height: 24),
            
            // Features
            _buildSectionTitle(context, 'Features'),
            const SizedBox(height: 12),
            _buildFeaturesList(context),
            const SizedBox(height: 32),
            
            // Made in Bangladesh
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Made with '),
                Icon(Icons.favorite, color: Colors.red.shade400, size: 18),
                const Text(' in Bangladesh 🇧🇩'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textHeading,
        ),
      ),
    );
  }
  
  Widget _buildStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatItem('21,591', 'Medicines', Icons.medication)),
              Expanded(child: _buildStatItem('1,661', 'Generics', Icons.science)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('232', 'Manufacturers', Icons.factory)),
              Expanded(child: _buildStatItem('99.7%', 'Verified', Icons.verified)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryAccent, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeading,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: AppColors.textSubtle, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      'Search 21,000+ medicines',
      'Find generic alternatives',
      'Compare prices & save money',
      'Voice search support',
      'Medicine reminders',
      'Drug interaction checker',
      'Pharmacy locator',
      'My Cabinet (bookmarks)',
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: features.map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Text(feature),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
