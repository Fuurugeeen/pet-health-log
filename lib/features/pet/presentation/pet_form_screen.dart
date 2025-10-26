import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/pet.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/pet_provider.dart';

class PetFormScreen extends ConsumerStatefulWidget {
  final Pet? pet;

  const PetFormScreen({super.key, this.pet});

  @override
  ConsumerState<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends ConsumerState<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _currentTreatmentController = TextEditingController();
  final _veterinarianController = TextEditingController();

  PetType _selectedType = PetType.dog;
  Gender _selectedGender = Gender.male;
  DateTime _selectedBirthDate = DateTime.now().subtract(const Duration(days: 365));
  String? _photoBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _populateForm(widget.pet!);
    }
  }

  void _populateForm(Pet pet) {
    _nameController.text = pet.name;
    _breedController.text = pet.breed;
    _weightController.text = pet.weight.toString();
    _medicalHistoryController.text = pet.medicalHistory.join(', ');
    _allergiesController.text = pet.allergies.join(', ');
    _currentTreatmentController.text = pet.currentTreatment ?? '';
    _veterinarianController.text = pet.veterinarian ?? '';
    _selectedType = pet.type;
    _selectedGender = pet.gender;
    _selectedBirthDate = pet.birthDate;
    _photoBase64 = pet.photoBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _currentTreatmentController.dispose();
    _veterinarianController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _photoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像の選択に失敗しました: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)), // 30年前
      lastDate: DateTime.now(),
      locale: const Locale('ja'),
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('ユーザーが見つかりません');
      }

      final now = DateTime.now();
      final pet = Pet(
        id: widget.pet?.id ?? const Uuid().v4(),
        ownerId: currentUser.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        breed: _breedController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        weight: double.parse(_weightController.text),
        photoBase64: _photoBase64,
        medicalHistory: _medicalHistoryController.text.trim().isEmpty
            ? []
            : _medicalHistoryController.text.split(',').map((e) => e.trim()).toList(),
        allergies: _allergiesController.text.trim().isEmpty
            ? []
            : _allergiesController.text.split(',').map((e) => e.trim()).toList(),
        currentTreatment: _currentTreatmentController.text.trim().isEmpty
            ? null
            : _currentTreatmentController.text.trim(),
        veterinarian: _veterinarianController.text.trim().isEmpty
            ? null
            : _veterinarianController.text.trim(),
        createdAt: widget.pet?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.pet == null) {
        await ref.read(petsProvider.notifier).addPet(pet);
      } else {
        await ref.read(petsProvider.notifier).updatePet(pet);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.saveSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editPet : AppStrings.addPet),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePet,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    AppStrings.save,
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 写真セクション
            _buildPhotoSection(),
            const SizedBox(height: 24),

            // 基本情報
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '基本情報',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.petName,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PetType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: AppStrings.petType,
                        border: OutlineInputBorder(),
                      ),
                      items: PetType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.petBreed,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectBirthDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: AppStrings.birthDate,
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_selectedBirthDate.year}年${_selectedBirthDate.month}月${_selectedBirthDate.day}日',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Gender>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: AppStrings.gender,
                        border: OutlineInputBorder(),
                      ),
                      items: Gender.values.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedGender = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: '${AppStrings.weight} (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.requiredField;
                        }
                        if (double.tryParse(value) == null) {
                          return '正しい数値を入力してください';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 医療情報
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '医療情報',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _medicalHistoryController,
                      decoration: const InputDecoration(
                        labelText: '既往症（カンマ区切り）',
                        border: OutlineInputBorder(),
                        hintText: '例: 膝蓋骨脱臼, アレルギー性皮膚炎',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'アレルギー（カンマ区切り）',
                        border: OutlineInputBorder(),
                        hintText: '例: 鶏肉, 小麦',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _currentTreatmentController,
                      decoration: const InputDecoration(
                        labelText: '現在の治療',
                        border: OutlineInputBorder(),
                        hintText: '現在受けている治療があれば記入',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _veterinarianController,
                      decoration: const InputDecoration(
                        labelText: 'かかりつけ医',
                        border: OutlineInputBorder(),
                        hintText: '病院名・獣医師名',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _photoBase64 != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.memory(
                        base64Decode(_photoBase64!),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library),
            label: Text(_photoBase64 != null ? '写真を変更' : '写真を追加'),
          ),
        ],
      ),
    );
  }
}