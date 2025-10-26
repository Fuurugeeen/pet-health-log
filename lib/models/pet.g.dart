// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 2;

  @override
  Pet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pet(
      id: fields[0] as String,
      ownerId: fields[1] as String,
      name: fields[2] as String,
      type: fields[3] as PetType,
      breed: fields[4] as String,
      birthDate: fields[5] as DateTime,
      gender: fields[6] as Gender,
      weight: fields[7] as double,
      photoBase64: fields[8] as String?,
      medicalHistory: (fields[9] as List).cast<String>(),
      allergies: (fields[10] as List).cast<String>(),
      currentTreatment: fields[11] as String?,
      veterinarian: fields[12] as String?,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ownerId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.breed)
      ..writeByte(5)
      ..write(obj.birthDate)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.photoBase64)
      ..writeByte(9)
      ..write(obj.medicalHistory)
      ..writeByte(10)
      ..write(obj.allergies)
      ..writeByte(11)
      ..write(obj.currentTreatment)
      ..writeByte(12)
      ..write(obj.veterinarian)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PetTypeAdapter extends TypeAdapter<PetType> {
  @override
  final int typeId = 3;

  @override
  PetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PetType.dog;
      case 1:
        return PetType.cat;
      case 2:
        return PetType.other;
      default:
        return PetType.dog;
    }
  }

  @override
  void write(BinaryWriter writer, PetType obj) {
    switch (obj) {
      case PetType.dog:
        writer.writeByte(0);
        break;
      case PetType.cat:
        writer.writeByte(1);
        break;
      case PetType.other:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 4;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      default:
        return Gender.male;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.male:
        writer.writeByte(0);
        break;
      case Gender.female:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
