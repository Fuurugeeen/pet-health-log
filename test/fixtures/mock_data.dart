import 'package:pet_health_log/models/user.dart';
import 'package:pet_health_log/models/pet.dart';
import 'package:pet_health_log/models/daily_record.dart';

/// テスト用のモックデータを提供するクラス
class MockData {
  // ユーザーデータ
  static final testUser1 = User(
    id: 'user1',
    name: 'テストユーザー1',
    type: UserType.owner,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  static final testUser2 = User(
    id: 'user2',
    name: 'テストユーザー2',
    type: UserType.owner,
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  static final veterinarianUser = User(
    id: 'vet1',
    name: '獣医師',
    type: UserType.veterinarian,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  // ペットデータ
  static final testDog = Pet(
    id: 'pet1',
    ownerId: 'user1',
    name: 'ポチ',
    type: PetType.dog,
    breed: '柴犬',
    birthDate: DateTime(2020, 5, 15),
    gender: Gender.male,
    weight: 10.5,
    medicalHistory: ['ワクチン接種済み'],
    allergies: [],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  static final testCat = Pet(
    id: 'pet2',
    ownerId: 'user1',
    name: 'タマ',
    type: PetType.cat,
    breed: 'アメリカンショートヘア',
    birthDate: DateTime(2021, 3, 20),
    gender: Gender.female,
    weight: 4.2,
    medicalHistory: [],
    allergies: ['魚アレルギー'],
    veterinarian: '田中動物病院',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  static final testPetUser2 = Pet(
    id: 'pet3',
    ownerId: 'user2',
    name: 'シロ',
    type: PetType.dog,
    breed: 'トイプードル',
    birthDate: DateTime(2022, 1, 10),
    gender: Gender.male,
    weight: 3.5,
    medicalHistory: [],
    allergies: [],
    currentTreatment: '皮膚炎治療中',
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  // 食事記録
  static final testMeal1 = MealRecord(
    id: 'meal1',
    time: DateTime(2024, 10, 31, 8, 0),
    foodType: 'ドライフード',
    amount: 100,
    appetiteLevel: 5,
    notes: '完食',
  );

  static final testMeal2 = MealRecord(
    id: 'meal2',
    time: DateTime(2024, 10, 31, 18, 0),
    foodType: 'ドライフード',
    amount: 100,
    appetiteLevel: 3,
    notes: '少し残した',
  );

  // 投薬記録
  static final testMedication = MedicationRecord(
    id: 'med1',
    medicationName: '皮膚炎薬',
    time: DateTime(2024, 10, 31, 9, 0),
    dosage: 1.0,
    administrationMethod: '経口',
    hasSideEffects: false,
  );

  // 排泄記録
  static final testExcretion1 = ExcretionRecord(
    id: 'exc1',
    time: DateTime(2024, 10, 31, 7, 0),
    type: ExcretionType.urine,
    hasAbnormality: false,
  );

  static final testExcretion2 = ExcretionRecord(
    id: 'exc2',
    time: DateTime(2024, 10, 31, 10, 0),
    type: ExcretionType.stool,
    condition: StoolCondition.normal,
    color: '茶色',
    amount: '普通',
    hasAbnormality: false,
  );

  // 散歩記録
  static final testWalk = WalkRecord(
    id: 'walk1',
    startTime: DateTime(2024, 10, 31, 6, 0),
    endTime: DateTime(2024, 10, 31, 6, 30),
    duration: 30,
    distance: 2.5,
    route: '公園コース',
    activityLevel: 4,
  );

  // 健康状態
  static final testHealthStatus = HealthStatus(
    temperature: 38.5,
    weight: 10.5,
    activityLevel: 4,
    symptoms: [],
    notes: '元気です',
  );

  static final abnormalHealthStatus = HealthStatus(
    temperature: 39.5,
    weight: 10.3,
    activityLevel: 2,
    symptoms: [Symptom.cough, Symptom.lethargy],
    notes: '咳が出ている',
  );

  // 日次記録
  static final testDailyRecord1 = DailyRecord(
    id: 'record1',
    petId: 'pet1',
    date: DateTime(2024, 10, 31),
    meals: [testMeal1, testMeal2],
    medications: [],
    excretions: [testExcretion1, testExcretion2],
    walks: [testWalk],
    healthStatus: testHealthStatus,
    createdAt: DateTime(2024, 10, 31, 7, 0),
    updatedAt: DateTime(2024, 10, 31, 19, 0),
  );

  static final testDailyRecord2 = DailyRecord(
    id: 'record2',
    petId: 'pet1',
    date: DateTime(2024, 10, 30),
    meals: [testMeal1],
    medications: [testMedication],
    excretions: [testExcretion1],
    walks: [],
    healthStatus: abnormalHealthStatus,
    notes: '動物病院受診',
    createdAt: DateTime(2024, 10, 30, 7, 0),
    updatedAt: DateTime(2024, 10, 30, 20, 0),
  );

  static final testDailyRecord3 = DailyRecord(
    id: 'record3',
    petId: 'pet2',
    date: DateTime(2024, 10, 31),
    meals: [testMeal1],
    medications: [],
    excretions: [testExcretion1],
    walks: [],
    createdAt: DateTime(2024, 10, 31, 7, 0),
    updatedAt: DateTime(2024, 10, 31, 19, 0),
  );
}
