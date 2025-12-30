import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/theme.dart';
import '../screens/details_screen.dart';

/// A premium-styled card displaying medicine information.
class MedicineCard extends StatelessWidget {
  final String brandName;
  final String genericName;
  final String manufacturer;
  final String strength;
  final String dosageForm;
  final double price;
  final String? packSize;
  final bool isCheapest;
  final bool isVerified; // True = real price, False = estimated price
  final VoidCallback? onAddToCabinet;
  
  // Trusted manufacturers in Bangladesh (#6)
  static const Set<String> _trustedManufacturers = {
    'Square', 'Beximco', 'Incepta', 'Renata', 'ACI', 'Eskayef', 'Opsonin',
    'Healthcare', 'Aristopharma', 'Acme', 'Drug International', 'Ibn Sina',
    'Popular', 'Navana', 'General', 'Globe', 'Nuvista', 'Sanofi', 'GSK',
  };

  const MedicineCard({
    super.key,
    required this.brandName,
    required this.genericName,
    required this.manufacturer,
    required this.strength,
    required this.dosageForm,
    required this.price,
    this.packSize,
    this.isCheapest = false,
    this.isVerified = false,
    this.onAddToCabinet,
  });
  
  bool get _isTrustedManufacturer {
    return _trustedManufacturers.any(
      (trusted) => manufacturer.toLowerCase().contains(trusted.toLowerCase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            Color.lerp(AppColors.surface, AppColors.primaryAccent, 0.03)!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: isCheapest
            ? Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 1.5)
            : Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  heroTag: '${brandName}_$strength',
                  brandName: brandName,
                  genericName: genericName,
                  manufacturer: manufacturer,
                  strength: strength,
                  dosageForm: dosageForm,
                  price: price,
                  indication: 'Used for treating acid reflux, heartburn, and GERD.',
                  sideEffects: 'Headache, nausea, diarrhea, abdominal pain.',
                  lastUpdated: DateTime(2025, 12, 1),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Name + Badge
                      Row(
                        children: [
                          Flexible(
                            child: Hero(
                              tag: '${brandName}_$strength',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  brandName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          if (isCheapest) ...[
                            const SizedBox(width: 8),
                            _PulseBadge(
                              child: Text(
                                'Best Price',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: AppColors.success,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Generic Name
                      Text(
                        genericName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Manufacturer & Details
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.building,
                            size: 12,
                            color: AppColors.textSubtle,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              manufacturer,
                              style: Theme.of(context).textTheme.labelLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Trusted Manufacturer Badge (#6)
                          if (_isTrustedManufacturer) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: AppColors.primaryAccent,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dosageForm - $strength',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.textSubtle.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),

                // Right: Price + Add Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${price.toStringAsFixed(2)} Tk',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isCheapest
                                ? AppColors.success
                                : AppColors.textHeading,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      packSize != null && packSize!.isNotEmpty
                          ? 'Pack: $packSize'
                          : 'per unit',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 11,
                            color: AppColors.textSubtle,
                          ),
                    ),
                    const SizedBox(height: 4),
                    // Price Verification Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVerified 
                          ? AppColors.success.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified ? Icons.verified : Icons.warning_amber_rounded,
                            size: 10,
                            color: isVerified ? AppColors.success : Colors.orange,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isVerified ? 'Verified' : 'Est.',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isVerified ? AppColors.success : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (onAddToCabinet != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onAddToCabinet,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primaryAccent,
                    tooltip: 'Add to Cabinet',
                    iconSize: 28,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline pulsing badge widget for "Best Price" label.
class _PulseBadge extends StatefulWidget {
  final Widget child;

  const _PulseBadge({required this.child});

  @override
  State<_PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<_PulseBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
