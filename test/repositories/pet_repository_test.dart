import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pet_health_log/features/pet/data/pet_repository.dart';
import 'package:pet_health_log/models/pet.dart';
import 'package:pet_health_log/services/hive_service.dart';
import '../helpers/hive_test_helper.dart';
import '../fixtures/mock_data.dart';

void main() {
  group('PetRepository Tests', () {
    late PetRepository petRepository;
    late Box<Pet> petBox;

    setUp(() async {
      await HiveTestHelper.initializeHive();
      petBox = await HiveTestHelper.openBox<Pet>(HiveService.petBoxName);
      petRepository = PetRepository();
    });

    tearDown(() async {
      await HiveTestHelper.tearDown();
    });

    group('createPet', () {
      test('ペットを作成できる', () async {
        final pet = await petRepository.createPet(MockData.testDog);

        expect(pet.id, MockData.testDog.id);
        expect(pet.name, MockData.testDog.name);
        expect(petBox.containsKey(pet.id), true);
      });

      test('作成したペットが保存される', () async {
        await petRepository.createPet(MockData.testDog);

        final savedPet = await petBox.get(MockData.testDog.id);
        expect(savedPet, isNotNull);
        expect(savedPet!.name, MockData.testDog.name);
        expect(savedPet.type, MockData.testDog.type);
      });
    });

    group('getPet', () {
      test('ペットを取得できる', () async {
        await petBox.put(MockData.testDog.id, MockData.testDog);

        final pet = await petRepository.getPet(MockData.testDog.id);

        expect(pet, isNotNull);
        expect(pet!.id, MockData.testDog.id);
        expect(pet.name, MockData.testDog.name);
      });

      test('存在しないペットの場合はnullを返す', () async {
        final pet = await petRepository.getPet('non_existent_id');

        expect(pet, null);
      });
    });

    group('getPets', () {
      test('特定のオーナーのペットを取得できる', () async {
        await petBox.put(MockData.testDog.id, MockData.testDog);
        await petBox.put(MockData.testCat.id, MockData.testCat);
        await petBox.put(MockData.testPetUser2.id, MockData.testPetUser2);

        final pets = await petRepository.getPets('user1');

        expect(pets.length, 2);
        expect(pets.any((p) => p.id == MockData.testDog.id), true);
        expect(pets.any((p) => p.id == MockData.testCat.id), true);
        expect(pets.any((p) => p.id == MockData.testPetUser2.id), false);
      });

      test('ペットが存在しない場合は空リストを返す', () async {
        final pets = await petRepository.getPets('user1');

        expect(pets, isEmpty);
      });

      test('ペットは作成日時の降順でソートされる', () async {
        final oldPet = MockData.testDog.copyWith(
          createdAt: DateTime(2024, 1, 1),
        );
        final newPet = MockData.testCat.copyWith(
          createdAt: DateTime(2024, 12, 1),
        );

        await petBox.put(oldPet.id, oldPet);
        await petBox.put(newPet.id, newPet);

        final pets = await petRepository.getPets('user1');

        expect(pets.first.id, newPet.id);
        expect(pets.last.id, oldPet.id);
      });
    });

    group('getAllPets', () {
      test('すべてのペットを取得できる', () async {
        await petBox.put(MockData.testDog.id, MockData.testDog);
        await petBox.put(MockData.testCat.id, MockData.testCat);
        await petBox.put(MockData.testPetUser2.id, MockData.testPetUser2);

        final pets = await petRepository.getAllPets();

        expect(pets.length, 3);
      });

      test('ペットが存在しない場合は空リストを返す', () async {
        final pets = await petRepository.getAllPets();

        expect(pets, isEmpty);
      });
    });

    group('updatePet', () {
      test('ペット情報を更新できる', () async {
        await petBox.put(MockData.testDog.id, MockData.testDog);

        final updatedPet = MockData.testDog.copyWith(name: '更新されたポチ');
        await petRepository.updatePet(updatedPet);

        final savedPet = await petBox.get(MockData.testDog.id);
        expect(savedPet!.name, '更新されたポチ');
      });

      test('更新時にupdatedAtが更新される', () async {
        await petBox.put(MockData.testDog.id, MockData.testDog);

        // 少し待ってから更新
        await Future.delayed(const Duration(milliseconds: 10));

        final result = await petRepository.updatePet(MockData.testDog);

        expect(result.updatedAt.isAfter(MockData.testDog.updatedAt), true);

        final savedPet = await petBox.get(MockData.testDog.id);
        expect(savedPet!.updatedAt.isAfter(MockData.testDog.updatedAt), true);
      });

      test('体重を更新できる', () async {
        await petBox.put(MockData.testDog.id, MockData.testDog);

        final updatedPet = MockData.testDog.copyWith(weight: 11.0);
        await petRepository.updatePet(updatedPet);

        final savedPet = await petBox.get(MockData.testDog.id);
        expect(savedPet!.weight, 11.0);
      });
    });

    group('deletePet', () {
      test('ペットを削除できる', () async {
        await petBox.put(MockData.testDog.id, MockData.testDog);

        await petRepository.deletePet(MockData.testDog.id);

        expect(petBox.containsKey(MockData.testDog.id), false);
      });

      test('存在しないペットを削除してもエラーにならない', () async {
        // 例外が発生しないことを確認
        await petRepository.deletePet('non_existent_id');
        // テスト成功
      });
    });

    group('getPetCount', () {
      test('特定のオーナーのペット数を取得できる', () async {
        await petBox.put(MockData.testDog.id, MockData.testDog);
        await petBox.put(MockData.testCat.id, MockData.testCat);
        await petBox.put(MockData.testPetUser2.id, MockData.testPetUser2);

        final count = await petRepository.getPetCount('user1');

        expect(count, 2);
      });

      test('ペットが存在しない場合は0を返す', () async {
        final count = await petRepository.getPetCount('user1');

        expect(count, 0);
      });
    });

    group('getLastUpdatedPet', () {
      test('最後に更新されたペットを取得できる', () async {
        final oldPet = MockData.testDog.copyWith(
          updatedAt: DateTime(2024, 1, 1),
        );
        final newPet = MockData.testCat.copyWith(
          updatedAt: DateTime(2024, 12, 1),
        );

        await petBox.put(oldPet.id, oldPet);
        await petBox.put(newPet.id, newPet);

        final lastUpdated = await petRepository.getLastUpdatedPet('user1');

        expect(lastUpdated, isNotNull);
        expect(lastUpdated!.id, newPet.id);
      });

      test('ペットが存在しない場合はnullを返す', () async {
        final lastUpdated = await petRepository.getLastUpdatedPet('user1');

        expect(lastUpdated, null);
      });

      test('複数のペットから最新のものを取得できる', () async {
        final pet1 = MockData.testDog.copyWith(
          updatedAt: DateTime(2024, 5, 1),
        );
        final pet2 = MockData.testCat.copyWith(
          updatedAt: DateTime(2024, 10, 1),
        );
        final pet3 = MockData.testDog.copyWith(
          id: 'pet4',
          updatedAt: DateTime(2024, 7, 1),
        );

        await petBox.put(pet1.id, pet1);
        await petBox.put(pet2.id, pet2);
        await petBox.put(pet3.id, pet3);

        final lastUpdated = await petRepository.getLastUpdatedPet('user1');

        expect(lastUpdated!.id, pet2.id);
      });
    });
  });
}
