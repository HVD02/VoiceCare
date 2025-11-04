import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  // Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Slower for visually impaired
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Set up handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        print("TTS Error: $msg");
      });

      _isInitialized = true;
      print("TTS Initialized Successfully");
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  // Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    
    try {
      if (_isSpeaking) await stop();
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  // Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  // Pause speaking
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('Error pausing TTS: $e');
    }
  }

  // Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      print('Error setting speech rate: $e');
    }
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  // Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      print('Error setting pitch: $e');
    }
  }

  bool get isSpeaking => _isSpeaking;

  // ========================================
  // CUSTOM ANNOUNCEMENTS FOR VOICECARE APP
  // ========================================

  // Welcome message
  Future<void> announceWelcome() async {
    await speak("Welcome to Voice Care. Your health assistant is ready. Tap anywhere to start.");
  }

  // Page navigation
  Future<void> announcePageChange(String pageName) async {
    await speak("Navigated to $pageName page");
  }

  // Health log announcement
  Future<void> announceHealthLog(String symptom, String severity) async {
    await speak("Health log recorded. $symptom with $severity severity. Saved successfully.");
  }

  // Medication reminders
  Future<void> announceMedicationReminder(String medicationName, String time) async {
    await speak("Reminder: Time to take $medicationName at $time. Single tap to mark as taken. Double tap to skip.");
  }

  Future<void> announceMedicineTaken(String medicationName) async {
    await speak("Medicine taken. $medicationName marked as completed.");
  }

  Future<void> announceMedicineSkipped(String medicationName) async {
    await speak("Medicine skipped. $medicationName marked as skipped.");
  }

  // Voice input announcements
  Future<void> announceListening() async {
    await speak("Listening. Please speak now.");
  }

  Future<void> announceProcessing() async {
    await speak("Processing your voice input. Please wait.");
  }

  Future<void> announceVoiceInputComplete(String recognizedText) async {
    await speak("Recognized: $recognizedText. Processing with AI.");
  }

  // Settings announcements
  Future<void> announceSettingChanged(String settingName, String value) async {
    await speak("$settingName changed to $value");
  }

  Future<void> announceDarkModeToggle(bool isDark) async {
    await speak(isDark ? "Dark mode enabled" : "Light mode enabled");
  }

  Future<void> announceFontSizeChanged(double size) async {
    await speak("Font size changed to ${size.toInt()} points");
  }

  // Error and success messages
  Future<void> announceError(String errorMessage) async {
    await speak("Error: $errorMessage. Please try again.");
  }

  Future<void> announceSuccess(String message) async {
    await speak("Success! $message");
  }

  // Button tap feedback
  Future<void> announceButtonTap(String buttonName) async {
    await speak("$buttonName button pressed");
  }

  // Insights announcements
  Future<void> announceInsight(String insight) async {
    await speak("Health insight: $insight");
  }

  // AI Response from Gemini
  Future<void> announceAIResponse(String response) async {
    await speak("AI Response: $response");
  }
}