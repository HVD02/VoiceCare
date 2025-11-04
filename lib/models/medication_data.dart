class MedicationData {
  final String id;
  final String name;
  final String dose;
  final DateTime scheduledTime;
  bool isTaken;
  bool isSkipped;
  DateTime? takenAt;
  DateTime? skippedAt;
  final String? notes;
  final bool isRecurring;
  final String? frequency; // daily, weekly, etc.

  MedicationData({
    required this.id,
    required this.name,
    required this.dose,
    required this.scheduledTime,
    this.isTaken = false,
    this.isSkipped = false,
    this.takenAt,
    this.skippedAt,
    this.notes,
    this.isRecurring = false,
    this.frequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isTaken': isTaken,
      'isSkipped': isSkipped,
      'takenAt': takenAt?.toIso8601String(),
      'skippedAt': skippedAt?.toIso8601String(),
      'notes': notes,
      'isRecurring': isRecurring,
      'frequency': frequency,
    };
  }

  factory MedicationData.fromJson(Map<String, dynamic> json) {
    return MedicationData(
      id: json['id'],
      name: json['name'],
      dose: json['dose'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      isTaken: json['isTaken'] ?? false,
      isSkipped: json['isSkipped'] ?? false,
      takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt']) : null,
      skippedAt: json['skippedAt'] != null ? DateTime.parse(json['skippedAt']) : null,
      notes: json['notes'],
      isRecurring: json['isRecurring'] ?? false,
      frequency: json['frequency'],
    );
  }

  MedicationData copyWith({
    String? id,
    String? name,
    String? dose,
    DateTime? scheduledTime,
    bool? isTaken,
    bool? isSkipped,
    DateTime? takenAt,
    DateTime? skippedAt,
    String? notes,
    bool? isRecurring,
    String? frequency,
  }) {
    return MedicationData(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isTaken: isTaken ?? this.isTaken,
      isSkipped: isSkipped ?? this.isSkipped,
      takenAt: takenAt ?? this.takenAt,
      skippedAt: skippedAt ?? this.skippedAt,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
    );
  }

  String getStatus() {
    if (isTaken) return 'Taken';
    if (isSkipped) return 'Skipped';
    
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return 'Overdue';
    
    return 'Pending';
  }

  bool isOverdue() {
    return !isTaken && !isSkipped && scheduledTime.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'MedicationData(id: $id, name: $name, dose: $dose, scheduledTime: $scheduledTime, status: ${getStatus()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MedicationData &&
      other.id == id &&
      other.name == name &&
      other.dose == dose &&
      other.scheduledTime == scheduledTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      dose.hashCode ^
      scheduledTime.hashCode;
  }
}