import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service for checking drug-drug interactions using OpenFDA API.
/// 
/// Uses the free OpenFDA Drug Label API to fetch real interaction data.
/// Falls back to local cache for common interactions when offline.
class DrugInteractionService {
  static final DrugInteractionService instance = DrugInteractionService._init();
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.fda.gov/drug/label.json',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  // Cache to avoid repeated API calls
  final Map<String, DrugLabelInfo> _cache = {};
  
  DrugInteractionService._init();

  /// Checks for interactions between a list of drugs using OpenFDA.
  Future<InteractionCheckResult> checkInteractions(List<String> drugNames) async {
    final List<InteractionWarning> warnings = [];
    final normalizedDrugs = drugNames.map((d) => _normalize(d)).toList();

    // First, fetch label info for each drug
    final Map<String, DrugLabelInfo> drugLabels = {};
    
    for (int i = 0; i < normalizedDrugs.length; i++) {
      final drugName = normalizedDrugs[i];
      try {
        final labelInfo = await _fetchDrugLabel(drugName);
        if (labelInfo != null) {
          drugLabels[drugNames[i]] = labelInfo;
        }
      } catch (e) {
        debugPrint('Failed to fetch label for $drugName: $e');
      }
    }

    // Now cross-check: does drug A's interaction text mention drug B?
    for (int i = 0; i < drugNames.length; i++) {
      final drug1 = drugNames[i];
      final label1 = drugLabels[drug1];
      
      if (label1 == null || label1.interactionText.isEmpty) continue;
      
      for (int j = i + 1; j < drugNames.length; j++) {
        final drug2 = drugNames[j];
        final drug2Normalized = normalizedDrugs[j];
        
        // Check if drug2 is mentioned in drug1's interaction warnings
        if (_containsDrugMention(label1.interactionText, drug2Normalized)) {
          warnings.add(InteractionWarning(
            drug1: drug1,
            drug2: drug2,
            interaction: Interaction(
              drug: drug2,
              severity: _inferSeverity(label1.interactionText, drug2Normalized),
              description: _extractRelevantText(label1.interactionText, drug2Normalized),
              recommendation: 'Consult your doctor or pharmacist before combining these medications.',
              source: 'FDA Drug Label',
            ),
          ));
        }
        
        // Also check reverse (drug1 mentioned in drug2's interactions)
        final label2 = drugLabels[drug2];
        if (label2 != null && _containsDrugMention(label2.interactionText, normalizedDrugs[i])) {
          // Avoid duplicates
          final exists = warnings.any((w) =>
              (w.drug1 == drug1 && w.drug2 == drug2) ||
              (w.drug1 == drug2 && w.drug2 == drug1));
          if (!exists) {
            warnings.add(InteractionWarning(
              drug1: drug2,
              drug2: drug1,
              interaction: Interaction(
                drug: drug1,
                severity: _inferSeverity(label2.interactionText, normalizedDrugs[i]),
                description: _extractRelevantText(label2.interactionText, normalizedDrugs[i]),
                recommendation: 'Consult your doctor or pharmacist before combining these medications.',
                source: 'FDA Drug Label',
              ),
            ));
          }
        }
      }
    }

    // If no API results, fall back to local database
    if (warnings.isEmpty) {
      return _checkLocalInteractions(drugNames);
    }

    // Sort by severity
    warnings.sort((a, b) => b.interaction.severity.index.compareTo(a.interaction.severity.index));

    return InteractionCheckResult(
      hasSevereInteractions: warnings.any((w) => w.interaction.severity == InteractionSeverity.severe),
      hasModerateInteractions: warnings.any((w) => w.interaction.severity == InteractionSeverity.moderate),
      warnings: warnings,
      source: 'OpenFDA',
    );
  }

  /// Fetches drug label information from OpenFDA API.
  Future<DrugLabelInfo?> _fetchDrugLabel(String drugName) async {
    // Check cache first
    if (_cache.containsKey(drugName)) {
      return _cache[drugName];
    }
    
    try {
      final response = await _dio.get('', queryParameters: {
        'search': 'openfda.generic_name:"$drugName" OR openfda.brand_name:"$drugName"',
        'limit': 1,
      });
      
      if (response.statusCode == 200 && response.data['results'] != null) {
        final results = response.data['results'] as List;
        if (results.isNotEmpty) {
          final label = results.first;
          
          // Extract interaction text from various possible fields
          String interactionText = '';
          
          if (label['drug_interactions'] != null) {
            interactionText += (label['drug_interactions'] as List).join(' ');
          }
          if (label['warnings'] != null) {
            interactionText += ' ${(label['warnings'] as List).join(' ')}';
          }
          if (label['precautions'] != null) {
            interactionText += ' ${(label['precautions'] as List).join(' ')}';
          }
          
          final info = DrugLabelInfo(
            genericName: drugName,
            interactionText: interactionText.toLowerCase(),
          );
          
          _cache[drugName] = info;
          return info;
        }
      }
    } on DioException catch (e) {
      debugPrint('OpenFDA API error: ${e.message}');
      // Fall back to local on network error
    }
    
    return null;
  }

  /// Checks if the interaction text mentions a specific drug.
  bool _containsDrugMention(String text, String drugName) {
    final lowerText = text.toLowerCase();
    final lowerDrug = drugName.toLowerCase();
    
    // Check for exact word match or common variations
    return lowerText.contains(lowerDrug) ||
           lowerText.contains(lowerDrug.replaceAll(' ', '')) ||
           _drugAliases[lowerDrug]?.any((alias) => lowerText.contains(alias)) == true;
  }

