import 'package:hive/hive.dart';

part 'pet.g.dart';

@HiveType(typeId: 2)
class Pet {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String ownerId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final PetType type;

  @HiveField(4)
  final String breed;

  @HiveField(5)
  final DateTime birthDate;

  @HiveField(6)
  final Gender gender;

  @HiveField(7)
  final double weight;

  @HiveField(8)
  final String? photoBase64;

  @HiveField(9)
  final List<String> medicalHistory;

  @HiveField(10)
  final List<String> allergies;

  @HiveField(11)
  final String? currentTreatment;

  @HiveField(12)
  final String? veterinarian;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.breed,
    required this.birthDate,
    required this.gender,
    required this.weight,
    this.photoBase64,
    required this.medicalHistory,
    required this.allergies,
    this.currentTreatment,
    this.veterinarian,
    required this.createdAt,
    required this.updatedAt,
  });

  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    PetType? type,
    String? breed,
    DateTime? birthDate,
    Gender? gender,
    double? weight,
    String? photoBase64,
    List<String>? medicalHistory,
    List<String>? allergies,
    String? currentTreatment,
    String? veterinarian,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      photoBase64: photoBase64 ?? this.photoBase64,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      currentTreatment: currentTreatment ?? this.currentTreatment,
      veterinarian: veterinarian ?? this.veterinarian,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 3)
enum PetType {
  @HiveField(0)
  dog,

  @HiveField(1)
  cat,

  @HiveField(2)
  other,
}

@HiveType(typeId: 4)
enum Gender {
  @HiveField(0)
  male,

  @HiveField(1)
  female,
}

extension PetTypeExtension on PetType {
  String get displayName {
    switch (this) {
      case PetType.dog:
        return '犬';
      case PetType.cat:
        return '猫';
      case PetType.other:
        return 'その他';
    }
  }
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'オス';
      case Gender.female:
        return 'メス';
    }
  }
}