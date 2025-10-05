import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/car_brands.dart';
import '../data/car_models.dart';
import '../data/category_tree.dart';
import '../data/cities.dart';
import '../data/models.dart';
import '../data/vehicle_categories.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  ListingCategory? _category = ListingCategory.konut;
  ListingType? _type = ListingType.satilik;
  String? _selectedCity;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();
  final TextEditingController _bodyTypeController = TextEditingController();
  final List<String> _photos = [];
  final ImagePicker _picker = ImagePicker();

  String? _draftListingId;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedEngineType;
  VehicleSubcategory? _selectedVehicleSubcategory;
  FuelType? _selectedFuelType;
  TransmissionType? _selectedTransmission;
  VehicleCondition? _selectedVehicleCondition;
  Drivetrain? _selectedDrivetrain;
  String? _selectedGeneralSubcategoryId;
  String? _selectedGeneralDetailId;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _districtController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _powerController.dispose();
    _bodyTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentCategory = _category ?? ListingCategory.konut;
    final generalNodes = listingCategoryTree[currentCategory] ?? const <CategoryNode>[];
    final primaryNode = findChildById(generalNodes, _selectedGeneralSubcategoryId);
    final detailNodes = primaryNode?.children ?? const <CategoryNode>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni İlan Oluştur')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Temel Bilgiler', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'İlan Başlığı'),
              maxLength: 200,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Başlık giriniz';
                }
                if (value.trim().length > 200) {
                  return 'Başlık 200 karakterden uzun olamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fiyat (yalnızca rakam)',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Fiyat giriniz';
                final numeric = double.tryParse(value.replaceAll(',', '.'));
                if (numeric == null) return 'Geçerli bir sayı giriniz';
                if (numeric < 0) return 'Fiyat 0\'dan küçük olamaz';
                if (numeric > 100000000) {
                  return 'Fiyat 100.000.000 değerini aşamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ListingCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: ListingCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(categoryLabel(category)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _category = value;
                  if (value != ListingCategory.arac) {
                    _selectedVehicleSubcategory = null;
                    _selectedBrand = null;
                    _selectedModel = null;
                    _selectedEngineType = null;
                    _selectedFuelType = null;
                    _selectedTransmission = null;
                    _selectedVehicleCondition = null;
                    _selectedDrivetrain = null;
                    _yearController.clear();
                    _mileageController.clear();
                    _powerController.clear();
                    _bodyTypeController.clear();
                  }
                  _selectedGeneralSubcategoryId = null;
                  _selectedGeneralDetailId = null;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ListingType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'İlan Türü'),
              items: ListingType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(listingTypeLabel(type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              key: ValueKey('city-${_selectedCity ?? 'none'}'),
              initialValue: _selectedCity,
              decoration: const InputDecoration(labelText: 'İl'),
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('Seçiniz')),
              ]
                  .followedBy(
                    kktcCities.map(
                      (city) => DropdownMenuItem<String?>(
                        value: city,
                        child: Text(city),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedCity = value),
              validator: (value) =>
                  value == null ? 'Lütfen ilan için bir il seçin' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: 'İlçe / Mahalle (opsiyonel)',
              ),
            ),
            const SizedBox(height: 16),
            if (currentCategory != ListingCategory.arac && generalNodes.isNotEmpty) ...[
              DropdownButtonFormField<String?>(
                key: ValueKey('general-${_selectedGeneralSubcategoryId ?? 'none'}'),
                initialValue: _selectedGeneralSubcategoryId,
                decoration: const InputDecoration(labelText: 'Alt Kategori'),
                items: generalNodes
                    .map(
                      (node) => DropdownMenuItem<String?>(
                        value: node.id,
                        child: Text(node.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGeneralSubcategoryId = value;
                    _selectedGeneralDetailId = null;
                  });
                },
                validator: (value) {
                  if (generalNodes.isEmpty) {
                    return null;
                  }
                  if (value == null || value.isEmpty) {
                    return '${categoryLabel(currentCategory)} için alt kategori seçin';
                  }
                  return null;
                },
              ),
              if (detailNodes.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  key: ValueKey('general-detail-${_selectedGeneralDetailId ?? 'none'}'),
                  initialValue: _selectedGeneralDetailId,
                  decoration: const InputDecoration(labelText: 'Alt Detay'),
                  items: detailNodes
                      .map(
                        (node) => DropdownMenuItem<String?>(
                          value: node.id,
                          child: Text(node.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedGeneralDetailId = value),
                  validator: (value) {
                    if (detailNodes.isEmpty) {
                      return null;
                    }
                    if (value == null || value.isEmpty) {
                      return 'Alt seçenek seçiniz';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
            if (_category == ListingCategory.arac) ...[
              DropdownButtonFormField<VehicleSubcategory?>(
                key: ValueKey('vehicle-${_selectedVehicleSubcategory?.name ?? 'all'}'),
                initialValue: _selectedVehicleSubcategory,
                decoration:
                    const InputDecoration(labelText: 'Vasıta Alt Kategorisi'),
                items: const [
                  DropdownMenuItem<VehicleSubcategory?>(
                    value: null,
                    child: Text('Seçin'),
                  ),
                ]
                    .followedBy(
                      vehicleCategoryInfos.map(
                        (info) => DropdownMenuItem<VehicleSubcategory?>(
                          value: info.type,
                          child: Row(
                            children: [
                              Icon(info.icon, size: 18),
                              const SizedBox(width: 8),
                              Text(vehicleSubcategoryLabel(info.type)),
                              if (info.badge != null) ...[
                                const SizedBox(width: 6),
                                Text(info.badge!),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedVehicleSubcategory = value;
                }),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedBrand),
                initialValue: _selectedBrand,
                decoration: const InputDecoration(labelText: 'Araç Markası'),
                items: carBrands
                    .map(
                      (brand) => DropdownMenuItem(
                        value: brand,
                        child: Text(brand),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBrand = value;
                    _selectedModel = null;
                    _selectedEngineType = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey('model-$_selectedBrand-$_selectedModel'),
                initialValue: _selectedModel,
                decoration: const InputDecoration(labelText: 'Model'),
                items: (carModels[_selectedBrand] ?? const <String>[]) 
                    .map(
                      (model) => DropdownMenuItem(
                        value: model,
                        child: Text(model),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedModel = value;
                    _selectedEngineType = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (((carEngineTypes[_selectedBrand]?[_selectedModel]) ??
                      const <String>[])
                  .isNotEmpty)
                DropdownButtonFormField<String>(
                  key: ValueKey('engine-$_selectedModel-$_selectedEngineType'),
                  initialValue: _selectedEngineType,
                  decoration: const InputDecoration(labelText: 'Motor Tipi'),
                  items: ((carEngineTypes[_selectedBrand]?[_selectedModel]) ??
                          const <String>[]) 
                      .map(
                        (engine) => DropdownMenuItem(
                          value: engine,
                          child: Text(engine),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedEngineType = value),
                ),
              if (((carEngineTypes[_selectedBrand]?[_selectedModel]) ??
                      const <String>[])
                  .isNotEmpty)
                const SizedBox(height: 16),
              DropdownButtonFormField<FuelType>(
                key: ValueKey('fuel-${_selectedFuelType?.name ?? 'none'}'),
                initialValue: _selectedFuelType,
                decoration: const InputDecoration(labelText: 'Yakıt Tipi'),
                items: FuelType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(fuelTypeLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedFuelType = value),
                validator: (value) =>
                    value == null ? 'Lütfen yakıt tipini seçin' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransmissionType>(
                key: ValueKey('transmission-${_selectedTransmission?.name ?? 'none'}'),
                initialValue: _selectedTransmission,
                decoration: const InputDecoration(labelText: 'Vites Tipi'),
                items: TransmissionType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(transmissionLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedTransmission = value),
                validator: (value) =>
                    value == null ? 'Lütfen vites tipini seçin' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VehicleCondition>(
                key: ValueKey('condition-${_selectedVehicleCondition?.name ?? 'none'}'),
                initialValue: _selectedVehicleCondition,
                decoration: const InputDecoration(labelText: 'Araç Durumu'),
                items: VehicleCondition.values
                    .map(
                      (condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(vehicleConditionLabel(condition)),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedVehicleCondition = value),
                validator: (value) =>
                    value == null ? 'Lütfen araç durumunu seçin' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Drivetrain?>(
                key: ValueKey('drivetrain-${_selectedDrivetrain?.name ?? 'none'}'),
                initialValue: _selectedDrivetrain,
                decoration: const InputDecoration(labelText: 'Çekiş (opsiyonel)'),
                items: const [
                  DropdownMenuItem<Drivetrain?>(value: null, child: Text('Seçiniz')),
                ]
                    .followedBy(
                      Drivetrain.values.map(
                        (drivetrain) => DropdownMenuItem<Drivetrain?>(
                          value: drivetrain,
                          child: Text(drivetrainLabel(drivetrain)),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedDrivetrain = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Model Yılı (opsiyonel)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Kilometre (opsiyonel)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyTypeController,
                decoration: const InputDecoration(labelText: 'Kasa Tipi (opsiyonel)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _powerController,
                decoration: const InputDecoration(labelText: 'Motor Gücü (bg) (opsiyonel)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(labelText: 'İlan Açıklaması'),
              maxLength: 5000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Açıklama zorunludur';
                }
                if (value.trim().length > 5000) {
                  return 'Açıklama 5000 karakteri aşamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Fotoğraflar', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingImage ? null : _pickImageFromDevice,
                    icon: _isUploadingImage
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : const Icon(Icons.photo_library_rounded),
                    label: Text(
                      _isUploadingImage
                          ? 'Yükleniyor...'
                          : 'Cihazdan Fotoğraf Yükle',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _promptPhotoUrl(context),
                    icon: const Icon(Icons.link_rounded),
                    label: const Text('URL Ekle'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._photos.map(
                  (photo) => Stack(
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          image: DecorationImage(
                            image: NetworkImage(photo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _photos.remove(photo)),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('İlanı Yayınla'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromDevice() async {
    try {
      final appState = context.read<AppState>();
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (file == null) return;

      _draftListingId ??= appState.repository.generateListingId();

      setState(() => _isUploadingImage = true);
      final downloadUrl = await appState.uploadListingImage(
        file: file,
        listingId: _draftListingId!,
      );

      if (!mounted) return;
      setState(() {
        _photos.add(downloadUrl);
        _isUploadingImage = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf yüklenemedi: $error')),
      );
    }
  }

  Future<void> _promptPhotoUrl(BuildContext context) async {
    final urlController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fotoğraf URL ekle'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                setState(() => _photos.add(urlController.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final appState = context.read<AppState>();
      final user = appState.currentUser;
      final ownerId = user?.id ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final listingId = _draftListingId ?? appState.repository.generateListingId();
      final priceValue = double.tryParse(
            _priceController.text.replaceAll(',', '.')) ??
        0;
      final selectedCategory = _category ?? ListingCategory.konut;

      if (_selectedCity == null) {
        throw AuthException('Lütfen ilan için bir il seçin.');
      }

      final normalizedPhone = normalizeTurkishPhone(user?.phone ?? '');
      if (normalizedPhone.isEmpty) {
        throw AuthException('Lütfen profilinizde telefon numarası ekleyin.');
      }

      CategoryNode? selectedGeneralNode;
      CategoryNode? selectedDetailNode;

      if (selectedCategory != ListingCategory.arac) {
        final nodes = listingCategoryTree[selectedCategory] ?? const <CategoryNode>[];
        if (nodes.isNotEmpty) {
          selectedGeneralNode = findChildById(nodes, _selectedGeneralSubcategoryId);
          if (selectedGeneralNode == null) {
            throw AuthException('${categoryLabel(selectedCategory)} için alt kategori seçin.');
          }
          final detailCandidates = selectedGeneralNode.children;
          if (detailCandidates.isNotEmpty) {
            selectedDetailNode = findChildById(detailCandidates, _selectedGeneralDetailId);
            if (selectedDetailNode == null) {
              throw AuthException('${selectedGeneralNode.label} için alt seçenek seçin.');
            }
          }
        }
      }

      if (selectedCategory == ListingCategory.arac) {
        if (_selectedVehicleSubcategory == null) {
          throw AuthException('Lütfen vasıta alt kategorisini seçin.');
        }
        if ((_selectedBrand ?? '').isEmpty) {
          throw AuthException('Lütfen araç markasını seçin.');
        }
        if ((carModels[_selectedBrand] ?? const <String>[]).isNotEmpty &&
            (_selectedModel ?? '').isEmpty) {
          throw AuthException('Lütfen araç modelini seçin.');
        }
        final engineOptions =
            carEngineTypes[_selectedBrand]?[_selectedModel] ??
                const <String>[];
        if (engineOptions.isNotEmpty && (_selectedEngineType ?? '').isEmpty) {
          throw AuthException('Lütfen araç motor tipini seçin.');
        }
        if (_selectedFuelType == null) {
          throw AuthException('Lütfen yakıt tipini seçin.');
        }
        if (_selectedTransmission == null) {
          throw AuthException('Lütfen vites tipini seçin.');
        }
        if (_selectedVehicleCondition == null) {
          throw AuthException('Lütfen araç durumunu seçin.');
        }
      }

      final images = _photos.isNotEmpty
          ? List<String>.from(_photos)
          : const [
              'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
            ];

      final district = _districtController.text.trim();
      final location = district.isEmpty
          ? _selectedCity!
          : '${_selectedCity!} - $district';

      final listing = Listing(
        id: listingId,
        title: _titleController.text.trim(),
        price: priceValue,
        currency: 'TL',
        images: images,
        description: _descriptionController.text.trim(),
        category: selectedCategory,
        type: _type ?? ListingType.satilik,
        location: location,
        date: DateTime.now(),
        publisher: user?.name ??
            (FirebaseAuth.instance.currentUser?.displayName ?? 'KKTC Caraba Kullanıcısı'),
        publisherId: ownerId,
        publisherAvatar: user?.avatarUrl ?? '',
        isPremium: false,
        contactPhone: normalizedPhone,
        status: ListingStatus.pending,
        reviewNotes: null,
        reviewedBy: null,
        reviewedAt: null,
        subcategory: selectedGeneralNode?.label,
        subcategoryDetail: selectedDetailNode?.label,
        vehicleSubcategory:
            selectedCategory == ListingCategory.arac ? _selectedVehicleSubcategory : null,
        brand: selectedCategory == ListingCategory.arac ? _selectedBrand : null,
        model: selectedCategory == ListingCategory.arac ? _selectedModel : null,
        engineType:
            selectedCategory == ListingCategory.arac ? _selectedEngineType : null,
        fuelType:
            selectedCategory == ListingCategory.arac ? _selectedFuelType : null,
        transmission:
            selectedCategory == ListingCategory.arac ? _selectedTransmission : null,
        condition:
            selectedCategory == ListingCategory.arac ? _selectedVehicleCondition : null,
        drivetrain:
            selectedCategory == ListingCategory.arac ? _selectedDrivetrain : null,
        bodyType:
            selectedCategory == ListingCategory.arac &&
                    _bodyTypeController.text.trim().isNotEmpty
                ? _bodyTypeController.text.trim()
                : null,
        power: selectedCategory == ListingCategory.arac
            ? int.tryParse(_powerController.text.trim())
            : null,
        year: int.tryParse(_yearController.text.trim()),
        mileage: int.tryParse(_mileageController.text.trim()),
      );

      await appState.addListing(listing);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlanınız kaydedildi! Yayınlanması için onay bekleniyor.'),
        ),
      );
      Navigator.pop(context);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İlan kaydedilemedi: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