  /// Infers severity from the interaction text context.
  InteractionSeverity _inferSeverity(String text, String drugName) {
    final lowerText = text.toLowerCase();
    
    // Look for severity indicators near the drug mention
    final severeKeywords = ['contraindicated', 'do not use', 'avoid', 'serious', 'fatal', 'death', 'life-threatening'];
    final moderateKeywords = ['caution', 'monitor', 'may increase', 'may decrease', 'adjust dose'];
    
    for (final keyword in severeKeywords) {
      if (lowerText.contains(keyword)) {
        return InteractionSeverity.severe;
      }
    }
    
    for (final keyword in moderateKeywords) {
      if (lowerText.contains(keyword)) {
        return InteractionSeverity.moderate;
      }
    }
    
    return InteractionSeverity.mild;
  }

  /// Extracts a relevant snippet of text around the drug mention.
  String _extractRelevantText(String fullText, String drugName) {
    final lowerText = fullText.toLowerCase();
    final index = lowerText.indexOf(drugName.toLowerCase());
    
    if (index == -1) {
      return 'Potential interaction detected. Check with your pharmacist.';
    }
    
    // Extract ~200 chars around the mention
    final start = (index - 100).clamp(0, fullText.length);
    final end = (index + 100).clamp(0, fullText.length);
    
    String snippet = fullText.substring(start, end).trim();
    if (start > 0) snippet = '...$snippet';
    if (end < fullText.length) snippet = '$snippet...';
    
    return snippet;
  }

  /// Normalizes a drug name for matching.
  String _normalize(String name) {
    String normalized = name.toLowerCase().trim();
    normalized = normalized.replaceAll(RegExp(r'\d+\s*(mg|mcg|ml|gm|iu|%)'), '');
    normalized = normalized.replaceAll(RegExp(r'\s*(tablet|capsule|syrup|injection|drops)s?'), '');
    return normalized.trim();
  }

  /// Common drug name aliases for better matching.
  static const Map<String, List<String>> _drugAliases = {
    'aspirin': ['acetylsalicylic acid', 'asa'],
    'paracetamol': ['acetaminophen', 'tylenol'],
    'ibuprofen': ['advil', 'motrin'],
    'omeprazole': ['prilosec'],
    'metformin': ['glucophage'],
    'amlodipine': ['norvasc'],
    'warfarin': ['coumadin'],
  };

  /// Fallback: Check against local hardcoded database when offline.
  InteractionCheckResult _checkLocalInteractions(List<String> drugNames) {
    final List<InteractionWarning> warnings = [];
    final normalizedDrugs = drugNames.map((d) => _normalize(d)).toList();

    for (int i = 0; i < normalizedDrugs.length; i++) {
      for (int j = i + 1; j < normalizedDrugs.length; j++) {
        final drug1 = normalizedDrugs[i];
        final drug2 = normalizedDrugs[j];

        final interactions = _localInteractionDatabase[drug1];
        if (interactions != null) {
          for (final interaction in interactions) {
            if (_normalize(interaction.drug) == drug2) {
              warnings.add(InteractionWarning(
                drug1: drugNames[i],
                drug2: drugNames[j],
                interaction: interaction,
              ));
            }
          }
        }
      }
    }

    warnings.sort((a, b) => b.interaction.severity.index.compareTo(a.interaction.severity.index));

    return InteractionCheckResult(
      hasSevereInteractions: warnings.any((w) => w.interaction.severity == InteractionSeverity.severe),
      hasModerateInteractions: warnings.any((w) => w.interaction.severity == InteractionSeverity.moderate),
      warnings: warnings,
      source: 'Local Database (Offline)',
    );
  }

  /// Local fallback database for common interactions.
  static final Map<String, List<Interaction>> _localInteractionDatabase = {
    'warfarin': [
      Interaction(
        drug: 'aspirin',
        severity: InteractionSeverity.severe,
        description: 'Increased risk of bleeding. Combined use significantly increases bleeding risk.',
        recommendation: 'Avoid combination or use with extreme caution under medical supervision.',
        source: 'Local Database',
      ),
      Interaction(
        drug: 'ibuprofen',
        severity: InteractionSeverity.severe,
        description: 'NSAIDs increase bleeding risk when combined with warfarin.',
        recommendation: 'Avoid NSAIDs. Consider acetaminophen as alternative.',
        source: 'Local Database',
      ),
    ],
    'metformin': [
      Interaction(
        drug: 'alcohol',
        severity: InteractionSeverity.moderate,
        description: 'Increased risk of lactic acidosis.',
        recommendation: 'Limit alcohol consumption.',
        source: 'Local Database',
      ),
    ],
    'omeprazole': [
      Interaction(
        drug: 'clopidogrel',
        severity: InteractionSeverity.moderate,
        description: 'Omeprazole may reduce the effectiveness of clopidogrel.',
        recommendation: 'Consider alternative PPI like pantoprazole.',
        source: 'Local Database',
      ),
    ],
  };
}

/// Cached drug label information.
class DrugLabelInfo {
  final String genericName;
  final String interactionText;

  DrugLabelInfo({
    required this.genericName,
    required this.interactionText,
  });
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
  final String source;

  const Interaction({
    required this.drug,
    required this.severity,
    required this.description,
    required this.recommendation,
    this.source = 'Unknown',
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
  final String source;

  const InteractionCheckResult({
    required this.hasSevereInteractions,
    required this.hasModerateInteractions,
    required this.warnings,
    this.source = 'Unknown',
  });

  bool get hasAnyInteractions => warnings.isNotEmpty;
  bool get isSafe => warnings.isEmpty;
}
