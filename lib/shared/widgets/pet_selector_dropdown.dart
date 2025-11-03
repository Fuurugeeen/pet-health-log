import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/pet.dart';
import '../providers/pet_provider.dart';

/// AppBar用のペット選択ドロップダウンウィジェット
///
/// 選択されているペットを切り替えるためのドロップダウンボタン。
/// AppBarのactionsセクションで使用されることを想定。
class PetSelectorDropdown extends ConsumerWidget {
  const PetSelectorDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPet = ref.watch(selectedPetProvider);
    final petsAsync = ref.watch(petsProvider);

    if (selectedPet == null) {
      return const SizedBox.shrink();
    }

    return DropdownButton<String>(
      value: selectedPet.id,
      underline: Container(),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      dropdownColor: AppColors.primary,
      onChanged: (petId) {
        if (petId != null) {
          petsAsync.whenData((pets) {
            final pet = pets.firstWhere((p) => p.id == petId);
            ref.read(selectedPetProvider.notifier).state = pet;
          });
        }
      },
      items: petsAsync.when(
        data: (pets) => pets.map((pet) {
          return DropdownMenuItem(
            value: pet.id,
            child: Text(
              pet.name,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        loading: () => [],
        error: (_, __) => [],
      ),
    );
  }
}
