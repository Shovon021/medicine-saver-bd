import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/drug_interaction_service.dart';

/// Screen for checking drug-drug interactions.
class InteractionCheckerScreen extends StatefulWidget {
  const InteractionCheckerScreen({super.key});

  @override
  State<InteractionCheckerScreen> createState() => _InteractionCheckerScreenState();
}

class _InteractionCheckerScreenState extends State<InteractionCheckerScreen> {
  final List<String> _selectedDrugs = [];
  final TextEditingController _drugController = TextEditingController();
  InteractionCheckResult? _result;

  // Sample drug suggestions
  final List<String> _suggestions = [
    'Warfarin', 'Aspirin', 'Ibuprofen', 'Metformin', 'Omeprazole',
    'Amlodipine', 'Simvastatin', 'Ciprofloxacin', 'Clopidogrel',
    'Methotrexate', 'Paracetamol', 'Napa', 'Sergel', 'Maxpro',
  ];

  void _addDrug(String drug) {
    if (drug.trim().isEmpty) return;
    if (!_selectedDrugs.contains(drug.trim())) {
      setState(() {
        _selectedDrugs.add(drug.trim());
        _drugController.clear();
        _result = null; // Clear previous result
      });
    }
  }

  void _removeDrug(String drug) {
    setState(() {
      _selectedDrugs.remove(drug);
      _result = null;
    });
  }

  void _checkInteractions() {
    if (_selectedDrugs.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 2 medicines to check interactions'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _result = DrugInteractionService.instance.checkInteractions(_selectedDrugs);
    });
  }

  @override
  void dispose() {
    _drugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interaction Checker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Check Drug Interactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add two or more medicines to check if they can be taken together safely.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSubtle,
                  ),
            ),
            const SizedBox(height: 24),

            // Drug Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _drugController,
                    decoration: const InputDecoration(
                      hintText: 'Enter medicine name',
                      prefixIcon: Icon(Icons.medication_outlined),
                    ),
                    onSubmitted: _addDrug,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: () => _addDrug(_drugController.text),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions
                  .where((s) => !_selectedDrugs.contains(s))
                  .take(6)
                  .map((drug) => ActionChip(
                        label: Text(drug),
                        onPressed: () => _addDrug(drug),
                        backgroundColor: AppColors.surface,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Selected Drugs
            if (_selectedDrugs.isNotEmpty) ...[
              Text(
                'Selected Medicines (${_selectedDrugs.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedDrugs
                    .map((drug) => Chip(
                          label: Text(drug),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeDrug(drug),
                          backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.1),
                          labelStyle: TextStyle(color: AppColors.primaryAccent),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Check Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checkInteractions,
                  icon: const Icon(Icons.health_and_safety_outlined),
                  label: const Text('Check Interactions'),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Results
            if (_result != null) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_result!.isSafe) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Known Interactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.success,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'These medicines appear safe to take together based on our database.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
        // Warning Header
        if (_result!.hasSevereInteractions)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'SEVERE interactions found! Consult a doctor before combining.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

        Text(
          'Interaction Warnings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Warning Cards
        ..._result!.warnings.map((warning) => _buildWarningCard(warning)),
      ],
    );
  }

  Widget _buildWarningCard(InteractionWarning warning) {
    final Color severityColor = switch (warning.interaction.severity) {
      InteractionSeverity.severe => Colors.red,
      InteractionSeverity.moderate => Colors.orange,
      InteractionSeverity.mild => Colors.yellow.shade700,
    };

    final String severityText = switch (warning.interaction.severity) {
      InteractionSeverity.severe => 'SEVERE',
      InteractionSeverity.moderate => 'MODERATE',
      InteractionSeverity.mild => 'MILD',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withValues(alpha: 0.3)),
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
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  '${warning.drug1} + ${warning.drug2}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severityText,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            warning.interaction.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: AppColors.primaryAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning.interaction.recommendation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryAccent,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
