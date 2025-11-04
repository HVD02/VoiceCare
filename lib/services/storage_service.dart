import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_log_data.dart';
import '../models/medication_data.dart';

class StorageService {
  static const String _healthLogsKey = 'health_logs';
  static const String _medicationsKey = 'medications';

  // Health Logs Methods
  Future<void> saveHealthLog(HealthLogData log) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getAllHealthLogs();
    
    // Check if today's log already exists
    final todayIndex = logs.indexWhere((l) => 
      l.date.year == log.date.year &&
      l.date.month == log.date.month &&
      l.date.day == log.date.day
    );
    
    if (todayIndex != -1) {
      logs[todayIndex] = log; // Update existing
    } else {
      logs.add(log); // Add new
    }
    
    final jsonList = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_healthLogsKey, jsonEncode(jsonList));
  }

  Future<List<HealthLogData>> getAllHealthLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_healthLogsKey);
    
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => HealthLogData.fromJson(json)).toList();
  }

  Future<HealthLogData?> getTodayLog() async {
    final logs = await getAllHealthLogs();
    final today = DateTime.now();
    
    try {
      return logs.firstWhere((log) =>
        log.date.year == today.year &&
        log.date.month == today.month &&
        log.date.day == today.day
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<HealthLogData>> getLogsByDateRange(DateTime start, DateTime end) async {
    final logs = await getAllHealthLogs();
    return logs.where((log) =>
      log.date.isAfter(start.subtract(const Duration(days: 1))) &&
      log.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  // Medication Methods
  Future<void> addMedication(MedicationData medication) async {
    final prefs = await SharedPreferences.getInstance();
    final medications = await getAllMedications();
    medications.add(medication);
    
    final jsonList = medications.map((m) => m.toJson()).toList();
    await prefs.setString(_medicationsKey, jsonEncode(jsonList));
  }

  Future<void> updateMedication(MedicationData medication) async {
    final prefs = await SharedPreferences.getInstance();
    final medications = await getAllMedications();
    
    final index = medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      medications[index] = medication;
      final jsonList = medications.map((m) => m.toJson()).toList();
      await prefs.setString(_medicationsKey, jsonEncode(jsonList));
    }
  }

  Future<void> deleteMedication(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final medications = await getAllMedications();
    medications.removeWhere((m) => m.id == id);
    
    final jsonList = medications.map((m) => m.toJson()).toList();
    await prefs.setString(_medicationsKey, jsonEncode(jsonList));
  }

  Future<List<MedicationData>> getAllMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_medicationsKey);
    
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => MedicationData.fromJson(json)).toList();
  }

  Future<List<MedicationData>> getTodayMedications() async {
    final medications = await getAllMedications();
    final today = DateTime.now();
    
    return medications.where((med) =>
      med.scheduledTime.year == today.year &&
      med.scheduledTime.month == today.month &&
      med.scheduledTime.day == today.day
    ).toList()
    ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  Future<List<MedicationData>> getUpcomingMedications() async {
    final medications = await getAllMedications();
    final now = DateTime.now();
    
    return medications.where((med) =>
      med.scheduledTime.isAfter(now) &&
      !med.isTaken &&
      !med.isSkipped
    ).toList()
    ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Analytics Methods
  Future<Map<String, dynamic>> getHealthStats() async {
    final logs = await getAllHealthLogs();
    
    if (logs.isEmpty) {
      return {
        'total_logs': 0,
        'average_sleep': 0.0,
        'most_common_symptoms': [],
        'mood_distribution': {},
      };
    }

    // Calculate average sleep
    final totalSleep = logs.fold(0.0, (sum, log) => sum + log.sleepHours);
    final averageSleep = totalSleep / logs.length;

    // Find most common symptoms
    final symptomCount = <String, int>{};
    for (var log in logs) {
      for (var symptom in log.symptoms) {
        symptomCount[symptom] = (symptomCount[symptom] ?? 0) + 1;
      }
    }
    
    final sortedSymptoms = symptomCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostCommonSymptoms = sortedSymptoms.take(5)
      .map((e) => {'symptom': e.key, 'count': e.value})
      .toList();

    // Mood distribution
    final moodCount = <String, int>{};
    for (var log in logs) {
      if (log.mood.isNotEmpty) {
        moodCount[log.mood] = (moodCount[log.mood] ?? 0) + 1;
      }
    }

    return {
      'total_logs': logs.length,
      'average_sleep': averageSleep,
      'most_common_symptoms': mostCommonSymptoms,
      'mood_distribution': moodCount,
    };
  }

  Future<Map<String, dynamic>> getMedicationStats() async {
    final medications = await getAllMedications();
    
    if (medications.isEmpty) {
      return {
        'total_medications': 0,
        'taken_today': 0,
        'skipped_today': 0,
        'pending_today': 0,
        'adherence_rate': 0.0,
      };
    }

    final today = DateTime.now();
    final todayMeds = medications.where((m) =>
      m.scheduledTime.year == today.year &&
      m.scheduledTime.month == today.month &&
      m.scheduledTime.day == today.day
    ).toList();

    final taken = todayMeds.where((m) => m.isTaken).length;
    final skipped = todayMeds.where((m) => m.isSkipped).length;
    final pending = todayMeds.where((m) => !m.isTaken && !m.isSkipped).length;

    final adherenceRate = todayMeds.isEmpty 
      ? 0.0 
      : (taken / (taken + skipped)) * 100;

    return {
      'total_medications': medications.length,
      'taken_today': taken,
      'skipped_today': skipped,
      'pending_today': pending,
      'adherence_rate': adherenceRate,
    };
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_healthLogsKey);
    await prefs.remove(_medicationsKey);
  }
}