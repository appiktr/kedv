import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/helper/location_helper.dart';
import 'package:kedv/model/report_issue_model.dart';
import 'package:kedv/service/report_service.dart';
import 'package:kedv/service/profile_service.dart';
import 'package:kedv/widgets/app_button.dart';
import 'package:kedv/widgets/app_text_field.dart';
import 'package:kedv/widgets/image_source_sheet.dart';

class ReportIssueView extends StatefulWidget {
  const ReportIssueView({super.key});

  @override
  State<ReportIssueView> createState() => _ReportIssueViewState();
}

class _ReportIssueViewState extends State<ReportIssueView> {
  final MapController _mapController = MapController();
  final ReportService _reportService = ReportService();
  final ProfileService _profileService = ProfileService();

  // Location State
  LatLng? _currentLocation;
  LatLng? _selectedLocation;

  // Data State
  List<ReportMenuItem> _categories = [];
  List<ReportFinalQuestion> _finalQuestions = [];

  // Selection State
  String? _selectedCategoryKey;
  String? _selectedSubCategoryKey;
  String? _selectedLeafKey;

  // Computed helpers to get objects from keys
  ReportMenuItem? get _selectedCategory {
    if (_selectedCategoryKey == null) return null;
    try {
      return _categories.firstWhere((e) => e.key == _selectedCategoryKey);
    } catch (_) {
      return null;
    }
  }

  ReportSubCategory? get _selectedSubCategory {
    final cat = _selectedCategory;
    if (cat == null || _selectedSubCategoryKey == null) return null;
    try {
      return cat.subCategoriesList.firstWhere((e) => e.key == _selectedSubCategoryKey);
    } catch (_) {
      return null;
    }
  }

  // Form State
  final Map<String, dynamic> _answers = {}; // key: value
  File? _selectedImage;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _initLocation();
    await _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    try {
      final response = await _reportService.getMenu2Questions();
      if (response != null) {
        setState(() {
          _categories = response.data.categories;
          _finalQuestions = response.data.finalQuestions;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Veriler yüklenirken hata oluştu: $e';
        });
      }
    }
  }

  Future<void> _initLocation() async {
    final location = await LocationHelper.getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = location;
        _selectedLocation = location;
        _isLoading = false;
      });
    } else {
      // Fallback or error handled by helper mostly, but let's just stop loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  Future<void> _pickImage() async {
    final source = await ImageSourceSheet.show(context);
    if (source != null) {
      _pickImageFromSource(source);
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        // Permission errors or cancellations usually happen here
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fotoğraf seçilemedi: $e')));
      }
    }
  }

  void _onSubmit() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen konum seçiniz.')));
      return;
    }
    if (_selectedCategoryKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir kategori seçiniz.')));
      return;
    }
    if (_selectedSubCategoryKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen alt kategori seçiniz.')));
      return;
    }

    // Check leaf only if subcategory has issues
    // We use the computed getter _selectedSubCategory to check issuesList
    final subCat = _selectedSubCategory;
    if (subCat != null && subCat.issuesList.isNotEmpty && _selectedLeafKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen detay seçiniz.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Upload Media if exists
      String? imageFilename;
      if (_selectedImage != null) {
        imageFilename = await _reportService.uploadMedia(_selectedImage!);
      }

      // 2. Get Profile ID
      final profile = await _profileService.getProfile();
      if (profile == null) throw Exception('Kullanıcı bilgisi alınamadı.');

      // 3. Build Payload
      final payload = <String, dynamic>{
        'profile_id': profile.id,
        'date': _formatDate(DateTime.now()),
        'location': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
        'category': _selectedCategoryKey,
        'subCategory': _selectedSubCategoryKey,
        if (_selectedLeafKey != null) 'sub_subCategory': _selectedLeafKey,
        // Add final questions
        ..._answers,
      };

      if (imageFilename != null) {
        payload['image'] = imageFilename;
      }

      await _reportService.submitReport(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Raporunuz başarıyla gönderildi!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Resolve computed helpers for UI building
    final selectedCat = _selectedCategory;
    final selectedSub = _selectedSubCategory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sorun Bildir'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                    IconButton(
                      onPressed: _initData,
                      icon: const Icon(Icons.refresh, color: Colors.red),
                    ),
                  ],
                ),
              ),

            // Map
            if (_errorMessage == null) SizedBox(height: 250, child: _buildMap()),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Sorunu Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            // LEVEL 1: Category
            _buildDropdown<String>(
              label: 'Kategori',
              value: _selectedCategoryKey,
              items: _categories.map((e) => e.key!).toList(),
              itemLabel: (key) {
                try {
                  final item = _categories.firstWhere((e) => e.key == key);
                  return item.label ?? item.title ?? 'Seçiniz';
                } catch (_) {
                  return '';
                }
              },
              onChanged: (val) {
                setState(() {
                  _selectedCategoryKey = val;
                  _selectedSubCategoryKey = null;
                  _selectedLeafKey = null;
                });
              },
            ),

            // LEVEL 2: SubCategory
            if (selectedCat != null)
              _buildDropdown<String>(
                label: 'Alt Kategori',
                value: _selectedSubCategoryKey,
                items: selectedCat.subCategoriesList.map((e) => e.key!).toList(),
                itemLabel: (key) {
                  try {
                    final item = selectedCat.subCategoriesList.firstWhere((e) => e.key == key);
                    return item.label ?? 'Seçiniz';
                  } catch (_) {
                    return '';
                  }
                },
                onChanged: (val) {
                  setState(() {
                    _selectedSubCategoryKey = val;
                    _selectedLeafKey = null;
                  });
                },
              ),

            // LEVEL 3: Leaf (SubSubCategory)
            if (selectedSub != null && selectedSub.issuesList.isNotEmpty)
              _buildDropdown<String>(
                label: 'Sorun Detayı',
                value: _selectedLeafKey,
                items: selectedSub.issuesList.map((e) => e.key).toList(),
                itemLabel: (key) {
                  try {
                    return selectedSub.issuesList.firstWhere((e) => e.key == key).value;
                  } catch (_) {
                    return '';
                  }
                },
                onChanged: (val) {
                  setState(() {
                    _selectedLeafKey = val;
                  });
                },
              ),

            const SizedBox(height: 24),

            // Final Questions Form
            if (_finalQuestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _finalQuestions.map((q) {
                    if (q.type == 'text') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q.label ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            AppTextField(
                              hintText: q.placeholder ?? '',
                              maxLines: 3,
                              onChanged: (val) {
                                _answers[q.field ?? q.key ?? ''] = val;
                              },
                            ),
                          ],
                        ),
                      );
                    } else if (q.type == 'image') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.label ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickImage,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                    )
                                  : const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt, color: Colors.grey),
                                          Text('Fotoğraf Ekle', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(text: 'Gönder', isLoading: _isSubmitting, onTap: _onSubmit),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMap() {
    final center = _selectedLocation ?? _currentLocation ?? const LatLng(41.0082, 28.9784);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: center, initialZoom: 15, onTap: _onMapTap),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        MarkerLayer(
          markers: [
            if (_selectedLocation != null)
              Marker(
                point: _selectedLocation!,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, color: AppColors.primary, size: 40),
              ),
          ],
        ),
      ],
    );
  }
}
