import 'package:flutter/foundation.dart';
import '../models/health_log_data.dart';
import '../services/storage_service.dart';

class HealthProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<HealthLogData> _healthLogs = [];
  bool _isInitialized = false;

  // Getter for health logs
  List<HealthLogData> get healthLogs => _healthLogs;

  // Getter for initialization status
  bool get isInitialized => _isInitialized;

  // Initialize and load data
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadHealthLogs();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing HealthProvider: $e');
    }
  }

  // Load health logs from storage
  Future<void> _loadHealthLogs() async {
    try {
      final logs = await _storageService.getHealthLogs();
      _healthLogs = logs;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading health logs: $e');
      _healthLogs = [];
    }
  }

  // Add a new health log
  Future<void> addHealthLog(HealthLogData log) async {
    try {
      _healthLogs.insert(0, log); // Add to beginning of list
      await _storageService.saveHealthLog(log);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding health log: $e');
    }
  }

  // Update an existing health log
  Future<void> updateHealthLog(HealthLogData log) async {
    try {
      final index = _healthLogs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _healthLogs[index] = log;
        await _storageService.updateHealthLog(log);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating health log: $e');
    }
  }

  // Delete a health log
  Future<void> deleteHealthLog(String id) async {
    try {
      _healthLogs.removeWhere((log) => log.id == id);
      await _storageService.deleteHealthLog(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting health log: $e');
    }
  }

  // Get logs for a specific date range
  List<HealthLogData> getLogsForDateRange(DateTime start, DateTime end) {
    return _healthLogs.where((log) {
      return log.date.isAfter(start.subtract(const Duration(days: 1))) &&
             log.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get logs for the last N days
  List<HealthLogData> getRecentLogs(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _healthLogs.where((log) => log.date.isAfter(cutoffDate)).toList();
  }

  // Get most common symptoms
  Map<String, int> getMostCommonSymptoms({int? lastDays}) {
    List<HealthLogData> logs = lastDays != null 
        ? getRecentLogs(lastDays) 
        : _healthLogs;
    
    Map<String, int> symptomCount = {};
    for (var log in logs) {
      for (var symptom in log.symptoms) {
        symptomCount[symptom] = (symptomCount[symptom] ?? 0) + 1;
      }
    }
    return symptomCount;
  }

  // Calculate average sleep hours
  double getAverageSleep({int? lastDays}) {
    List<HealthLogData> logs = lastDays != null 
        ? getRecentLogs(lastDays) 
        : _healthLogs;
    
    if (logs.isEmpty) return 0.0;
    
    double total = logs.fold(0.0, (sum, log) => sum + log.sleepHours);
    return total / logs.length;
  }

  // Calculate average water intake
  double getAverageWaterIntake({int? lastDays}) {
    List<HealthLogData> logs = lastDays != null 
        ? getRecentLogs(lastDays) 
        : _healthLogs;
    
    if (logs.isEmpty) return 0.0;
    
    int total = logs.fold(0, (sum, log) => sum + log.waterIntake);
    return total / logs.length;
  }

  // Calculate average stress level
  double getAverageStressLevel({int? lastDays}) {
    List<HealthLogData> logs = lastDays != null 
        ? getRecentLogs(lastDays) 
        : _healthLogs;
    
    if (logs.isEmpty) return 0.0;
    
    int total = logs.fold(0, (sum, log) => sum + log.stressLevel);
    return total / logs.length;
  }

  // Export all data
  Future<String> exportData() async {
    try {
      return await _storageService.exportAllData();
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return '';
    }
  }

  // Import data
  Future<void> importData(String jsonData) async {
    try {
      await _storageService.importData(jsonData);
      await _loadHealthLogs();
    } catch (e) {
      debugPrint('Error importing data: $e');
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      await _storageService.clearAllData();
      _healthLogs.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }
}