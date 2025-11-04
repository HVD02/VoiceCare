import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../models/health_log_data.dart';

class HealthLogPage extends StatefulWidget {
  const HealthLogPage({Key? key}) : super(key: key);

  @override
  State<HealthLogPage> createState() => _HealthLogPageState();
}

class _HealthLogPageState extends State<HealthLogPage> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _transcribedText = '';
  String _userInput = ''; // NEW: Store the final user input separately
  final TextEditingController _moodController = TextEditingController();
  
  final GeminiService _geminiService = GeminiService();
  final StorageService _storageService = StorageService();
  
  Set<String> _selectedSymptoms = {};
  double _sleepHours = 7.0;
  HealthLogData? _todayLog;

  final List<String> _symptoms = [
    'Headache', 'Fatigue', 'Nausea', 'Fever', 'Cough',
    'Sore Throat', 'Body Ache', 'Dizziness', 'Stomach Pain',
    'Anxiety', 'Congestion', 'Back Pain', 'Joint Pain',
    'Chest Pain', 'Insomnia'
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
    _loadTodayLog();
  }

  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize(
        onError: (error) => _speak('Error: ${error.errorMsg}'),
        onStatus: (status) => print('Speech status: $status'),
      );
      
      if (!available) {
        _speak('Speech recognition not available');
      }
    } else {
      _speak('Microphone permission denied');
    }
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

  Future<void> _loadTodayLog() async {
    final log = await _storageService.getTodayLog();
    setState(() {
      _todayLog = log;
      if (log != null) {
        _selectedSymptoms = log.symptoms.toSet();
        _moodController.text = log.mood;
        _sleepHours = log.sleepHours;
        _userInput = log.notes; // Load existing notes if available
      }
    });
  }

  void _startListening() async {
    if (!_isListening && _speech.isAvailable) {
      setState(() {
        _isListening = true;
        _transcribedText = ''; // Clear only the live transcription
      });
      
      await _speak('Listening... Please describe how you are feeling');
      
      await _speech.listen(
        onResult: (result) async {
          setState(() {
            _transcribedText = result.recognizedWords;
          });
          
          if (result.finalResult) {
            await _processTranscription(_transcribedText);
          }
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
      );
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _processTranscription(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _userInput = text; // Store the final user input
      _isListening = false;
    });

    await _speak('Processing your input...');
    
    try {
      final analysis = await _geminiService.analyzeHealthDescription(text);
      
      setState(() {
        if (analysis['symptoms'] != null) {
          _selectedSymptoms = Set<String>.from(
            (analysis['symptoms'] as List).where((s) => _symptoms.contains(s))
          );
        }
        
        if (analysis['mood'] != null) {
          _moodController.text = analysis['mood'];
        }
        
        if (analysis['sleep_hours'] != null) {
          _sleepHours = double.parse(analysis['sleep_hours'].toString());
        }
      });

      String feedback = 'I understood: ';
      if (_selectedSymptoms.isNotEmpty) {
        feedback += '${_selectedSymptoms.join(", ")}. ';
      }
      if (_moodController.text.isNotEmpty) {
        feedback += 'Mood: ${_moodController.text}. ';
      }
      
      await _speak(feedback);
      await _speak('You can adjust your selections below');
      
    } catch (e) {
      await _speak('Sorry, I had trouble processing that. Please try again.');
    }
  }

  Future<void> _saveLog() async {
    final log = HealthLogData(
      date: DateTime.now(),
      symptoms: _selectedSymptoms.toList(),
      mood: _moodController.text,
      sleepHours: _sleepHours,
      notes: _userInput, // Save the user's voice input
    );
    
    await _storageService.saveHealthLog(log);
    await _speak('Health log saved successfully');
    
    setState(() {
      _todayLog = log;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Health log saved successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _flutterTts.stop();
    _moodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Health Log'),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _speak('Tap the yellow button to record your health status using your voice'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large circular voice input button
              Center(
                child: GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  onLongPress: () => _speak('Tap to speak about your health'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : Colors.yellow[700],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _isListening ? Colors.red.withOpacity(0.5) : Colors.yellow.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 80,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isListening ? 'Listening...' : 'Tap to Speak',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Date display
              Text(
                "Today's Log",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                DateTime.now().toString().split(' ')[0],
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              
              const SizedBox(height: 30),
              
              // Display SAVED user input (not live transcription)
              if (_userInput.isNotEmpty) ...[
                const Text(
                  'You said:',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _userInput,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Show live transcription only while listening
              if (_isListening && _transcribedText.isNotEmpty) ...[
                const Text(
                  'Transcribing...',
                  style: TextStyle(color: Colors.yellow, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.yellow, width: 2),
                  ),
                  child: Text(
                    _transcribedText,
                    style: const TextStyle(color: Colors.yellow, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Symptoms section
              const Text(
                'How are you feeling?',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _symptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSymptoms.remove(symptom);
                          _speak('$symptom removed');
                        } else {
                          _selectedSymptoms.add(symptom);
                          _speak('$symptom added');
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.yellow[700] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.yellow : Colors.grey[700]!,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        symptom,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 30),
              
              // Mood section
              const Text(
                'Your mood',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _moodController,
                onTap: () => _speak('Enter your mood'),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Happy, Tired, Anxious',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Sleep section
              const Text(
                'Sleep',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _sleepHours,
                      min: 0,
                      max: 12,
                      divisions: 24,
                      activeColor: Colors.yellow[700],
                      onChanged: (value) {
                        setState(() => _sleepHours = value);
                      },
                      onChangeEnd: (value) {
                        _speak('${value.toStringAsFixed(1)} hours of sleep');
                      },
                    ),
                  ),
                  Text(
                    '${_sleepHours.toStringAsFixed(1)} hours',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Log',
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}