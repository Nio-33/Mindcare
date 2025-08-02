import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../models/therapy_journal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/therapy_journal_provider.dart';

class MedicationTrackerCard extends StatefulWidget {
  const MedicationTrackerCard({super.key});

  @override
  State<MedicationTrackerCard> createState() => _MedicationTrackerCardState();
}

class _MedicationTrackerCardState extends State<MedicationTrackerCard> {
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medication Tracker',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _medicationNameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedTime?.format(context) ?? 'Select Time',
                        style: TextStyle(
                          color: _selectedTime == null 
                              ? Theme.of(context).hintColor 
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Side effects, effectiveness, etc.)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMedicationEntry,
                child: const Text('Track Medication'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveMedicationEntry() {
    if (_medicationNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a medication name'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final journalProvider = context.read<TherapyJournalProvider>();
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to track medication'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final content = '''
Medication: ${_medicationNameController.text}
Dosage: ${_dosageController.text}
Time: ${_selectedTime?.format(context) ?? 'Not specified'}
Notes: ${_notesController.text}
''';
    
    final entry = TherapyJournalEntry(
      userId: authProvider.user!.uid,
      title: 'Medication - ${_medicationNameController.text}',
      content: content,
      type: JournalEntryType.medication,
      sharingPermission: SharingPermission.private,
      isEncrypted: true,
    );
    
    journalProvider.addEntry(entry, context);
    
    // Clear form
    _medicationNameController.clear();
    _dosageController.clear();
    _notesController.clear();
    setState(() {
      _selectedTime = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medication entry saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}