import 'package:hive/hive.dart';

part 'daily_record.g.dart';

@HiveType(typeId: 5)
class DailyRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String petId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final List<MealRecord> meals;

  @HiveField(4)
  final List<MedicationRecord> medications;

  @HiveField(5)
  final List<ExcretionRecord> excretions;

  @HiveField(6)
  final HealthStatus? healthStatus;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  DailyRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.meals,
    required this.medications,
    required this.excretions,
    this.healthStatus,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  DailyRecord copyWith({
    String? id,
    String? petId,
    DateTime? date,
    List<MealRecord>? meals,
    List<MedicationRecord>? medications,
    List<ExcretionRecord>? excretions,
    HealthStatus? healthStatus,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      medications: medications ?? this.medications,
      excretions: excretions ?? this.excretions,
      healthStatus: healthStatus ?? this.healthStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 6)
class MealRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime time;

  @HiveField(2)
  final String foodType;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final int appetiteLevel; // 1-5

  @HiveField(5)
  final String? notes;

  MealRecord({
    required this.id,
    required this.time,
    required this.foodType,
    required this.amount,
    required this.appetiteLevel,
    this.notes,
  });

  MealRecord copyWith({
    String? id,
    DateTime? time,
    String? foodType,
    double? amount,
    int? appetiteLevel,
    String? notes,
  }) {
    return MealRecord(
      id: id ?? this.id,
      time: time ?? this.time,
      foodType: foodType ?? this.foodType,
      amount: amount ?? this.amount,
      appetiteLevel: appetiteLevel ?? this.appetiteLevel,
      notes: notes ?? this.notes,
    );
  }
}

@HiveType(typeId: 7)
class MedicationRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicationName;

  @HiveField(2)
  final DateTime time;

  @HiveField(3)
  final double dosage;

  @HiveField(4)
  final String administrationMethod;

  @HiveField(5)
  final bool hasSideEffects;

  @HiveField(6)
  final String? sideEffectDetails;

  MedicationRecord({
    required this.id,
    required this.medicationName,
    required this.time,
    required this.dosage,
    required this.administrationMethod,
    required this.hasSideEffects,
    this.sideEffectDetails,
  });

  MedicationRecord copyWith({
    String? id,
    String? medicationName,
    DateTime? time,
    double? dosage,
    String? administrationMethod,
    bool? hasSideEffects,
    String? sideEffectDetails,
  }) {
    return MedicationRecord(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      time: time ?? this.time,
      dosage: dosage ?? this.dosage,
      administrationMethod: administrationMethod ?? this.administrationMethod,
      hasSideEffects: hasSideEffects ?? this.hasSideEffects,
      sideEffectDetails: sideEffectDetails ?? this.sideEffectDetails,
    );
  }
}

@HiveType(typeId: 8)
class ExcretionRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime time;

  @HiveField(2)
  final ExcretionType type;

  @HiveField(3)
  final StoolCondition? condition;

  @HiveField(4)
  final String? color;

  @HiveField(5)
  final String? amount;

  @HiveField(6)
  final bool hasAbnormality;

  @HiveField(7)
  final String? notes;

  ExcretionRecord({
    required this.id,
    required this.time,
    required this.type,
    this.condition,
    this.color,
    this.amount,
    required this.hasAbnormality,
    this.notes,
  });

  ExcretionRecord copyWith({
    String? id,
    DateTime? time,
    ExcretionType? type,
    StoolCondition? condition,
    String? color,
    String? amount,
    bool? hasAbnormality,
    String? notes,
  }) {
    return ExcretionRecord(
      id: id ?? this.id,
      time: time ?? this.time,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      color: color ?? this.color,
      amount: amount ?? this.amount,
      hasAbnormality: hasAbnormality ?? this.hasAbnormality,
      notes: notes ?? this.notes,
    );
  }
}

@HiveType(typeId: 9)
class HealthStatus {
  @HiveField(0)
  final double? temperature;

  @HiveField(1)
  final double? weight;

  @HiveField(2)
  final int activityLevel; // 1-5

  @HiveField(3)
  final List<Symptom> symptoms;

  @HiveField(4)
  final String? notes;

  HealthStatus({
    this.temperature,
    this.weight,
    required this.activityLevel,
    required this.symptoms,
    this.notes,
  });

  HealthStatus copyWith({
    double? temperature,
    double? weight,
    int? activityLevel,
    List<Symptom>? symptoms,
    String? notes,
  }) {
    return HealthStatus(
      temperature: temperature ?? this.temperature,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
    );
  }
}

@HiveType(typeId: 10)
enum ExcretionType {
  @HiveField(0)
  urine,

  @HiveField(1)
  stool,
}

@HiveType(typeId: 11)
enum StoolCondition {
  @HiveField(0)
  normal,

  @HiveField(1)
  soft,

  @HiveField(2)
  hard,

  @HiveField(3)
  diarrhea,
}

@HiveType(typeId: 12)
enum Symptom {
  @HiveField(0)
  cough,

  @HiveField(1)
  sneeze,

  @HiveField(2)
  vomiting,

  @HiveField(3)
  diarrhea,

  @HiveField(4)
  lossOfAppetite,

  @HiveField(5)
  lethargy,

  @HiveField(6)
  fever,

  @HiveField(7)
  other,
}

// Extensions for display names
extension ExcretionTypeExtension on ExcretionType {
  String get displayName {
    switch (this) {
      case ExcretionType.urine:
        return '尿';
      case ExcretionType.stool:
        return '便';
    }
  }
}

extension StoolConditionExtension on StoolCondition {
  String get displayName {
    switch (this) {
      case StoolCondition.normal:
        return '正常';
      case StoolCondition.soft:
        return '軟便';
      case StoolCondition.hard:
        return '硬便';
      case StoolCondition.diarrhea:
        return '下痢';
    }
  }
}

extension SymptomExtension on Symptom {
  String get displayName {
    switch (this) {
      case Symptom.cough:
        return '咳';
      case Symptom.sneeze:
        return 'くしゃみ';
      case Symptom.vomiting:
        return '嘔吐';
      case Symptom.diarrhea:
        return '下痢';
      case Symptom.lossOfAppetite:
        return '食欲不振';
      case Symptom.lethargy:
        return '元気がない';
      case Symptom.fever:
        return '発熱';
      case Symptom.other:
        return 'その他';
    }
  }
}