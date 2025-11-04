class HealthLogData {
  final DateTime date;
  final List<String> symptoms;
  final String mood;
  final double sleepHours;
  final String notes;
  final String? severity;

  HealthLogData({
    required this.date,
    required this.symptoms,
    required this.mood,
    required this.sleepHours,
    this.notes = '',
    this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'mood': mood,
      'sleepHours': sleepHours,
      'notes': notes,
      'severity': severity,
    };
  }

  factory HealthLogData.fromJson(Map<String, dynamic> json) {
    return HealthLogData(
      date: DateTime.parse(json['date']),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      mood: json['mood'] ?? '',
      sleepHours: (json['sleepHours'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
      severity: json['severity'],
    );
  }

  HealthLogData copyWith({
    DateTime? date,
    List<String>? symptoms,
    String? mood,
    double? sleepHours,
    String? notes,
    String? severity,
  }) {
    return HealthLogData(
      date: date ?? this.date,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      sleepHours: sleepHours ?? this.sleepHours,
      notes: notes ?? this.notes,
      severity: severity ?? this.severity,
    );
  }

  @override
  String toString() {
    return 'HealthLogData(date: $date, symptoms: $symptoms, mood: $mood, sleepHours: $sleepHours)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is HealthLogData &&
      other.date == date &&
      other.symptoms == symptoms &&
      other.mood == mood &&
      other.sleepHours == sleepHours &&
      other.notes == notes &&
      other.severity == severity;
  }

  @override
  int get hashCode {
    return date.hashCode ^
      symptoms.hashCode ^
      mood.hashCode ^
      sleepHours.hashCode ^
      notes.hashCode ^
      severity.hashCode;
  }
}