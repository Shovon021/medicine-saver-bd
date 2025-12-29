import 'dart:math';

/// A simple fuzzy search utility using Levenshtein Distance algorithm.
/// Handles typos like "Paracitamol" -> "Paracetamol".
class FuzzySearch {
  /// Calculates the Levenshtein distance between two strings.
  /// Lower distance = more similar strings.
  static int levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    List<int> prev = List.generate(s2.length + 1, (i) => i);
    List<int> curr = List.filled(s2.length + 1, 0);

    for (int i = 1; i <= s1.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1,      // Deletion
          curr[j - 1] + 1,  // Insertion
          prev[j - 1] + cost // Substitution
        ].reduce(min);
      }
      List<int> temp = prev;
      prev = curr;
      curr = temp;
    }

    return prev[s2.length];
  }

  /// Calculates similarity score between 0.0 and 1.0.
  /// 1.0 = exact match, 0.0 = completely different.
  static double similarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    int maxLen = max(s1.length, s2.length);
    int distance = levenshteinDistance(s1, s2);
    return 1.0 - (distance / maxLen);
  }

  /// Finds the best matches from a list of candidates.
  /// Returns candidates with similarity score >= threshold, sorted by score.
  static List<FuzzyMatch> findMatches(
    String query,
    List<String> candidates, {
    double threshold = 0.6,
    int maxResults = 10,
  }) {
    if (query.isEmpty) return [];

    List<FuzzyMatch> matches = [];

    for (String candidate in candidates) {
      double score = similarity(query, candidate);
      
      // Also check if the candidate contains the query (for partial matches)
      if (candidate.toLowerCase().contains(query.toLowerCase())) {
        score = max(score, 0.8); // Boost substring matches
      }
      
      if (score >= threshold) {
        matches.add(FuzzyMatch(candidate: candidate, score: score));
      }
    }

    // Sort by score descending
    matches.sort((a, b) => b.score.compareTo(a.score));

    // Limit results
    return matches.take(maxResults).toList();
  }

  /// Phonetic matching for Bangla transliteration.
  /// Maps common English phonetic spellings to Bengali equivalents.
  static final Map<String, List<String>> _phoneticMap = {
    'napa': ['নাপা', 'napa', 'naapa'],
    'paracetamol': ['প্যারাসিটামল', 'paracitamol', 'paracetamole', 'paracitamole'],
    'sergel': ['সার্জেল', 'sergal', 'sargel'],
    'maxpro': ['ম্যাক্সপ্রো', 'maxpro', 'max pro'],
    'omeprazole': ['ওমেপ্রাজল', 'omeprazol', 'omeprazole'],
    'esomeprazole': ['এসোমেপ্রাজল', 'esomeprazol', 'esomiprazole'],
    'seclo': ['সেক্লো', 'seklo', 'secllo'],
    'amlodipine': ['অ্যামলোডিপিন', 'amlodipin', 'amlodipyne'],
    'metformin': ['মেটফরমিন', 'metformine', 'metphormin'],
    'aspirin': ['অ্যাসপিরিন', 'asprin', 'asperin'],
  };

  /// Expands a query to include phonetic variations.
  static List<String> expandPhonetic(String query) {
    String normalized = query.toLowerCase().trim();
    Set<String> variations = {normalized};

    _phoneticMap.forEach((canonical, aliases) {
      if (aliases.any((alias) => alias.toLowerCase() == normalized) ||
          canonical == normalized) {
        variations.addAll(aliases);
        variations.add(canonical);
      }
    });

    return variations.toList();
  }
}

/// Represents a fuzzy match result with candidate and similarity score.
class FuzzyMatch {
  final String candidate;
  final double score;

  FuzzyMatch({required this.candidate, required this.score});

  @override
  String toString() => 'FuzzyMatch($candidate, ${(score * 100).toStringAsFixed(1)}%)';
}
