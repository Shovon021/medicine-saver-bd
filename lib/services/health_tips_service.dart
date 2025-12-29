import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Service for providing health tips and awareness content.
class HealthTipsService {
  static final HealthTipsService instance = HealthTipsService._init();

  HealthTipsService._init();

  /// Get all health tips.
  List<HealthTip> getAllTips() => _healthTips;

  /// Get tip of the day (based on current date).
  HealthTip getTipOfTheDay() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _healthTips[dayOfYear % _healthTips.length];
  }

  /// Get tips by category.
  List<HealthTip> getTipsByCategory(TipCategory category) {
    return _healthTips.where((tip) => tip.category == category).toList();
  }

  /// Sample health tips data.
  static final List<HealthTip> _healthTips = [
    // General Health
    HealthTip(
      id: 1,
      title: 'Stay Hydrated',
      content: 'Drink at least 8 glasses of water daily. Proper hydration helps maintain body temperature, removes waste, and lubricates joints.',
      category: TipCategory.general,
      icon: FontAwesomeIcons.glassWater,
    ),
    HealthTip(
      id: 2,
      title: 'Get Enough Sleep',
      content: 'Adults need 7-9 hours of sleep per night. Quality sleep improves memory, reduces stress, and strengthens immunity.',
      category: TipCategory.general,
      icon: FontAwesomeIcons.bed,
    ),
    HealthTip(
      id: 3,
      title: 'Wash Your Hands',
      content: 'Wash hands with soap for at least 20 seconds. This simple habit prevents the spread of germs and infections.',
      category: TipCategory.general,
      icon: FontAwesomeIcons.handsBubbles,
    ),

    // Medicine Safety
    HealthTip(
      id: 4,
      title: 'Complete Your Course',
      content: 'Always complete the full course of antibiotics as prescribed. Stopping early can lead to antibiotic resistance.',
      category: TipCategory.medicine,
      icon: FontAwesomeIcons.pills,
    ),
    HealthTip(
      id: 5,
      title: 'Check Expiry Dates',
      content: 'Never take expired medications. Expired drugs may be less effective or even harmful.',
      category: TipCategory.medicine,
      icon: FontAwesomeIcons.calendarXmark,
    ),
    HealthTip(
      id: 6,
      title: 'Store Medicines Properly',
      content: 'Keep medicines in a cool, dry place away from sunlight. Some may need refrigeration - check the label.',
      category: TipCategory.medicine,
      icon: FontAwesomeIcons.houseMedical,
    ),
    HealthTip(
      id: 7,
      title: 'Read the Label',
      content: 'Always read medicine labels for dosage, warnings, and interactions. Ask your pharmacist if unsure.',
      category: TipCategory.medicine,
      icon: FontAwesomeIcons.clipboardList,
    ),

    // Nutrition
    HealthTip(
      id: 8,
      title: 'Eat More Vegetables',
      content: 'Fill half your plate with vegetables. They provide essential vitamins, minerals, and fiber for good health.',
      category: TipCategory.nutrition,
      icon: FontAwesomeIcons.carrot,
    ),
    HealthTip(
      id: 9,
      title: 'Limit Sugar Intake',
      content: 'Reduce consumption of sugary drinks and snacks. Excess sugar can lead to obesity, diabetes, and heart disease.',
      category: TipCategory.nutrition,
      icon: FontAwesomeIcons.candyCane,
    ),
    HealthTip(
      id: 10,
      title: 'Eat Breakfast Daily',
      content: 'A healthy breakfast kickstarts your metabolism and provides energy for the day. Include protein and fiber.',
      category: TipCategory.nutrition,
      icon: FontAwesomeIcons.mugHot,
    ),

    // Exercise
    HealthTip(
      id: 11,
      title: 'Walk 30 Minutes Daily',
      content: 'A daily 30-minute walk reduces heart disease risk, improves mood, and helps maintain healthy weight.',
      category: TipCategory.exercise,
      icon: FontAwesomeIcons.personWalking,
    ),
    HealthTip(
      id: 12,
      title: 'Take Stretch Breaks',
      content: 'If you sit for long periods, take a 5-minute stretch break every hour to prevent muscle stiffness.',
      category: TipCategory.exercise,
      icon: FontAwesomeIcons.personPraying, // Closest to stretching/yoga
    ),

    // Mental Health
    HealthTip(
      id: 13,
      title: 'Practice Deep Breathing',
      content: 'When stressed, take 5 slow deep breaths. This activates your relaxation response and reduces anxiety.',
      category: TipCategory.mental,
      icon: FontAwesomeIcons.lungs,
    ),
    HealthTip(
      id: 14,
      title: 'Limit Screen Time',
      content: 'Take regular breaks from screens and avoid them before bed. Blue light can disrupt sleep patterns.',
      category: TipCategory.mental,
      icon: FontAwesomeIcons.mobileScreenButton,
    ),
    HealthTip(
      id: 15,
      title: 'Stay Connected',
      content: 'Maintain social connections with family and friends. Social support is crucial for mental wellbeing.',
      category: TipCategory.mental,
      icon: FontAwesomeIcons.peopleGroup,
    ),

    // Bangladesh Specific
    HealthTip(
      id: 16,
      title: 'Prevent Dengue',
      content: 'Remove stagnant water from around your home. Use mosquito nets and repellents, especially during monsoon.',
      category: TipCategory.local,
      icon: FontAwesomeIcons.mosquito,
    ),
    HealthTip(
      id: 17,
      title: 'Safe Drinking Water',
      content: 'Always drink filtered or boiled water. Waterborne diseases are common - prevention is key.',
      category: TipCategory.local,
      icon: FontAwesomeIcons.faucetDrip,
    ),
    HealthTip(
      id: 18,
      title: 'Avoid Street Food Risks',
      content: 'Choose street food carefully. Look for vendors who maintain hygiene and cook food thoroughly.',
      category: TipCategory.local,
      icon: FontAwesomeIcons.bowlFood,
    ),
  ];
}

/// Categories for health tips.
enum TipCategory {
  general,
  medicine,
  nutrition,
  exercise,
  mental,
  local,
}

/// Extension for category display names.
extension TipCategoryExtension on TipCategory {
  String get displayName {
    switch (this) {
      case TipCategory.general:
        return 'General Health';
      case TipCategory.medicine:
        return 'Medicine Safety';
      case TipCategory.nutrition:
        return 'Nutrition';
      case TipCategory.exercise:
        return 'Exercise';
      case TipCategory.mental:
        return 'Mental Health';
      case TipCategory.local:
        return 'Local Health';
    }
  }

  IconData get icon {
    switch (this) {
      case TipCategory.general:
        return FontAwesomeIcons.heartPulse;
      case TipCategory.medicine:
        return FontAwesomeIcons.prescriptionBottleMedical;
      case TipCategory.nutrition:
        return FontAwesomeIcons.appleWhole;
      case TipCategory.exercise:
        return FontAwesomeIcons.personRunning;
      case TipCategory.mental:
        return FontAwesomeIcons.brain;
      case TipCategory.local:
        return FontAwesomeIcons.locationDot;
    }
  }
}

/// Represents a health tip.
class HealthTip {
  final int id;
  final String title;
  final String content;
  final TipCategory category;
  final IconData icon;

  const HealthTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.icon,
  });
}
