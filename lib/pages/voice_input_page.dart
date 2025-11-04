import 'package:flutter/material.dart';

class VoiceInputPage extends StatefulWidget {
  const VoiceInputPage({super.key});

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _transcribedText = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // Start voice recognition
      _startListening();
    } else {
      // Stop voice recognition
      _stopListening();
    }
  }

  void _startListening() {
    // TODO: Implement actual speech recognition
    // For now, just simulate
    setState(() {
      _transcribedText = 'Listening...';
    });
  }

  void _stopListening() {
    // TODO: Stop speech recognition
    setState(() {
      _transcribedText = 'Tap the microphone to start';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isListening ? const Color(0xFF1a1a1a) : Colors.white,
      appBar: AppBar(
        backgroundColor: _isListening ? const Color(0xFF1a1a1a) : Colors.white,
        foregroundColor: _isListening ? Colors.white : Colors.black,
        title: Text(
          'VOICECARE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: _isListening ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: 28,
            color: _isListening ? Colors.white : Colors.black,
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              size: 28,
              color: _isListening ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Microphone Button
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedBuilder(
                animation: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFD700),
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 80,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // Status Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _isListening ? 'Listening...' : 'Tap to speak',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isListening ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Transcribed Text
            if (_transcribedText.isNotEmpty && !_isListening)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _transcribedText,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const Spacer(),

            // Bottom Action Button (only show when not listening)
            if (!_isListening)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Process voice input
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.notifications_active,
                            color: Colors.black,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Set Reminder',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: _isListening
          ? FloatingActionButton.extended(
              onPressed: _toggleListening,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.stop, size: 28),
              label: const Text(
                'Stop',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}