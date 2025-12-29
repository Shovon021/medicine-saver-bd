/// Service for checking drug-drug interactions and contraindications.
/// 
/// IMPORTANT: This is a simplified demonstration. In a production app,
/// this should be backed by a comprehensive medical database or API.
class DrugInteractionService {
  static final DrugInteractionService instance = DrugInteractionService._init();
  
  DrugInteractionService._init();

  /// Known drug interactions database (simplified).
  /// In production, this would come from a medical database or API.
  static final Map<String, List<Interaction>> _interactionDatabase = {
    'warfarin': [
      Interaction(
        drug: 'aspirin',
        severity: InteractionSeverity.severe,
        description: 'Increased risk of bleeding. Combined use significantly increases bleeding risk.',
        recommendation: 'Avoid combination or use with extreme caution under medical supervision.',
      ),
      Interaction(
        drug: 'ibuprofen',
        severity: InteractionSeverity.severe,
        description: 'NSAIDs increase bleeding risk when combined with warfarin.',
        recommendation: 'Avoid NSAIDs. Consider acetaminophen as alternative.',
      ),
      Interaction(
        drug: 'vitamin k',
        severity: InteractionSeverity.moderate,
        description: 'Vitamin K can reduce the effectiveness of warfarin.',
        recommendation: 'Maintain consistent vitamin K intake.',
      ),
    ],
    'aspirin': [
      Interaction(
        drug: 'warfarin',
        severity: InteractionSeverity.severe,
        description: 'Increased risk of bleeding.',
        recommendation: 'Avoid combination unless specifically prescribed.',
      ),
      Interaction(
        drug: 'ibuprofen',
        severity: InteractionSeverity.moderate,
        description: 'May reduce the cardioprotective effects of aspirin.',
        recommendation: 'Take aspirin at least 30 minutes before ibuprofen.',
      ),
      Interaction(
        drug: 'methotrexate',
        severity: InteractionSeverity.severe,
        description: 'Aspirin can increase methotrexate toxicity.',
        recommendation: 'Avoid high-dose aspirin with methotrexate.',
      ),
    ],
    'metformin': [
      Interaction(
        drug: 'alcohol',
        severity: InteractionSeverity.moderate,
        description: 'Increased risk of lactic acidosis.',
        recommendation: 'Limit alcohol consumption.',
      ),
      Interaction(
        drug: 'contrast dye',
        severity: InteractionSeverity.severe,
        description: 'Risk of kidney damage when combined with iodinated contrast.',
        recommendation: 'Stop metformin before and after contrast procedures.',
      ),
    ],
    'omeprazole': [
      Interaction(
        drug: 'clopidogrel',
        severity: InteractionSeverity.moderate,
        description: 'Omeprazole may reduce the effectiveness of clopidogrel.',
        recommendation: 'Consider alternative PPI like pantoprazole.',
      ),
      Interaction(
        drug: 'methotrexate',
        severity: InteractionSeverity.moderate,
        description: 'May increase methotrexate levels.',
        recommendation: 'Monitor for methotrexate toxicity.',
      ),
    ],
    'amlodipine': [
      Interaction(
        drug: 'simvastatin',
        severity: InteractionSeverity.moderate,
        description: 'Increased risk of muscle problems (myopathy).',
        recommendation: 'Limit simvastatin to 20mg daily when combined.',
      ),
      Interaction(
        drug: 'grapefruit',
        severity: InteractionSeverity.mild,
        description: 'Grapefruit can increase amlodipine levels.',
        recommendation: 'Avoid large amounts of grapefruit.',
      ),
    ],
    'ciprofloxacin': [
      Interaction(
        drug: 'antacids',
        severity: InteractionSeverity.moderate,
        description: 'Antacids reduce ciprofloxacin absorption.',
        recommendation: 'Take ciprofloxacin 2 hours before antacids.',
      ),
      Interaction(
        drug: 'theophylline',
        severity: InteractionSeverity.severe,
        description: 'May increase theophylline toxicity.',
        recommendation: 'Monitor theophylline levels closely.',
      ),
    ],
  };

  /// Checks for interactions between a list of drugs.
  InteractionCheckResult checkInteractions(List<String> drugNames) {
    final List<InteractionWarning> warnings = [];
    final normalizedDrugs = drugNames.map((d) => _normalize(d)).toList();

    // Check each pair of drugs
    for (int i = 0; i < normalizedDrugs.length; i++) {
      for (int j = i + 1; j < normalizedDrugs.length; j++) {
        final drug1 = normalizedDrugs[i];
        final drug2 = normalizedDrugs[j];

        // Check if drug1 interacts with drug2
        final interactions1 = _interactionDatabase[drug1];
        if (interactions1 != null) {
          for (final interaction in interactions1) {
            if (_normalize(interaction.drug) == drug2) {
              warnings.add(InteractionWarning(
                drug1: drugNames[i],
                drug2: drugNames[j],
                interaction: interaction,
              ));
            }
          }
        }

        // Check reverse (drug2 interacts with drug1) if not already found
        final interactions2 = _interactionDatabase[drug2];
        if (interactions2 != null) {
          for (final interaction in interactions2) {
            if (_normalize(interaction.drug) == drug1) {
              // Check if we already have this warning
              final exists = warnings.any((w) =>
                  (w.drug1 == drugNames[i] && w.drug2 == drugNames[j]) ||
                  (w.drug1 == drugNames[j] && w.drug2 == drugNames[i]));
              if (!exists) {
                warnings.add(InteractionWarning(
                  drug1: drugNames[j],
                  drug2: drugNames[i],
                  interaction: interaction,
                ));
              }
            }
          }
        }
      }
    }

    // Sort by severity
    warnings.sort((a, b) => b.interaction.severity.index.compareTo(a.interaction.severity.index));

    return InteractionCheckResult(
      hasSevereInteractions: warnings.any((w) => w.interaction.severity == InteractionSeverity.severe),
      hasModerateInteractions: warnings.any((w) => w.interaction.severity == InteractionSeverity.moderate),
      warnings: warnings,
    );
  }

  /// Normalizes a drug name for matching.
  String _normalize(String name) {
    // Remove common suffixes and normalize
    String normalized = name.toLowerCase().trim();
    
    // Remove strength indicators
    normalized = normalized.replaceAll(RegExp(r'\d+\s*(mg|mcg|ml|gm|iu|%)'), '');
    
    // Remove common forms
    normalized = normalized.replaceAll(RegExp(r'\s*(tablet|capsule|syrup|injection|drops)s?'), '');
    
    return normalized.trim();
  }
}

/// Severity levels for drug interactions.
enum InteractionSeverity {
  mild,
  moderate,
  severe,
}

/// Represents a known drug interaction.
class Interaction {
  final String drug;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  const Interaction({
    required this.drug,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
}

/// Represents a warning for a specific drug pair.
class InteractionWarning {
  final String drug1;
  final String drug2;
  final Interaction interaction;

  const InteractionWarning({
    required this.drug1,
    required this.drug2,
    required this.interaction,
  });
}

/// Result of checking multiple drugs for interactions.
class InteractionCheckResult {
  final bool hasSevereInteractions;
  final bool hasModerateInteractions;
  final List<InteractionWarning> warnings;

  const InteractionCheckResult({
    required this.hasSevereInteractions,
    required this.hasModerateInteractions,
    required this.warnings,
  });

  bool get hasAnyInteractions => warnings.isNotEmpty;
  bool get isSafe => warnings.isEmpty;
}
