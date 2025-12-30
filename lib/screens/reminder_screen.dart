import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/reminder_service.dart';

/// Screen for managing medicine reminders.
class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _isLoading = true;
  List<MedicineReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    await ReminderService.instance.init();
    setState(() {
      _reminders = ReminderService.instance.reminders;
      _isLoading = false;
    });
  }

  void _showAddReminderDialog() {
    final medicineController = TextEditingController();
    final dosageController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    List<int> selectedDays = [1, 2, 3, 4, 5, 6, 7]; // Every day by default

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Reminder',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              // Medicine Name
              TextField(
                controller: medicineController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  hintText: 'e.g., Napa 500mg',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // Dosage
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g., 1 tablet after meals',
                  prefixIcon: Icon(Icons.straighten_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Time Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.access_time, color: AppColors.primaryAccent),
                title: const Text('Reminder Time'),
                subtitle: Text(
                  _formatTimeOfDay(selectedTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryAccent,
                      ),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                    ),
                  );
                  if (picked != null) {
                    setModalState(() {
                      selectedTime = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Day Selector
              Text(
                'Repeat On',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildDayChip('Mon', 1, selectedDays, (days) => setModalState(() => selectedDays = days)),
                  _buildDayChip('Tue', 2, selectedDays, (days) => setModalState(() => selectedDays = days)),
                  _buildDayChip('Wed', 3, selectedDays, (days) => setModalState(() => selectedDays = days)),
                  _buildDayChip('Thu', 4, selectedDays, (days) => setModalState(() => selectedDays = days)),
                  _buildDayChip('Fri', 5, selectedDays, (days) => setModalState(() => selectedDays = days)),
                  _buildDayChip('Sat', 6, selectedDays, (days) => setModalState(() => selectedDays = days)),
                  _buildDayChip('Sun', 7, selectedDays, (days) => setModalState(() => selectedDays = days)),
                ],
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (medicineController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter medicine name')),
                      );
                      return;
                    }

                    if (selectedDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one day')),
                      );
                      return;
                    }

                    final result = await ReminderService.instance.scheduleReminder(
                      medicineName: medicineController.text,
                      dosage: dosageController.text.isEmpty ? '1 dose' : dosageController.text,
                      time: ReminderTime(hour: selectedTime.hour, minute: selectedTime.minute),
                      daysOfWeek: selectedDays,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    
                    if (result != null) {
                      await _loadReminders();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder set successfully!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to set reminder. Please try again.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.alarm_add),
                  label: const Text('Set Reminder'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(String label, int day, List<int> selectedDays, Function(List<int>) onChanged) {
    final isSelected = selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        final newDays = List<int>.from(selectedDays);
        if (selected) {
          newDays.add(day);
        } else {
          newDays.remove(day);
        }
        onChanged(newDays);
      },
      selectedColor: AppColors.primaryAccent.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryAccent,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final h = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? _buildEmptyState()
              : _buildReminderList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderDialog,
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add Reminder'),
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.white,
      ),
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
              Icons.alarm_off_outlined,
              size: 80,
              color: AppColors.textSubtle.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Reminders Set',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSubtle,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set reminders to never miss your medication.',
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

  Widget _buildReminderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return _buildReminderCard(reminder);
      },
    );
  }

  Widget _buildReminderCard(MedicineReminder reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: reminder.isActive
            ? null
            : Border.all(color: AppColors.border),
        boxShadow: reminder.isActive
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Time Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: reminder.isActive
                  ? AppColors.primaryAccent.withValues(alpha: 0.1)
                  : AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.alarm,
                  color: reminder.isActive ? AppColors.primaryAccent : AppColors.textSubtle,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.timeString,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: reminder.isActive ? AppColors.primaryAccent : AppColors.textSubtle,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.medicineName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: reminder.isActive ? AppColors.textHeading : AppColors.textSubtle,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.dosage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSubtle,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.daysString,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryAccent,
                      ),
                ),
              ],
            ),
          ),

          // Toggle & Delete
          Column(
            children: [
              Switch(
                value: reminder.isActive,
                onChanged: (value) async {
                  await ReminderService.instance.toggleReminder(reminder.id);
                  await _loadReminders();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red.withValues(alpha: 0.7),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Reminder'),
                      content: Text('Delete reminder for "${reminder.medicineName}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ReminderService.instance.cancelReminder(reminder.id);
                    await _loadReminders();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
