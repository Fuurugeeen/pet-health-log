import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/pet/data/pet_repository.dart';
import '../../models/pet.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepository();
});

final petsProvider = StateNotifierProvider<PetsNotifier, AsyncValue<List<Pet>>>((ref) {
  return PetsNotifier(ref.read(petRepositoryProvider), ref);
});

final selectedPetProvider = StateProvider<Pet?>((ref) => null);

class PetsNotifier extends StateNotifier<AsyncValue<List<Pet>>> {
  final PetRepository _petRepository;
  final Ref _ref;

  PetsNotifier(this._petRepository, this._ref) : super(const AsyncValue.loading()) {
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      // モック版では認証を簡略化し、全ペットを取得
      final pets = await _petRepository.getAllPets();
      state = AsyncValue.data(pets);
      
      // 最初のペットを選択状態にする
      if (pets.isNotEmpty) {
        final selectedPet = _ref.read(selectedPetProvider);
        if (selectedPet == null || !pets.any((pet) => pet.id == selectedPet.id)) {
          _ref.read(selectedPetProvider.notifier).state = pets.first;
        }
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addPet(Pet pet) async {
    try {
      await _petRepository.createPet(pet);
      await _loadPets();
      
      // 新しく追加されたペットを選択状態にする
      _ref.read(selectedPetProvider.notifier).state = pet;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePet(Pet pet) async {
    try {
      final updatedPet = await _petRepository.updatePet(pet);
      await _loadPets();
      
      // 更新されたペットが選択中の場合、選択状態も更新
      final selectedPet = _ref.read(selectedPetProvider);
      if (selectedPet?.id == pet.id) {
        _ref.read(selectedPetProvider.notifier).state = updatedPet;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deletePet(String petId) async {
    try {
      await _petRepository.deletePet(petId);
      await _loadPets();
      
      // 削除されたペットが選択中の場合、選択状態をクリア
      final selectedPet = _ref.read(selectedPetProvider);
      if (selectedPet?.id == petId) {
        final pets = state.value ?? [];
        _ref.read(selectedPetProvider.notifier).state = 
            pets.isNotEmpty ? pets.first : null;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadPets();
  }
}

final petProvider = Provider.family<AsyncValue<Pet?>, String>((ref, petId) {
  final pets = ref.watch(petsProvider);
  return pets.when(
    data: (petList) {
      final pet = petList.where((p) => p.id == petId).firstOrNull;
      return AsyncValue.data(pet);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});