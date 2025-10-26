// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyRecordAdapter extends TypeAdapter<DailyRecord> {
  @override
  final int typeId = 5;

  @override
  DailyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRecord(
      id: fields[0] as String,
      petId: fields[1] as String,
      date: fields[2] as DateTime,
      meals: (fields[3] as List).cast<MealRecord>(),
      medications: (fields[4] as List).cast<MedicationRecord>(),
      excretions: (fields[5] as List).cast<ExcretionRecord>(),
      healthStatus: fields[6] as HealthStatus?,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DailyRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.meals)
      ..writeByte(4)
      ..write(obj.medications)
      ..writeByte(5)
      ..write(obj.excretions)
      ..writeByte(6)
      ..write(obj.healthStatus)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealRecordAdapter extends TypeAdapter<MealRecord> {
  @override
  final int typeId = 6;

  @override
  MealRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealRecord(
      id: fields[0] as String,
      time: fields[1] as DateTime,
      foodType: fields[2] as String,
      amount: fields[3] as double,
      appetiteLevel: fields[4] as int,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.foodType)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.appetiteLevel)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicationRecordAdapter extends TypeAdapter<MedicationRecord> {
  @override
  final int typeId = 7;

  @override
  MedicationRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationRecord(
      id: fields[0] as String,
      medicationName: fields[1] as String,
      time: fields[2] as DateTime,
      dosage: fields[3] as double,
      administrationMethod: fields[4] as String,
      hasSideEffects: fields[5] as bool,
      sideEffectDetails: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicationName)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.dosage)
      ..writeByte(4)
      ..write(obj.administrationMethod)
      ..writeByte(5)
      ..write(obj.hasSideEffects)
      ..writeByte(6)
      ..write(obj.sideEffectDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExcretionRecordAdapter extends TypeAdapter<ExcretionRecord> {
  @override
  final int typeId = 8;

  @override
  ExcretionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExcretionRecord(
      id: fields[0] as String,
      time: fields[1] as DateTime,
      type: fields[2] as ExcretionType,
      condition: fields[3] as StoolCondition?,
      color: fields[4] as String?,
      amount: fields[5] as String?,
      hasAbnormality: fields[6] as bool,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExcretionRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.condition)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.hasAbnormality)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExcretionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HealthStatusAdapter extends TypeAdapter<HealthStatus> {
  @override
  final int typeId = 9;

  @override
  HealthStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthStatus(
      temperature: fields[0] as double?,
      weight: fields[1] as double?,
      activityLevel: fields[2] as int,
      symptoms: (fields[3] as List).cast<Symptom>(),
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthStatus obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.temperature)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.activityLevel)
      ..writeByte(3)
      ..write(obj.symptoms)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExcretionTypeAdapter extends TypeAdapter<ExcretionType> {
  @override
  final int typeId = 10;

  @override
  ExcretionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExcretionType.urine;
      case 1:
        return ExcretionType.stool;
      default:
        return ExcretionType.urine;
    }
  }

  @override
  void write(BinaryWriter writer, ExcretionType obj) {
    switch (obj) {
      case ExcretionType.urine:
        writer.writeByte(0);
        break;
      case ExcretionType.stool:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExcretionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoolConditionAdapter extends TypeAdapter<StoolCondition> {
  @override
  final int typeId = 11;

  @override
  StoolCondition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StoolCondition.normal;
      case 1:
        return StoolCondition.soft;
      case 2:
        return StoolCondition.hard;
      case 3:
        return StoolCondition.diarrhea;
      default:
        return StoolCondition.normal;
    }
  }

  @override
  void write(BinaryWriter writer, StoolCondition obj) {
    switch (obj) {
      case StoolCondition.normal:
        writer.writeByte(0);
        break;
      case StoolCondition.soft:
        writer.writeByte(1);
        break;
      case StoolCondition.hard:
        writer.writeByte(2);
        break;
      case StoolCondition.diarrhea:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoolConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SymptomAdapter extends TypeAdapter<Symptom> {
  @override
  final int typeId = 12;

  @override
  Symptom read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Symptom.cough;
      case 1:
        return Symptom.sneeze;
      case 2:
        return Symptom.vomiting;
      case 3:
        return Symptom.diarrhea;
      case 4:
        return Symptom.lossOfAppetite;
      case 5:
        return Symptom.lethargy;
      case 6:
        return Symptom.fever;
      case 7:
        return Symptom.other;
      default:
        return Symptom.cough;
    }
  }

  @override
  void write(BinaryWriter writer, Symptom obj) {
    switch (obj) {
      case Symptom.cough:
        writer.writeByte(0);
        break;
      case Symptom.sneeze:
        writer.writeByte(1);
        break;
      case Symptom.vomiting:
        writer.writeByte(2);
        break;
      case Symptom.diarrhea:
        writer.writeByte(3);
        break;
      case Symptom.lossOfAppetite:
        writer.writeByte(4);
        break;
      case Symptom.lethargy:
        writer.writeByte(5);
        break;
      case Symptom.fever:
        writer.writeByte(6);
        break;
      case Symptom.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
