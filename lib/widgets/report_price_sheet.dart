import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/brand.dart';
import '../services/price_report_service.dart';

class ReportPriceSheet extends StatefulWidget {
  final Brand brand;

  const ReportPriceSheet({super.key, required this.brand});

  @override
  State<ReportPriceSheet> createState() => _ReportPriceSheetState();
}

class _ReportPriceSheetState extends State<ReportPriceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _pharmacyController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _pharmacyController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final price = double.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final success = await PriceReportService.instance.submitReport(
      medicineId: widget.brand.id,
      medicineName: widget.brand.name,
      pricePaid: price,
      mrp: widget.brand.price,
      pharmacyName: _pharmacyController.text.trim(),
      locationArea: _locationController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true); // Return true to refresh parent
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you! Price reported successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit report. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Title
              Text(
                'Report Price for ${widget.brand.name}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccent,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Help others save money by reporting the price you paid.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSubtle,
                    ),
              ),
              const SizedBox(height: 24),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Price Input
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Price Paid (Tk)',
                        hintText: 'e.g. 20.0',
                        prefixIcon: const Icon(Icons.currency_exchange),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Pharmacy Name
                    TextFormField(
                      controller: _pharmacyController,
                      decoration: InputDecoration(
                        labelText: 'Pharmacy Name (Optional)',
                        hintText: 'e.g. Lazz Pharma',
                        prefixIcon: const Icon(Icons.store_outlined),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Area / Location (Optional)',
                        hintText: 'e.g. Dhanmondi',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit Report',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
