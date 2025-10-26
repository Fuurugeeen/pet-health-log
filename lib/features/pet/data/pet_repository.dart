import 'package:hive/hive.dart';
import '../../../models/pet.dart';
import '../../../services/hive_service.dart';

class PetRepository {
  Box get _petBox => HiveService.getPetBox();

  Future<List<Pet>> getPets(String ownerId) async {
    return _petBox.values
        .cast<Pet>()
        .where((pet) => pet.ownerId == ownerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Pet?> getPet(String id) async {
    return _petBox.get(id);
  }

  Future<Pet> createPet(Pet pet) async {
    await _petBox.put(pet.id, pet);
    return pet;
  }

  Future<Pet> updatePet(Pet pet) async {
    final updatedPet = pet.copyWith(updatedAt: DateTime.now());
    await _petBox.put(pet.id, updatedPet);
    return updatedPet;
  }

  Future<void> deletePet(String id) async {
    await _petBox.delete(id);
  }

  Future<List<Pet>> getAllPets() async {
    return _petBox.values.cast<Pet>().toList();
  }

  Future<int> getPetCount(String ownerId) async {
    return _petBox.values
        .cast<Pet>()
        .where((pet) => pet.ownerId == ownerId)
        .length;
  }

  Future<Pet?> getLastUpdatedPet(String ownerId) async {
    final pets = await getPets(ownerId);
    if (pets.isEmpty) return null;
    
    pets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return pets.first;
  }
}