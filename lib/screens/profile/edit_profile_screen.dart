import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../state/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const String _countryPrefix = '+90 ';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;
  late final TextEditingController _bioController;
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedAvatarFile;
  Uint8List? _selectedAvatarBytes;
  bool _removeAvatar = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final user = appState.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    final phone = user?.phone ?? '';
    final formatted = phone.trim().isEmpty
        ? ''
        : phone.replaceFirst(RegExp(r'^\+?90'), '').trim();
    _phoneController = TextEditingController(text: formatted);
    _companyController = TextEditingController(text: user?.company ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _selectedAvatarFile = file;
        _selectedAvatarBytes = bytes;
        _removeAvatar = false;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf seçilemedi: $error')),
      );
    }
  }

  void _removeAvatarImage() {
    setState(() {
      _selectedAvatarFile = null;
      _selectedAvatarBytes = null;
      _removeAvatar = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = context.read<AppState>();

    setState(() => _isSaving = true);
    try {
      await appState.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        company: _companyController.text.trim(),
        bio: _bioController.text.trim(),
        avatarFile: _selectedAvatarFile,
        removeAvatar: _removeAvatar,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profiliniz güncellendi.')),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil güncellenemedi: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  ImageProvider? _avatarImage(AppUser? user) {
    if (_selectedAvatarBytes != null) {
      return MemoryImage(_selectedAvatarBytes!);
    }
    final avatarUrl = _removeAvatar ? '' : (user?.avatarUrl ?? '');
    if (avatarUrl.isNotEmpty) {
      return NetworkImage(avatarUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: .12),
                    backgroundImage: _avatarImage(user),
                    child: _avatarImage(user) == null
                        ? const Icon(Icons.person_rounded, size: 48)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _isSaving ? null : _pickAvatar,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_camera_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!_removeAvatar && ((user?.avatarUrl ?? '').trim().isNotEmpty))
              TextButton.icon(
                onPressed: _isSaving ? null : _removeAvatarImage,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Profil fotoğrafını kaldır'),
              ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Ad Soyad'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Adınızı girin' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      prefixText: _countryPrefix,
                    ),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.isEmpty) {
                        return 'Telefon numarası giriniz';
                      }
                      if (digits.length < 10) {
                        return 'Telefon numarası eksik görünüyor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyController,
                    decoration:
                        const InputDecoration(labelText: 'Şirket / Kurum (opsiyonel)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(labelText: 'Hakkında (opsiyonel)'),
                    minLines: 3,
                    maxLines: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
