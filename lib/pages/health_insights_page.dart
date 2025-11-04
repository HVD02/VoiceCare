import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';
import '../models/health_log_data.dart';

class HealthInsightsPage extends StatefulWidget {
  const HealthInsightsPage({Key? key}) : super(key: key);

  @override
  State<HealthInsightsPage> createState() => _HealthInsightsPageState();
}

class _HealthInsightsPageState extends State<HealthInsightsPage> {
  late FlutterTts _flutterTts;
  final StorageService _storageService = StorageService();
  final GeminiService _geminiService = GeminiService();
  
  Map<String, dynamic> _healthStats = {};
  Map<String, dynamic> _medicationStats = {};
  List<HealthLogData> _recentLogs = [];
  String? _aiInsights;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadInsights();
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);

    _healthStats = await _storageService.getHealthStats();
    _medicationStats = await _storageService.getMedicationStats();
    
    final allLogs = await _storageService.getAllHealthLogs();
    _recentLogs = allLogs.reversed.take(7).toList();

    // Generate AI insights if there are logs
    if (_recentLogs.isNotEmpty) {
      await _generateAIInsights();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _generateAIInsights() async {
    try {
      final recentSymptoms = _recentLogs
          .expand((log) => log.symptoms)
          .toSet()
          .toList();
      
      final recentMoods = _recentLogs
          .map((log) => log.mood)
          .where((mood) => mood.isNotEmpty)
          .toList();

      if (recentSymptoms.isNotEmpty) {
        final advice = await _geminiService.getHealthAdvice(
          recentSymptoms,
          recentMoods.isNotEmpty ? recentMoods.last : 'neutral',
        );
        
        setState(() => _aiInsights = advice);
      }
    } catch (e) {
      print('Error generating AI insights: $e');
    }
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
        title: const Text('Health Insights'),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _speak('Refreshing insights');
              _loadInsights();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _speak('This page shows your health trends and AI-powered insights based on your logged data'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : RefreshIndicator(
              onRefresh: _loadInsights,
              color: Colors.yellow[700],
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Insights Card
                      if (_aiInsights != null) ...[
                        _buildSectionTitle('AI Health Insights', Icons.psychology),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () => _speak(_aiInsights!),
                          onLongPress: () => _speak('AI generated health insights based on your recent logs'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.yellow[700]!, Colors.amber[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.lightbulb, color: Colors.black),
                                    SizedBox(width: 10),
                                    Text(
                                      'Personalized Advice',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _aiInsights!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],

                      // Health Statistics
                      _buildSectionTitle('Health Statistics', Icons.bar_chart),
                      const SizedBox(height: 15),
                      _buildStatCard(
                        'Total Logs',
                        '${_healthStats['total_logs'] ?? 0}',
                        Icons.article,
                        Colors.blue,
                        'You have logged ${_healthStats['total_logs'] ?? 0} health entries',
                      ),
                      const SizedBox(height: 10),
                      _buildStatCard(
                        'Average Sleep',
                        '${(_healthStats['average_sleep'] ?? 0.0).toStringAsFixed(1)} hrs',
                        Icons.bedtime,
                        Colors.purple,
                        'Your average sleep is ${(_healthStats['average_sleep'] ?? 0.0).toStringAsFixed(1)} hours',
                      ),
                      const SizedBox(height: 10),
                      _buildStatCard(
                        'Medication Adherence',
                        '${(_medicationStats['adherence_rate'] ?? 0.0).toStringAsFixed(0)}%',
                        Icons.medication,
                        Colors.green,
                        'Your medication adherence rate is ${(_medicationStats['adherence_rate'] ?? 0.0).toStringAsFixed(0)} percent',
                      ),

                      const SizedBox(height: 30),

                      // Most Common Symptoms
                      if (_healthStats['most_common_symptoms'] != null &&
                          (_healthStats['most_common_symptoms'] as List).isNotEmpty) ...[
                        _buildSectionTitle('Most Common Symptoms', Icons.sick),
                        const SizedBox(height: 15),
                        ..._buildSymptomsList(_healthStats['most_common_symptoms'] as List),
                        const SizedBox(height: 30),
                      ],

                      // Mood Distribution
                      if (_healthStats['mood_distribution'] != null &&
                          (_healthStats['mood_distribution'] as Map).isNotEmpty) ...[
                        _buildSectionTitle('Mood Tracker', Icons.sentiment_satisfied),
                        const SizedBox(height: 15),
                        ..._buildMoodList(_healthStats['mood_distribution'] as Map<String, dynamic>),
                        const SizedBox(height: 30),
                      ],

                      // Recent Activity
                      _buildSectionTitle('Recent Activity', Icons.history),
                      const SizedBox(height: 15),
                      if (_recentLogs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Text(
                              'No recent health logs',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ),
                        )
                      else
                        ..._recentLogs.map((log) => _buildLogCard(log)).toList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return GestureDetector(
      onTap: () => _speak(title),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellow[700], size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String speakText) {
    return GestureDetector(
      onTap: () => _speak(speakText),
      onLongPress: () => _speak(title),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSymptomsList(List symptoms) {
    return symptoms.map((symptom) {
      final name = symptom['symptom'];
      final count = symptom['count'];
      return GestureDetector(
        onTap: () => _speak('$name: $count occurrences'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildMoodList(Map<String, dynamic> moodDistribution) {
    return moodDistribution.entries.map((entry) {
      final mood = entry.key;
      final count = entry.value;
      return GestureDetector(
        onTap: () => _speak('$mood: $count times'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(_getMoodEmoji(mood), style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    mood,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              Text(
                '$count',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLogCard(HealthLogData log) {
    return GestureDetector(
      onTap: () {
        final symptomsText = log.symptoms.isEmpty ? 'no symptoms' : log.symptoms.join(', ');
        _speak('Log from ${log.date.toString().split(' ')[0]}. Symptoms: $symptomsText. Mood: ${log.mood}. Sleep: ${log.sleepHours} hours');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  log.date.toString().split(' ')[0],
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                if (log.symptoms.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${log.symptoms.length} symptoms',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            if (log.symptoms.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: log.symptoms
                    .take(3)
                    .map((s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.grey[800],
                          labelStyle: const TextStyle(color: Colors.white),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.sentiment_satisfied, color: Colors.yellow[700], size: 16),
                const SizedBox(width: 5),
                Text(
                  log.mood.isEmpty ? 'No mood recorded' : log.mood,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 15),
                Icon(Icons.bedtime, color: Colors.purple[300], size: 16),
                const SizedBox(width: 5),
                Text(
                  '${log.sleepHours}h',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    final moodLower = mood.toLowerCase();
    if (moodLower.contains('happy') || moodLower.contains('good') || moodLower.contains('great')) {
      return '😊';
    } else if (moodLower.contains('sad') || moodLower.contains('depressed')) {
      return '😢';
    } else if (moodLower.contains('anxious') || moodLower.contains('worried')) {
      return '😰';
    } else if (moodLower.contains('tired') || moodLower.contains('exhausted')) {
      return '😴';
    } else if (moodLower.contains('angry') || moodLower.contains('frustrated')) {
      return '😠';
    } else if (moodLower.contains('calm') || moodLower.contains('relaxed')) {
      return '😌';
    }
    return '😐';
  }
}