import 'dart:math';
import 'package:uuid/uuid.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/pet/data/pet_repository.dart';
import '../features/record/data/daily_record_repository.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../models/daily_record.dart';

class SampleDataService {
  static final _uuid = const Uuid();
  static final _random = Random();
  
  // 初回起動時のシンプルなサンプルデータ生成
  static Future<void> generateInitialSampleData() async {
    try {
      final petRepository = PetRepository();
      
      // 既存のペットがある場合はスキップ
      final existingPets = await petRepository.getAllPets();
      if (existingPets.isNotEmpty) {
        // print('既存のペットがあるため、サンプルデータの生成をスキップします');
        return;
      }
      
      // デフォルトのサンプルペット（ポチ）を作成
      final samplePet = Pet(
        id: _uuid.v4(),
        ownerId: 'default_user', // デフォルトユーザーID
        name: 'ポチ',
        type: PetType.dog,
        breed: '柴犬',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 3)), // 3歳
        gender: Gender.male,
        weight: 8.5,
        medicalHistory: [],
        allergies: [],
        veterinarian: 'サンプル動物病院',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await petRepository.createPet(samplePet);
      // print('サンプルペット「${samplePet.name}」を作成しました');
      
      // デモ用の記録データを生成
      await generateDemoRecordsForPet(samplePet.id);
    } catch (error) {
      // print('サンプルデータ生成エラー: $error');
    }
  }

  static Future<void> generateSampleData() async {
    // final authRepository = AuthRepository();
    final petRepository = PetRepository();

    // サンプルユーザーの作成
    final user = User(
      id: _uuid.v4(),
      name: 'サンプルユーザー',
      type: UserType.owner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // ユーザーのサンプルペットを作成
    final pets = [
      Pet(
        id: _uuid.v4(),
        ownerId: user.id,
        name: 'ポチ',
        type: PetType.dog,
        breed: '柴犬',
        birthDate: DateTime.now().subtract(Duration(days: 365 * 3)),
        gender: Gender.male,
        weight: 8.5,
        medicalHistory: ['膝蓋骨脱臼'],
        allergies: ['鶏肉'],
        currentTreatment: '関節サプリメント',
        veterinarian: '〇〇動物病院 田中先生',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Pet(
        id: _uuid.v4(),
        ownerId: user.id,
        name: 'ミケ',
        type: PetType.cat,
        breed: '三毛猫',
        birthDate: DateTime.now().subtract(Duration(days: 365 * 2)),
        gender: Gender.female,
        weight: 4.2,
        medicalHistory: [],
        allergies: [],
        veterinarian: '〇〇動物病院 田中先生',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // 過去30日分の記録を生成
    for (final pet in pets) {
      await petRepository.createPet(pet);
      
      for (int i = 0; i < 30; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        
        // 食事記録
        // final meals = [
        //   MealRecord(
        //     id: _uuid.v4(),
        //     time: DateTime(date.year, date.month, date.day, 8, 0),
        //     foodType: '朝食（ドライフード）',
        //     amount: 50 + _random.nextDouble() * 20,
        //     appetiteLevel: 3 + _random.nextInt(3),
        //   ),
        //   MealRecord(
        //     id: _uuid.v4(),
        //     time: DateTime(date.year, date.month, date.day, 18, 0),
        //     foodType: '夕食（ドライフード）',
        //     amount: 50 + _random.nextDouble() * 20,
        //     appetiteLevel: 3 + _random.nextInt(3),
        //   ),
        // ];

        // 排泄記録
        final excretions = <ExcretionRecord>[];
        for (int j = 0; j < 2 + _random.nextInt(3); j++) {
          excretions.add(
            ExcretionRecord(
              id: _uuid.v4(),
              time: DateTime(date.year, date.month, date.day, 9 + j * 4, 0),
              type: _random.nextBool() ? ExcretionType.stool : ExcretionType.urine,
              condition: StoolCondition.values[_random.nextInt(StoolCondition.values.length)],
              hasAbnormality: _random.nextDouble() < 0.1, // 10%の確率で異常
            ),
          );
        }

        // 体調記録
        // final healthStatus = HealthStatus(
        //   temperature: 38.0 + _random.nextDouble() * 2, // 38-40度
        //   weight: pet.weight + (_random.nextDouble() - 0.5) * 0.2, // ±0.1kg
        //   activityLevel: 3 + _random.nextInt(3),
        //   symptoms: _random.nextDouble() < 0.2 // 20%の確率で症状あり
        //       ? [Symptom.values[_random.nextInt(Symptom.values.length)]]
        //       : [],
        // );

        // 投薬記録（たまに）
        final medications = <MedicationRecord>[];
        if (pet.name == 'ポチ' && _random.nextDouble() < 0.3) {
          medications.add(
            MedicationRecord(
              id: _uuid.v4(),
              medicationName: '関節サプリメント',
              time: DateTime(date.year, date.month, date.day, 12, 0),
              dosage: 1.0,
              administrationMethod: '経口',
              hasSideEffects: false,
            ),
          );
        }

        // TODO: DailyRecordRepositoryに保存
        // final dailyRecord = DailyRecord(
        //   id: _uuid.v4(),
        //   petId: pet.id,
        //   date: date,
        //   meals: meals,
        //   medications: medications,
        //   excretions: excretions,
        //   healthStatus: healthStatus,
        //   notes: _random.nextDouble() < 0.1 ? '今日は元気でした' : null,
        //   createdAt: date,
        //   updatedAt: date,
        // );
        // await dailyRecordRepository.createRecord(dailyRecord);
      }
    }
  }

  static Future<bool> hasSampleData() async {
    final authRepository = AuthRepository();
    final users = await authRepository.getAllUsers();
    return users.any((user) => user.name == 'サンプルユーザー');
  }

  // デモ用の記録データを生成（各タブ3件ずつ）
  static Future<void> generateDemoRecordsForPet(String petId) async {
    final dailyRecordRepository = DailyRecordRepository();
    final now = DateTime.now();

    try {
      // 今日から過去3日分のデータを作成
      for (int dayOffset = 0; dayOffset < 3; dayOffset++) {
        final date = now.subtract(Duration(days: dayOffset));
        
        // 食事記録（各日3件）
        final meals = <MealRecord>[
          MealRecord(
            id: _uuid.v4(),
            time: DateTime(date.year, date.month, date.day, 8, 0),
            foodType: '朝食（ドライフード）',
            amount: 50.0,
            appetiteLevel: 5,
            notes: '完食しました',
          ),
          MealRecord(
            id: _uuid.v4(),
            time: DateTime(date.year, date.month, date.day, 12, 30),
            foodType: 'おやつ（ささみ）',
            amount: 20.0,
            appetiteLevel: 4,
          ),
          MealRecord(
            id: _uuid.v4(),
            time: DateTime(date.year, date.month, date.day, 18, 0),
            foodType: '夕食（ドライフード）',
            amount: 50.0,
            appetiteLevel: 4,
            notes: '少し残しました',
          ),
        ];

        // 投薬記録（各日1-2件）
        final medications = <MedicationRecord>[
          MedicationRecord(
            id: _uuid.v4(),
            medicationName: '関節サプリメント',
            time: DateTime(date.year, date.month, date.day, 9, 0),
            dosage: 1.0,
            administrationMethod: '経口',
            hasSideEffects: false,
          ),
          if (dayOffset == 0) // 今日だけ追加
            MedicationRecord(
              id: _uuid.v4(),
              medicationName: 'ビタミン剤',
              time: DateTime(date.year, date.month, date.day, 20, 0),
              dosage: 0.5,
              administrationMethod: '経口',
              hasSideEffects: false,
            ),
        ];

        // 排泄記録（各日2-3件）
        final excretions = <ExcretionRecord>[
          ExcretionRecord(
            id: _uuid.v4(),
            time: DateTime(date.year, date.month, date.day, 7, 30),
            type: ExcretionType.urine,
            hasAbnormality: false,
            notes: '正常',
          ),
          ExcretionRecord(
            id: _uuid.v4(),
            time: DateTime(date.year, date.month, date.day, 9, 15),
            type: ExcretionType.stool,
            condition: StoolCondition.normal,
            hasAbnormality: false,
          ),
          ExcretionRecord(
            id: _uuid.v4(),
            time: DateTime(date.year, date.month, date.day, 15, 45),
            type: ExcretionType.urine,
            hasAbnormality: false,
          ),
        ];

        // 散歩記録（各日1-2件）
        final walks = <WalkRecord>[
          WalkRecord(
            id: _uuid.v4(),
            startTime: DateTime(date.year, date.month, date.day, 7, 0),
            endTime: DateTime(date.year, date.month, date.day, 7, 30),
            duration: 30,
            distance: 1.5,
            route: '近所の公園',
            activityLevel: 4,
            notes: '元気に歩きました',
          ),
          if (dayOffset == 0) // 今日だけ夕方の散歩も追加
            WalkRecord(
              id: _uuid.v4(),
              startTime: DateTime(date.year, date.month, date.day, 17, 0),
              endTime: DateTime(date.year, date.month, date.day, 17, 45),
              duration: 45,
              distance: 2.0,
              route: '川沿いの遊歩道',
              activityLevel: 5,
              notes: '他の犬と遊びました',
            ),
        ];

        // 体調記録
        final healthStatus = HealthStatus(
          temperature: 38.2 + _random.nextDouble() * 0.6, // 38.2-38.8度
          weight: 8.5 + (_random.nextDouble() - 0.5) * 0.2, // 8.4-8.6kg
          activityLevel: 4 + _random.nextInt(2), // 4-5
          symptoms: dayOffset == 2 ? [Symptom.cough] : [], // 2日前に軽い咳
          notes: dayOffset == 0 ? '今日も元気です' : null,
        );

        // DailyRecordを作成して保存
        final dailyRecord = DailyRecord(
          id: _uuid.v4(),
          petId: petId,
          date: date,
          meals: meals,
          medications: medications,
          excretions: excretions,
          walks: walks,
          healthStatus: healthStatus,
          notes: dayOffset == 1 ? '食欲旺盛でした' : null,
          createdAt: date,
          updatedAt: date,
        );

        await dailyRecordRepository.createRecord(dailyRecord);
      }
      
      // print('デモ記録データを生成しました（3日分）');
    } catch (error) {
      // print('デモ記録データ生成エラー: $error');
    }
  }
}