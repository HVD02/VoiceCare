import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late FlutterTts _flutterTts;
  late SharedPreferences _prefs;
  
  bool _voiceAssistantEnabled = true;
  bool _isDarkMode = true;
  double _fontSize = 16.0;
  bool _hapticsEnabled = true;
  double _speechRate = 0.5;
  double _speechVolume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadSettings();
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceAssistantEnabled = _prefs.getBool('voiceAssistant') ?? true;
      _isDarkMode = _prefs.getBool('darkMode') ?? true;
      _fontSize = _prefs.getDouble('fontSize') ?? 16.0;
      _hapticsEnabled = _prefs.getBool('haptics') ?? true;
      _speechRate = _prefs.getDouble('speechRate') ?? 0.5;
      _speechVolume = _prefs.getDouble('speechVolume') ?? 1.0;
    });
    
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_speechVolume);
  }

  Future<void> _speak(String text) async {
    if (_voiceAssistantEnabled) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _saveAndApplySettings() async {
    await _prefs.setBool('voiceAssistant', _voiceAssistantEnabled);
    await _prefs.setBool('darkMode', _isDarkMode);
    await _prefs.setDouble('fontSize', _fontSize);
    await _prefs.setBool('haptics', _hapticsEnabled);
    await _prefs.setDouble('speechRate', _speechRate);
    await _prefs.setDouble('speechVolume', _speechVolume);
    
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_speechVolume);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _speak('Settings page. Adjust voice assistant, theme, font size, and accessibility options here.'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _speak('Health Tracker User profile'),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.yellow[700],
                      child: Icon(Icons.person, size: 60, color: Colors.grey[900]),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Health Tracker User',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: _fontSize + 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => _speak('0 health logs recorded'),
                    child: Text(
                      '0 health logs',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: _fontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // General Settings Section
            _buildSectionHeader('GENERAL SETTINGS'),
            _buildSettingTile(
              icon: Icons.mic,
              title: 'Voice Assistant',
              subtitle: 'Enable voice feedback and guidance',
              trailing: Switch(
                value: _voiceAssistantEnabled,
                onChanged: (value) async {
                  setState(() => _voiceAssistantEnabled = value);
                  await _saveAndApplySettings();
                  if (value) {
                    await _speak('Voice assistant enabled');
                  }
                },
                activeColor: Colors.yellow[700],
              ),
              onTap: () => _speak('Voice assistant is currently ${_voiceAssistantEnabled ? "enabled" : "disabled"}. Tap to toggle.'),
            ),

            _buildSettingTile(
              icon: Icons.volume_up,
              title: 'Speech Volume',
              subtitle: 'Adjust voice feedback volume',
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: _speechVolume,
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.yellow[700],
                  onChanged: (value) {
                    setState(() => _speechVolume = value);
                  },
                  onChangeEnd: (value) async {
                    await _saveAndApplySettings();
                    await _speak('Volume set to ${(value * 100).toInt()} percent');
                  },
                ),
              ),
              onTap: () => _speak('Speech volume is at ${(_speechVolume * 100).toInt()} percent'),
            ),

            _buildSettingTile(
              icon: Icons.speed,
              title: 'Speech Speed',
              subtitle: 'Adjust voice feedback speed',
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: _speechRate,
                  min: 0.1,
                  max: 1.0,
                  activeColor: Colors.yellow[700],
                  onChanged: (value) {
                    setState(() => _speechRate = value);
                  },
                  onChangeEnd: (value) async {
                    await _saveAndApplySettings();
                    await _speak('Speech rate adjusted');
                  },
                ),
              ),
              onTap: () => _speak('Speech speed is currently at ${(_speechRate * 100).toInt()} percent'),
            ),

            _buildSettingTile(
              icon: Icons.vibration,
              title: 'Haptic Feedback',
              subtitle: 'Enable vibration feedback',
              trailing: Switch(
                value: _hapticsEnabled,
                onChanged: (value) async {
                  setState(() => _hapticsEnabled = value);
                  await _saveAndApplySettings();
                  await _speak('Haptic feedback ${value ? "enabled" : "disabled"}');
                },
                activeColor: Colors.yellow[700],
              ),
              onTap: () => _speak('Haptic feedback is ${_hapticsEnabled ? "enabled" : "disabled"}'),
            ),

            // Personalization Section
            _buildSectionHeader('PERSONALIZATION'),
            
            _buildSettingTile(
              icon: Icons.palette,
              title: 'Themes & Contrast',
              subtitle: _isDarkMode ? 'Dark mode' : 'Light mode',
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) async {
                  setState(() => _isDarkMode = value);
                  await _saveAndApplySettings();
                  await _speak('${value ? "Dark" : "Light"} mode enabled');
                },
                activeColor: Colors.yellow[700],
              ),
              onTap: () => _speak('Current theme is ${_isDarkMode ? "dark mode" : "light mode"}. Tap to change.'),
            ),

            _buildSettingTile(
              icon: Icons.format_size,
              title: 'Font Size & Haptics',
              subtitle: 'Size: ${_fontSize.toInt()}',
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: _fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  activeColor: Colors.yellow[700],
                  onChanged: (value) {
                    setState(() => _fontSize = value);
                  },
                  onChangeEnd: (value) async {
                    await _saveAndApplySettings();
                    await _speak('Font size set to ${value.toInt()}');
                  },
                ),
              ),
              onTap: () => _speak('Font size is ${_fontSize.toInt()}. Adjust using the slider.'),
            ),

            // Safety & Support Section
            _buildSectionHeader('SAFETY & SUPPORT'),
            
            _buildSettingTile(
              icon: Icons.help_outline,
              title: 'Help & Tutorial',
              subtitle: 'Learn how to use the app',
              onTap: () async {
                await _speak('Help and tutorial. This app helps you track your health using voice commands. Use the yellow microphone button on the home page to record your symptoms. Single tap medications to mark as taken, double tap to skip. All your data is saved securely.');
              },
            ),

            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy & Data',
              subtitle: 'Manage your data',
              onTap: () async {
                await _speak('Privacy and data settings. Your health data is stored locally on your device and is never shared without your permission.');
              },
            ),

            _buildSettingTile(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Help us improve',
              onTap: () async {
                await _speak('Send feedback. Please contact us at support@healthtracker.com');
              },
            ),

            _buildSettingTile(
              icon: Icons.delete_outline,
              title: 'Clear All Data',
              subtitle: 'Reset app to default',
              titleColor: Colors.red,
              onTap: () async {
                await _speak('Warning: This will delete all your health logs and medication records. Are you sure?');
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.white,
                    title: Text(
                      'Clear All Data?',
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                    ),
                    content: Text(
                      'This will permanently delete all your health logs and medication records. This action cannot be undone.',
                      style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _speak('Data deletion cancelled');
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          // Clear all data logic here
                          await _prefs.clear();
                          Navigator.pop(context);
                          await _speak('All data cleared successfully');
                        },
                        child: const Text('Delete All', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Text(
        title,
        style: TextStyle(
          color: _isDarkMode ? Colors.grey[500] : Colors.grey[600],
          fontSize: _fontSize - 2,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _speak(title),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.yellow[700]!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.yellow[700]),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? (_isDarkMode ? Colors.white : Colors.black),
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: _fontSize - 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing else Icon(Icons.chevron_right, color: _isDarkMode ? Colors.grey[600] : Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}