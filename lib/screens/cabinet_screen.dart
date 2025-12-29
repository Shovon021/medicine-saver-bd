import 'package:flutter/material.dart';
import '../services/security_service.dart'; // RE-ENABLED with PIN-based security
import '../services/backup_service.dart';
import '../services/cabinet_service.dart';
import '../config/theme.dart';
import '../widgets/medicine_card.dart';

/// Screen displaying user's saved medicines ("My Cabinet").
class CabinetScreen extends StatefulWidget {
  const CabinetScreen({super.key});

  @override
  State<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends State<CabinetScreen> {
  bool _isLoading = true;
  bool _isLocked = true; // Default to locked state
  List<SavedMedicine> _medicines = [];

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    // Check if PIN is enabled
    final pinEnabled = await SecurityService.instance.isPinEnabled();
    
    if (!pinEnabled) {
      // No PIN set, allow access directly
      setState(() => _isLocked = false);
      _loadMedicines();
      return;
    }
    
    // Show PIN dialog
    if (mounted) {
      final verified = await _showPinDialog();
      if (verified) {
        setState(() => _isLocked = false);
        _loadMedicines();
      } else if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<bool> _showPinDialog() async {
    final pinController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(
            hintText: '4-digit PIN',
            counterText: '',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final verified = await SecurityService.instance.verifyPin(pinController.text);
              if (context.mounted) Navigator.pop(context, verified);
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
    pinController.dispose();
    return result ?? false;
  }

  Future<void> _loadMedicines() async {
    await CabinetService.instance.init();
    setState(() {
      _medicines = CabinetService.instance.medicines;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cabinet')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock Cabinet'),
                onPressed: _checkSecurity,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cabinet'),
        actions: [
          // Secure Vault Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.security),
            tooltip: 'Secure Vault Options',
            onSelected: (value) async {
              switch (value) {
                case 'export':
                  await BackupService.instance.exportCabinet();
                  break;
                case 'import':
                  final count = await BackupService.instance.importCabinet();
                  if (!context.mounted) return;
                  
                  if (count > 0) {
                    _loadMedicines();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restored $count medicines')),
                    );
                  }
                  break;
                case 'lock':
                  setState(() => _isLocked = true);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.upload_file),
                  title: Text('Export Backup'),
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Restore Backup'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'lock',
                child: ListTile(
                  leading: Icon(Icons.lock, color: Colors.red),
                  title: Text('Lock Cabinet', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicines.isEmpty
              ? _buildEmptyState()
              : _buildMedicineList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_liquid_outlined,
              size: 80,
              color: AppColors.textSubtle.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Cabinet is Empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSubtle,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save medicines for quick access by tapping the bookmark icon on any medicine card.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSubtle.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final medicine = _medicines[index];
        return Dismissible(
          key: Key(medicine.brandName),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          onDismissed: (_) async {
            await CabinetService.instance.removeMedicine(medicine.brandName);
            await _loadMedicines();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicineCard(
                brandName: medicine.brandName,
                genericName: medicine.genericName,
                manufacturer: medicine.manufacturer,
                strength: medicine.strength,
                dosageForm: medicine.dosageForm,
                price: medicine.price,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'Saved ${_formatDate(medicine.savedAt)}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 11,
                        color: AppColors.textSubtle,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
