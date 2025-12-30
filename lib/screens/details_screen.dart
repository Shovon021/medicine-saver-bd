import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/theme.dart';
import '../widgets/medicine_card.dart';
import '../widgets/report_price_sheet.dart';
import '../services/price_report_service.dart';
import '../models/price_report.dart';
import '../models/brand.dart';
import '../services/auth_service.dart';

/// Displays full details for a medicine, alternatives, and savings calculator.
class DetailsScreen extends StatefulWidget {
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
  final String? heroTag;
  final int? brandId; // Added ID for reporting

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
    this.brandId,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // Sample alternatives for UI demo (unchanged logic)
  List<Map<String, dynamic>> get _alternatives => [
    {
      'brandName': 'Esoral 20',
      'genericName': widget.genericName,
      'manufacturer': 'Square Pharma',
      'strength': widget.strength,
      'dosageForm': widget.dosageForm,
      'price': 6.00,
      'isCheapest': true,
    },
    {
      'brandName': 'Sergel 20',
      'genericName': widget.genericName,
      'manufacturer': 'Healthcare Pharma',
      'strength': widget.strength,
      'dosageForm': widget.dosageForm,
      'price': 7.50,
      'isCheapest': false,
    },
    {
      'brandName': 'Nexium 20',
      'genericName': widget.genericName,
      'manufacturer': 'AstraZeneca',
      'strength': widget.strength,
      'dosageForm': widget.dosageForm,
      'price': 25.00,
      'isCheapest': false,
    },
  ];

  double get _cheapestPrice =>
      _alternatives.map((e) => e['price'] as double).reduce((a, b) => a < b ? a : b);

  double get _savingsPercentage {
    if (widget.price <= _cheapestPrice) return 0;
    return ((widget.price - _cheapestPrice) / widget.price * 100);
  }

  // Reporting State
  List<PriceReport> _reports = [];
  bool _isLoadingReports = false;
  double? _averageStreetPrice;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoadingReports = true);
    final reports = await PriceReportService.instance.getReportsForMedicine(widget.brandName);
    final avgPrice = await PriceReportService.instance.getAveragePrice(widget.brandName);
    
    if (mounted) {
      setState(() {
        _reports = reports;
        _averageStreetPrice = avgPrice;
        _isLoadingReports = false;
      });
    }
  }

  void _showReportDialog(BuildContext context) async {
    if (!AuthService.instance.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to report prices.')),
      );
      return;
    }

    final brand = Brand(
        id: widget.brandId ?? 0,
        name: widget.brandName,
        genericId: 0, // Not needed for this context
        manufacturerId: 0,
        strength: widget.strength,
        dosageForm: widget.dosageForm,
        price: widget.price,
        packSize: widget.packSize,
    );

    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportPriceSheet(brand: brand),
    );

    if (result == true) {
      _loadReports(); // Refresh data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicine Details'),
        actions: [
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
            _buildHeaderCard(context),
            const SizedBox(height: 24),

            if (_savingsPercentage > 0) ...[
              _buildSavingsCard(context),
              const SizedBox(height: 24),
            ],

            // NEW: Community Reports Section
            _buildCommunitySection(context),
            const SizedBox(height: 24),

            _buildInfoSection(context),
            const SizedBox(height: 24),

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportDialog(context),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Report Price'),
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    if (_isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const FaIcon(FontAwesomeIcons.users, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('No community reports yet.', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Be the first to report the real street price!', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Community Reports', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_averageStreetPrice != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Average Street Price:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '৳${_averageStreetPrice!.toStringAsFixed(2)}', 
                    style: TextStyle(
                      color: AppColors.success, 
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final report = _reports[index];
            final savings = widget.price - report.pricePaid;
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 2, offset: const Offset(0, 1)),
                ],
              ),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
                     child: const FaIcon(FontAwesomeIcons.user, size: 12, color: Colors.white),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Paid ৳${report.pricePaid.toStringAsFixed(2)}',
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                         ),
                         Text(
                           '${report.pharmacyName?.isNotEmpty == true ? report.pharmacyName : 'Pharmacy'} • ${report.locationArea?.isNotEmpty == true ? report.locationArea : 'Unknown Area'}',
                           style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                         ),
                       ],
                     ),
                   ),
                   if (savings > 0)
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                         color: Colors.green.withValues(alpha: 0.2),
                         borderRadius: BorderRadius.circular(4),
                       ),
                       child: Text(
                         'Saved ৳${savings.toStringAsFixed(0)}',
                         style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                       ),
                     ),
                ],
              ),
            );
          },
        ),
      ],
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
                child: widget.heroTag != null
                    ? Hero(
                        tag: widget.heroTag!,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            widget.brandName,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 24,
                                ),
                          ),
                        ),
                      )
                    : Text(
                        widget.brandName,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 24,
                            ),
                      ),
              ),
              if (widget.isVerified)
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
              widget.genericName,
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
              _buildInfoChip(context, FontAwesomeIcons.building, widget.manufacturer),
              const SizedBox(width: 12),
              _buildInfoChip(context, FontAwesomeIcons.ruler, widget.strength),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(context, FontAwesomeIcons.tablets, widget.dosageForm),
              if (widget.packSize != null) ...[
                const SizedBox(width: 12),
                _buildInfoChip(context, FontAwesomeIcons.boxOpen, widget.packSize!),
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
                '৳${widget.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textHeading,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          // Last Updated
          if (widget.lastUpdated != null) ...[
            const SizedBox(height: 8),
            Text(
              'Price updated: ${_formatDate(widget.lastUpdated!)}',
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
        if (widget.indication != null && widget.indication!.isNotEmpty) ...[
          Text(
            'Indication',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.indication!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
        ],
        if (widget.sideEffects != null && widget.sideEffects!.isNotEmpty) ...[
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
                    widget.sideEffects!,
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
