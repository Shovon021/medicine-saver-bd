import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../services/database_update_service.dart';

/// Developer credits screen
class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  bool _isChecking = false;

  Future<void> _checkUpdate() async {
    setState(() => _isChecking = true);

    try {
      final currentVersion = await DatabaseUpdateService.instance.getLocalVersion();
      if (!mounted) return;
      
      final newVersion = await DatabaseUpdateService.instance.checkForUpdate();
      
      if (!mounted) return;
      setState(() => _isChecking = false);

      if (newVersion != null && newVersion > currentVersion) {
        // Update available
        _showUpdateDialog(newVersion);
      } else {
        // No update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database is up to date!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking updates: $e')),
      );
    }
  }

  Future<void> _showUpdateDialog(int newVersion) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text('A new medicine database version ($newVersion) is available. Download now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _performUpdate(newVersion);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _performUpdate(int newVersion) async {
    setState(() => _isChecking = true);
    
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await DatabaseUpdateService.instance.downloadUpdate(newVersion);
    
    if (!mounted) return;
    Navigator.pop(context); // Close progress dialog
    setState(() => _isChecking = false);

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Database updated successfully! Please restart the app to see changes.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Developer Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAccent,
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // Developer Name
            Text(
              'Sarfaraz Ahamed Shovon',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mobile App Developer',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSubtle,
              ),
            ),
            const SizedBox(height: 32),

            // Database Management Section (New)
            _buildSectionTitle(context, 'Database Management'),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.system_update,
              title: 'Check for Updates',
              subtitle: _isChecking ? 'Checking...' : 'Download latest medicine prices',
              isLoading: _isChecking,
              onTap: _isChecking ? () {} : _checkUpdate,
            ),
            const SizedBox(height: 32),
            
            // Contact Links
            _buildSectionTitle(context, 'Contact Me'),
            const SizedBox(height: 12),
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: 'sarfaraz.sovon@gmail.com',
              onTap: () => _launchUrl('mailto:sarfaraz.sovon@gmail.com'),
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              context,
              icon: Icons.facebook,
              title: 'Facebook',
              subtitle: 'facebook.com/sarfaraz.shovon',
              onTap: () => _launchUrl('https://www.facebook.com/share/1Jp7V63tgf/'),
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              context,
              icon: Icons.code,
              title: 'GitHub',
              subtitle: 'github.com/Shovon021',
              onTap: () => _launchUrl('https://github.com/Shovon021'),
            ),
            const SizedBox(height: 32),
            
            // Technologies Used
            _buildSectionTitle(context, 'Technologies Used'),
            const SizedBox(height: 12),
            _buildTechGrid(context),
            const SizedBox(height: 32),
            
            // Special Thanks
            _buildSectionTitle(context, 'Special Thanks'),
            const SizedBox(height: 12),
            _buildThanksCard(context),
            const SizedBox(height: 32),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAccent.withValues(alpha: 0.1),
                    AppColors.success.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Made with '),
                      Icon(Icons.favorite, color: Colors.red.shade400, size: 18),
                      const Text(' in Bangladesh 🇧🇩'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 Medicine Saver BD\nAll Rights Reserved',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
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
  
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading 
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryAccent))
                : Icon(icon, color: AppColors.primaryAccent),
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
            if (!isLoading)
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                  Text(subtitle, style: TextStyle(color: AppColors.primaryAccent, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTechGrid(BuildContext context) {
    final techs = [
      {'name': 'Flutter', 'icon': Icons.flutter_dash},
      {'name': 'Dart', 'icon': Icons.code},
      {'name': 'SQLite', 'icon': Icons.storage},
      {'name': 'Supabase', 'icon': Icons.cloud},
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: techs.map((tech) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tech['icon'] as IconData, color: AppColors.primaryAccent),
            ),
            const SizedBox(height: 8),
            Text(
              tech['name'] as String,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        )).toList(),
      ),
    );
  }
  
  Widget _buildThanksCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThankItem('Kaggle', 'Medicine dataset'),
          _buildThankItem('Flutter Team', 'Amazing framework'),
          _buildThankItem('Open Source Community', 'Libraries & tools'),
        ],
      ),
    );
  }
  
  Widget _buildThankItem(String name, String contribution) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.star, color: AppColors.secondaryAccent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: AppColors.textBody),
                children: [
                  TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: ' - $contribution'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
