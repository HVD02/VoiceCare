import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/storage_service.dart';
import '../models/medication_data.dart';

class MedicationReminderPage extends StatefulWidget {
  const MedicationReminderPage({Key? key}) : super(key: key);

  @override
  State<MedicationReminderPage> createState() => _MedicationReminderPageState();
}

class _MedicationReminderPageState extends State<MedicationReminderPage> {
  late FlutterTts _flutterTts;
  final StorageService _storageService = StorageService();
  List<MedicationData> _medications = [];
  bool _showQuickActions = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadMedications();
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _loadMedications() async {
    final meds = await _storageService.getTodayMedications();
    setState(() {
      _medications = meds;
    });
  }

  Future<void> _markMedicationTaken(MedicationData medication) async {
    medication.isTaken = true;
    medication.takenAt = DateTime.now();
    await _storageService.updateMedication(medication);
    await _speak('Medicine taken. ${medication.name} marked as taken');
    _loadMedications();
  }

  Future<void> _markMedicationSkipped(MedicationData medication) async {
    medication.isSkipped = true;
    medication.skippedAt = DateTime.now();
    await _storageService.updateMedication(medication);
    await _speak('Medicine skipped. ${medication.name} marked as skipped');
    _loadMedications();
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final doseController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Add Medication', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Medication Name',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
              ),
            ),
            TextField(
              controller: doseController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Dose (e.g., 20 units)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  selectedTime = time;
                }
              },
              child: const Text('Set Reminder Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
            onPressed: () async {
              if (nameController.text.isNotEmpty && doseController.text.isNotEmpty) {
                final medication = MedicationData(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  dose: doseController.text,
                  scheduledTime: DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    selectedTime.hour,
                    selectedTime.minute,
                  ),
                );
                
                await _storageService.addMedication(medication);
                await _speak('Medication ${nameController.text} added with reminder at ${selectedTime.format(context)}');
                Navigator.pop(context);
                _loadMedications();
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Medications'),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _speak('Single tap to mark medicine as taken. Double tap to mark as skipped.'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick action panel
          GestureDetector(
            onTap: () {
              setState(() => _showQuickActions = !_showQuickActions);
              _speak(_showQuickActions ? 'Quick actions shown' : 'Quick actions hidden');
            },
            onLongPress: () => _speak('Tap to show or hide quick actions'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showQuickActions ? 200 : 100,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[800]!, Colors.grey[850]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication,
                    size: 60,
                    color: Colors.yellow[700],
                  ),
                  const SizedBox(height: 10),
                  if (_showQuickActions) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickActionButton(
                          'TAKEN',
                          Colors.yellow[700]!,
                          () => _speak('Tap on a medication card once to mark as taken'),
                        ),
                        _buildQuickActionButton(
                          'SKIP',
                          Colors.grey[700]!,
                          () => _speak('Double tap on a medication card to mark as skipped'),
                        ),
                      ],
                    ),
                  ] else
                    const Text(
                      'Single tap for Taken, Double tap to Close',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),

          // Today's medications list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    _speak('${_medications.length} medications scheduled for today');
                  },
                  child: Text(
                    '${_medications.length} medications',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Medication cards
          Expanded(
            child: _medications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication_outlined, size: 80, color: Colors.grey[700]),
                        const SizedBox(height: 20),
                        Text(
                          'No medications scheduled',
                          style: TextStyle(color: Colors.grey[600], fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _medications.length,
                    itemBuilder: (context, index) {
                      final medication = _medications[index];
                      return MedicationCard(
                        medication: medication,
                        onTaken: () => _markMedicationTaken(medication),
                        onSkipped: () => _markMedicationSkipped(medication),
                        onSpeak: _speak,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicationDialog,
        backgroundColor: Colors.yellow[700],
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Add Medication', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final MedicationData medication;
  final VoidCallback onTaken;
  final VoidCallback onSkipped;
  final Function(String) onSpeak;

  const MedicationCard({
    Key? key,
    required this.medication,
    required this.onTaken,
    required this.onSkipped,
    required this.onSpeak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = medication.isTaken
        ? 'Taken'
        : medication.isSkipped
            ? 'Skipped'
            : 'Pending';

    return GestureDetector(
      onTap: () {
        if (!medication.isTaken && !medication.isSkipped) {
          onTaken();
        } else {
          onSpeak('This medication is already marked as $status');
        }
      },
      onDoubleTap: () {
        if (!medication.isTaken && !medication.isSkipped) {
          onSkipped();
        } else {
          onSpeak('This medication is already marked as $status');
        }
      },
      onLongPress: () {
        onSpeak('${medication.name}, ${medication.dose}. Scheduled for ${TimeOfDay.fromDateTime(medication.scheduledTime).format(context)}. Status: $status');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: medication.isTaken
              ? Colors.green[800]
              : medication.isSkipped
                  ? Colors.red[900]
                  : Colors.grey[800],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: medication.isTaken
                ? Colors.green
                : medication.isSkipped
                    ? Colors.red
                    : Colors.yellow[700]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                shape: BoxShape.circle,
              ),
              child: Icon(
                medication.isTaken
                    ? Icons.check_circle
                    : medication.isSkipped
                        ? Icons.cancel
                        : Icons.medication,
                color: medication.isTaken
                    ? Colors.green
                    : medication.isSkipped
                        ? Colors.red
                        : Colors.yellow[700],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    medication.dose,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Scheduled: ${TimeOfDay.fromDateTime(medication.scheduledTime).format(context)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: medication.isTaken
                        ? Colors.green
                        : medication.isSkipped
                            ? Colors.red
                            : Colors.yellow[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (medication.takenAt != null || medication.skippedAt != null)
                  Text(
                    TimeOfDay.fromDateTime(
                      medication.takenAt ?? medication.skippedAt!,
                    ).format(context),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}