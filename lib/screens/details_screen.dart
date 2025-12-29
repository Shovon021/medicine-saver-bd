import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/theme.dart';
import '../widgets/medicine_card.dart';

/// Displays full details for a medicine, alternatives, and savings calculator.
class DetailsScreen extends StatelessWidget {
  final String brandName;
  final String genericName;
  final String manufacturer;
  final String strength;
  final String dosageForm;
  final double price;
  final String? packSize;
  final String? indication;
  final String? sideEffects;
  final bool isVerified;
  final DateTime? lastUpdated;
  final String? heroTag; // Added for Hero Animation

  const DetailsScreen({
    super.key,
    required this.brandName,
    required this.genericName,
    required this.manufacturer,
    required this.strength,
    required this.dosageForm,
    required this.price,
    this.packSize,
    this.indication,
    this.sideEffects,
    this.isVerified = true,
    this.lastUpdated,
    this.heroTag,
  });

  // Sample alternatives for UI demo
  List<Map<String, dynamic>> get _alternatives => [
        {
          'brandName': 'Esoral 20',
          'genericName': genericName,
          'manufacturer': 'Square Pharma',
          'strength': strength,
          'dosageForm': dosageForm,
          'price': 6.00,
          'isCheapest': true,
        },
        {
          'brandName': 'Sergel 20',
          'genericName': genericName,
          'manufacturer': 'Healthcare Pharma',
          'strength': strength,
          'dosageForm': dosageForm,
          'price': 7.50,
          'isCheapest': false,
        },
        {
          'brandName': 'Nexium 20',
          'genericName': genericName,
          'manufacturer': 'AstraZeneca',
          'strength': strength,
          'dosageForm': dosageForm,
          'price': 25.00,
          'isCheapest': false,
        },
      ];

  double get _cheapestPrice =>
      _alternatives.map((e) => e['price'] as double).reduce((a, b) => a < b ? a : b);

  double get _savingsPercentage {
    if (price <= _cheapestPrice) return 0;
    return ((price - _cheapestPrice) / price * 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicine Details'),
        actions: [
          // Report Price Button
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.flag, size: 18),
            tooltip: 'Report Incorrect Price',
            onPressed: () => _showReportDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(context),
            const SizedBox(height: 24),

            // Savings Calculator
            if (_savingsPercentage > 0) ...[
              _buildSavingsCard(context),
              const SizedBox(height: 24),
            ],

            // Medical Info Section
            _buildInfoSection(context),
            const SizedBox(height: 24),

            // Alternatives List
            Text(
              'Bio-Equivalent Alternatives',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._alternatives.map((med) => MedicineCard(
                  brandName: med['brandName'],
                  genericName: med['genericName'],
                  manufacturer: med['manufacturer'],
                  strength: med['strength'],
                  dosageForm: med['dosageForm'],
                  price: med['price'],
                  isCheapest: med['isCheapest'],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Name + Verified Badge
          Row(
            children: [
              Expanded(
                child: heroTag != null
                    ? Hero(
                        tag: heroTag!,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            brandName,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 24,
                                ),
                          ),
                        ),
                      )
                    : Text(
                        brandName,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 24,
                            ),
                      ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.circleCheck,
                        size: 14,
                        color: AppColors.primaryAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Generic Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              genericName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // Details Grid
          Row(
            children: [
              _buildInfoChip(context, FontAwesomeIcons.building, manufacturer),
              const SizedBox(width: 12),
              _buildInfoChip(context, FontAwesomeIcons.ruler, strength),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(context, FontAwesomeIcons.tablets, dosageForm),
              if (packSize != null) ...[
                const SizedBox(width: 12),
                _buildInfoChip(context, FontAwesomeIcons.boxOpen, packSize!),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unit Price',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                '৳${price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textHeading,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          // Last Updated
          if (lastUpdated != null) ...[
            const SizedBox(height: 8),
            Text(
              'Price updated: ${_formatDate(lastUpdated!)}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 11,
                    color: AppColors.textSubtle,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 12, color: AppColors.textSubtle),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.1),
            AppColors.success.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.piggyBank,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You can save ${_savingsPercentage.toStringAsFixed(0)}%!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Switch to ${_alternatives.firstWhere((e) => e['isCheapest'] == true)['brandName']} at ৳${_cheapestPrice.toStringAsFixed(2)}/unit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textBody,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (indication != null && indication!.isNotEmpty) ...[
          Text(
            'Indication',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            indication!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
        ],
        if (sideEffects != null && sideEffects!.isNotEmpty) ...[
          Text(
            'Side Effects',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.orange.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.orange.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sideEffects!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Incorrect Price',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Help us keep prices accurate. If you\'ve seen a different price in the market, let us know.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSubtle,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Correct Price (৳)',
                hintText: 'e.g., 8.50',
                prefixIcon: const FaIcon(FontAwesomeIcons.moneyBillWave, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Where did you see this price?',
                prefixIcon: const FaIcon(FontAwesomeIcons.noteSticky, size: 18),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you! Your report has been submitted.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Submit Report'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
