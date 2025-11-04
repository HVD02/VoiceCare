import 'package:flutter/material.dart';
import 'package:voicecare_app/services/tts_service.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  bool _isListening = false;
  final TtsService _ttsService = TtsService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
    setState(() {
      _isInitialized = true;
    });
    
    // Welcome message when app starts
    await _ttsService.speak("Welcome to VoiceCare. Tap anywhere to start recording your health symptoms.");
  }

  void _toggleListening() async {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // When starting to listen
      await _ttsService.speak("Listening. Please speak now.");
      // Here you would start your speech-to-text
    } else {
      // When stopping listening
      await _ttsService.speak("Recording stopped. Processing your input.");
      // Here you would stop your speech-to-text
    }
  }

  void _onMenuSelect(String value) async {
    if (value == 'Health Insights') {
      await _ttsService.speak("Opening Health Insights");
      if (mounted) {
        Navigator.pushNamed(context, '/healthinsights');
      }
    } else if (value == 'Settings') {
      await _ttsService.speak("Opening Settings");
      if (mounted) {
        Navigator.pushNamed(context, '/settings');
      }
    }
  }

  void _navigateToHistory() async {
    await _ttsService.speak("Opening Health Log");
    if (mounted) {
      Navigator.pushNamed(context, '/healthlog');
    }
  }

  void _navigateToReminder() async {
    await _ttsService.speak("Opening Medication Reminders");
    if (mounted) {
      Navigator.pushNamed(context, '/reminder');
    }
  }

  // Example: Simulating a successful symptom save
  void _simulateSaveSymptom() async {
    await _ttsService.speak("Symptom saved successfully. Your headache has been logged at 2:30 PM.");
    
    // Show a snackbar as well for visual feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptom saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'VOICECARE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        leading: PopupMenuButton<String>(
          color: const Color(0xFF1E1E1E),
          icon: const Icon(Icons.more_vert, size: 30, color: Colors.white70),
          onSelected: _onMenuSelect,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'Health Insights',
              child: Row(
                children: [
                  Icon(Icons.insights, color: Colors.white70),
                  SizedBox(width: 10),
                  Text('Health Insights'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'Settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.white70),
                  SizedBox(width: 10),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white70, size: 30),
            onPressed: _navigateToHistory,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _toggleListening,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mic button with animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 190,
                width: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow.withOpacity(0.1),
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 15,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.black87,
                      size: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _isListening ? 'Listening...' : 'Tap anywhere to talk',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              
              // Test button for TTS demo
              if (_isInitialized)
                ElevatedButton(
                  onPressed: _simulateSaveSymptom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Test TTS (Save Symptom)'),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToReminder,
        backgroundColor: const Color(0xFFFFD54F),
        child: const Icon(Icons.notifications, color: Colors.black87),
      ),
    );
  }
}