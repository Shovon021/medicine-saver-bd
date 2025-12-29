import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/theme.dart';
import '../services/health_tips_service.dart';

/// Screen displaying health tips and awareness content.
class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  TipCategory? _selectedCategory;
  late HealthTip _tipOfTheDay;
  late List<HealthTip> _displayedTips;

  @override
  void initState() {
    super.initState();
    _tipOfTheDay = HealthTipsService.instance.getTipOfTheDay();
    _displayedTips = HealthTipsService.instance.getAllTips();
  }

  void _filterByCategory(TipCategory? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null) {
        _displayedTips = HealthTipsService.instance.getAllTips();
      } else {
        _displayedTips = HealthTipsService.instance.getTipsByCategory(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tips'),
      ),
      body: CustomScrollView(
        slivers: [
          // Tip of the Day
          SliverToBoxAdapter(
            child: _buildTipOfTheDay(),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: _buildCategoryFilter(),
          ),

          // Tips List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTipCard(_displayedTips[index]),
                childCount: _displayedTips.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipOfTheDay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryAccent,
            AppColors.primaryAccent.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Tip of the Day',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FaIcon(
                _tipOfTheDay.icon,
                size: 32,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _tipOfTheDay.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _tipOfTheDay.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(null, 'All', FontAwesomeIcons.layerGroup),
          ...TipCategory.values.map(
            (category) => _buildCategoryChip(
              category,
              category.displayName,
              category.icon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(TipCategory? category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: FaIcon(
          icon,
          size: 14,
          color: isSelected ? AppColors.primaryAccent : AppColors.textSubtle,
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _filterByCategory(category),
        selectedColor: AppColors.primaryAccent.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primaryAccent,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryAccent : AppColors.textBody,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primaryAccent : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildTipCard(HealthTip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTipDetails(tip),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(tip.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      tip.icon,
                      size: 20,
                      color: _getCategoryColor(tip.category),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSubtle,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSubtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(TipCategory category) {
    switch (category) {
      case TipCategory.general:
        return Colors.red;
      case TipCategory.medicine:
        return Colors.blue;
      case TipCategory.nutrition:
        return Colors.green;
      case TipCategory.exercise:
        return Colors.orange;
      case TipCategory.mental:
        return Colors.purple;
      case TipCategory.local:
        return Colors.teal;
    }
  }

  void _showTipDetails(HealthTip tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Icon & Category
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(tip.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: FaIcon(
                        tip.icon,
                        size: 28,
                        color: _getCategoryColor(tip.category),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(tip.category).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tip.category.displayName,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: _getCategoryColor(tip.category),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Content
              Text(
                tip.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 24),
              // Share Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share This Tip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
