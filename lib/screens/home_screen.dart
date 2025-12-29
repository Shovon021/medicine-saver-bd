import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../widgets/medicine_card.dart';
import '../widgets/shimmer_loading.dart';
import '../services/voice_search_service.dart'; // RE-ENABLED with native Android intent
// import '../services/prescription_scanner_service.dart'; // DISABLED
import 'interaction_checker_screen.dart';
import 'cabinet_screen.dart';
import 'reminder_screen.dart';
import 'pharmacy_locator_screen.dart';
import 'health_tips_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../services/cabinet_service.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isListening = false;

  // Real search results from database
  List<Brand> _searchResults = [];
  List<Brand> _filteredResults = []; // Filtered by strength
  bool _isLoading = false;
  String? _currentGenericName;
  int _savingsPercent = 0;
  
  // Strength filter
  List<String> _availableStrengths = [];
  String? _selectedStrength;
  
  // Category (Dosage Form) filter
  List<String> _availableCategories = [];
  String? _selectedCategory;
  
  // Recent Searches (#5)
  List<String> _recentSearches = [];
  static const String _recentSearchesKey = 'recent_searches';
  
  // Sort Options (#7)
  String _sortOption = 'price_asc'; // Default: Price Low to High

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query); // Remove if exists (to move to top)
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.take(5).toList();
    }
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
    setState(() {});
  }

  void _applySorting() {
    setState(() {
      switch (_sortOption) {
        case 'price_asc':
          _filteredResults.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          break;
        case 'price_desc':
          _filteredResults.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          break;
        case 'name_asc':
          _filteredResults.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
      }
    });
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _currentGenericName = null;
        _savingsPercent = 0;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _isLoading = true;
    });
    
    try {
      // Use smart search to get ALL alternatives by generic
      final results = await DatabaseHelper.instance.searchWithAlternatives(query);
      
      // Calculate savings if we have results with prices
      int savings = 0;
      String? genericName;
      if (results.isNotEmpty) {
        genericName = results.first.genericName;
        final prices = results.where((b) => b.price != null && b.price! > 0).map((b) => b.price!).toList();
        if (prices.length >= 2) {
          final highest = prices.reduce((a, b) => a > b ? a : b);
          final lowest = prices.reduce((a, b) => a < b ? a : b);
          savings = ((highest - lowest) / highest * 100).round();
        }
      }
      
      setState(() {
        _searchResults = results;
        _filteredResults = List.from(results); // Copy for sorting
        _availableStrengths = DatabaseHelper.getUniqueStrengths(results);
        _availableCategories = _getUniqueCategories(results);
        _selectedStrength = null; // Reset filter
        _selectedCategory = null; // Reset category filter
        _currentGenericName = genericName;
        _savingsPercent = savings;
        _isLoading = false;
      });
      
      // Save to recent searches and apply sort
      if (results.isNotEmpty) {
        _saveRecentSearch(query);
      }
      _applySorting();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  void _applyStrengthFilter(String? strength) {
    setState(() {
      _selectedStrength = strength;
      _applyFilters();
    });
  }

  void _applyCategoryFilter(String? category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    var results = List<Brand>.from(_searchResults);
    
    if (_selectedStrength != null) {
      results = results.where((b) => b.strength == _selectedStrength).toList();
    }
    
    if (_selectedCategory != null) {
      results = results.where((b) => b.dosageForm == _selectedCategory).toList();
    }
    
    _filteredResults = results;
    _applySorting();
  }

  List<String> _getUniqueCategories(List<Brand> brands) {
    final categories = brands
        .where((b) => b.dosageForm != null && b.dosageForm!.isNotEmpty)
        .map((b) => b.dosageForm!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<void> _addToCabinet(Brand brand) async {
    final savedMedicine = SavedMedicine(
      brandName: brand.name,
      genericName: brand.genericName ?? '',
      manufacturer: brand.manufacturerName ?? '',
      strength: brand.strength ?? '',
      dosageForm: brand.dosageForm ?? '',
      price: brand.price ?? 0.0,
    );
    
    await CabinetService.instance.addMedicine(savedMedicine);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${brand.name} added to Cabinet'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CabinetScreen()),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _startVoiceSearch() async {
    // Voice search using Android's built-in speech recognition
    setState(() => _isListening = true);
    
    try {
      final result = await VoiceSearchService.instance.startListening();
      
      if (result != null && result.isNotEmpty && mounted) {
        final query = VoiceSearchService.extractSearchQuery(result);
        _searchController.text = query;
        _onSearch(query);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No speech detected. Try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isListening = false);
    }
  }

  Future<void> _scanPrescription() async {
    _showScanOptions();
  }

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan Prescription',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo or choose from gallery to extract medicine names',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSubtle,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildScanOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      // DISABLED: Scanner feature removed
                      // final result = await PrescriptionScannerService.instance.scanFromCamera();
                      // _handleScanResult(result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Scanner feature temporarily disabled')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildScanOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      // DISABLED: Scanner feature removed
                      // final result = await PrescriptionScannerService.instance.scanFromGallery();
                      // _handleScanResult(result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Scanner feature temporarily disabled')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primaryAccent),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  // _showScanBottomSheet and related methods

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Image.asset('assets/logo.jpg', height: 40),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Medicine Saver',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 26,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Interaction Checker Button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InteractionCheckerScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.health_and_safety_outlined),
                          tooltip: 'Drug Interaction Checker',
                        ),
                        // Health Tips Button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HealthTipsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lightbulb_outline),
                          tooltip: 'Health Tips',
                        ),
                        // Profile / Login Button
                        ListenableBuilder(
                          listenable: AuthService.instance,
                          builder: (context, _) {
                            final user = AuthService.instance.currentUser;
                            return IconButton(
                              onPressed: () {
                                if (user == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  );
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(child: Text(user.name[0])),
                                          title: Text(user.name),
                                          subtitle: Text(user.email),
                                        ),
                                        const Divider(),
                                        ListTile(
                                          leading: const Icon(Icons.info_outline),
                                          title: const Text('About Developer'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            showAboutDialog(
                                              context: context,
                                              applicationName: 'Medicine Saver BD',
                                              applicationVersion: '1.0.0',
                                              applicationIcon: const Icon(Icons.medical_services, size: 40),
                                              children: [
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'Developed by:\n\nSarfaraz Ahamed Shovon',
                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'Helping Bangladesh find affordable medicines.',
                                                    textAlign: TextAlign.center,
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.logout, color: Colors.red),
                                          title: const Text('Logout', style: TextStyle(color: Colors.red)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            AuthService.instance.signOut();
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  );
                                }
                              },
                              icon: user == null
                                  ? const Icon(Icons.account_circle_outlined)
                                  : CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.primaryAccent,
                                      child: Text(
                                        user.name[0],
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                              tooltip: user == null ? 'Login' : 'Profile',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find affordable alternatives instantly',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSubtle,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions Row 1
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.document_scanner_outlined,
                        label: 'Scan Prescription',
                        onTap: _scanPrescription,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.health_and_safety_outlined,
                        label: 'Interactions',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InteractionCheckerScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Quick Actions Row 2
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.medication_liquid_outlined,
                        label: 'My Cabinet',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CabinetScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.alarm,
                        label: 'Reminders',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReminderScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.local_pharmacy_outlined,
                        label: 'Pharmacy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PharmacyLocatorScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Glassmorphism Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.8) ?? AppColors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          width: 1.0,
                        ),
                        boxShadow: [
                            BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Search medicine name (English/বাংলা)',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textSubtle,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  color: AppColors.textSubtle,
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearch('');
                                  },
                                )
                              : null,
                          // Override defaults for glass effect
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Results Section with Staggered Animation
            if (_isSearching) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _currentGenericName != null 
                              ? 'Alternatives for $_currentGenericName'
                              : 'Alternatives Found',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_savingsPercent > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Save up to $_savingsPercent%',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Strength Filter Chips
              if (_availableStrengths.length > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedStrength == null,
                            onSelected: (_) => _applyStrengthFilter(null),
                            selectedColor: AppColors.primaryAccent.withValues(alpha: 0.2),
                          ),
                          const SizedBox(width: 8),
                          ..._availableStrengths.map((strength) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(strength),
                              selected: _selectedStrength == strength,
                              onSelected: (_) => _applyStrengthFilter(strength),
                              selectedColor: AppColors.primaryAccent.withValues(alpha: 0.2),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              // Category (Dosage Form) Filter Chips
              if (_availableCategories.length > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Icon(Icons.medical_services_outlined, size: 16, color: AppColors.textSubtle),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('All Forms'),
                            selected: _selectedCategory == null,
                            onSelected: (_) => _applyCategoryFilter(null),
                            selectedColor: AppColors.success.withValues(alpha: 0.2),
                          ),
                          const SizedBox(width: 8),
                          ..._availableCategories.map((category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (_) => _applyCategoryFilter(category),
                              selectedColor: AppColors.success.withValues(alpha: 0.2),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Sort by: ',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSubtle,
                        ),
                      ),
                      PopupMenuButton<String>(
                        initialValue: _sortOption,
                        onSelected: (value) {
                          setState(() => _sortOption = value);
                          _applySorting();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'price_asc',
                            child: Text('Price: Low to High'),
                          ),
                          const PopupMenuItem(
                            value: 'price_desc',
                            child: Text('Price: High to Low'),
                          ),
                          const PopupMenuItem(
                            value: 'name_asc',
                            child: Text('Name (A-Z)'),
                          ),
                        ],
                        child: Row(
                          children: [
                            Text(
                              _sortOption == 'price_asc' ? 'Price ↑' :
                              _sortOption == 'price_desc' ? 'Price ↓' : 'Name',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primaryAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: AppColors.primaryAccent),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: _isLoading
                    ? const SliverToBoxAdapter(
                        child: ShimmerLoadingList(itemCount: 4),
                      )
                    : _filteredResults.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 80,
                                      color: AppColors.textSubtle.withValues(alpha: 0.2),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'No medicines found',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: AppColors.textSubtle,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try searching for another brand or generic name',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textSubtle.withValues(alpha: 0.7),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final brand = _filteredResults[index];
                                final isCheapest = index == 0; // First result is cheapest (sorted by price ASC)
                                // Staggered Animation Wrapper
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: MedicineCard(
                                        brandName: brand.name,
                                        genericName: brand.genericName ?? 'Unknown',
                                        manufacturer: brand.manufacturerName ?? 'Unknown',
                                        strength: brand.strength ?? '',
                                        dosageForm: brand.dosageForm ?? '',
                                        price: brand.price ?? 0.0,
                                        packSize: brand.packSize,
                                        isCheapest: isCheapest,
                                        isVerified: brand.verified,
                                        onAddToCabinet: () => _addToCabinet(brand),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _filteredResults.length,
                            ),
                          ),
              ),
            ] else ...[
              // Empty State / Welcome
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 80,
                        color: AppColors.textSubtle.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search for any medicine',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSubtle,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find cheaper bio-equivalent alternatives',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSubtle.withValues(alpha: 0.7),
                            ),
                      ),
                      // Recent Searches (#5)
                      if (_recentSearches.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Recent Searches',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textSubtle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _recentSearches.map((query) => ActionChip(
                            label: Text(query),
                            onPressed: () {
                              _searchController.text = query;
                              _onSearch(query);
                            },
                            avatar: const Icon(Icons.history, size: 16),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      // Voice Search FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _startVoiceSearch,
        backgroundColor: _isListening ? Colors.red : AppColors.primaryAccent,
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primaryAccent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textHeading,
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
