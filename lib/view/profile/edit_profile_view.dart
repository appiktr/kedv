import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/location_model.dart';
import 'package:kedv/model/profile_model.dart';
import 'package:kedv/model/profile_update_request_model.dart';
import 'package:kedv/service/location_service.dart';
import 'package:kedv/service/profile_service.dart';
import 'package:kedv/widgets/app_button.dart';
import 'package:kedv/widgets/app_date_picker.dart';
import 'package:kedv/widgets/app_dropdown.dart';
import 'package:kedv/widgets/app_text_field.dart';

class EditProfileView extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileView({super.key, required this.profile});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  final _locationService = LocationService();
  final _profileService = ProfileService();

  List<City> _cities = [];
  List<District> _districts = [];
  List<Neighbourhood> _neighborhoods = [];

  City? _selectedCity;
  District? _selectedDistrict;
  Neighbourhood? _selectedNeighbourhood;
  String? _selectedGender;
  DateTime? _birthDate;

  bool _isLoading = false;
  final List<String> _genders = ['female', 'male'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.user.name);
    _phoneController = TextEditingController(text: widget.profile.user.phone);
    _addressController = TextEditingController(text: widget.profile.address);
    _selectedGender = widget.profile.gender;
    if (widget.profile.birthdate.isNotEmpty) {
      try {
        _birthDate = DateTime.parse(widget.profile.birthdate);
      } catch (_) {}
    }

    _fetchCities().then((_) {
      if (mounted) {
        // Setting initial values requires handling potential mismatches or empty lists,
        // simplistic approach for now, assuming IDs match.
        setState(() {
          _selectedCity = _cities.firstWhere(
            (element) => element.id == widget.profile.city.id,
            orElse: () => _cities.first,
          );
        });
        _fetchDistricts(_selectedCity?.id ?? widget.profile.city.id).then((_) {
          if (mounted) {
            setState(() {
              _selectedDistrict = _districts.firstWhere(
                (element) => element.id == widget.profile.district.id,
                orElse: () => _districts.first,
              );
            });
            _fetchNeighbourhoods(_selectedDistrict?.id ?? widget.profile.district.id).then((_) {
              if (mounted) {
                setState(() {
                  _selectedNeighbourhood = _neighborhoods.firstWhere(
                    (element) => element.id == widget.profile.neighbourhood.id,
                    orElse: () => _neighborhoods.first,
                  );
                });
              }
            });
          }
        });
      }
    });
  }

  Future<void> _fetchCities() async {
    try {
      final cities = await _locationService.getCities();
      if (!mounted) return;
      setState(() {
        _cities = cities;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Şehirler yüklenirken hata oluştu: $e')));
    }
  }

  Future<void> _fetchDistricts(int cityId) async {
    try {
      final districts = await _locationService.getDistricts(cityId);
      if (!mounted) return;
      setState(() {
        _districts = districts;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('İlçeler yüklenirken hata oluştu: $e')));
    }
  }

  Future<void> _fetchNeighbourhoods(int districtId) async {
    try {
      final neighborhoods = await _locationService.getNeighbourhoods(districtId);
      if (!mounted) return;
      setState(() {
        _neighborhoods = neighborhoods;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mahalleler yüklenirken hata oluştu: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen doğum tarihi seçiniz')));
        return;
      }

      setState(() => _isLoading = true);

      try {
        final request = ProfileUpdateRequestModel(
          name: _nameController.text,
          phone: _phoneController.text.replaceAll(' ', ''),
          gender: _selectedGender!,
          birthdate:
              "${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}",
          cityId: _selectedCity!.id,
          districtId: _selectedDistrict!.id,
          neighbourhoodId: _selectedNeighbourhood!.id,
          address: _addressController.text,
          currentPassword: _currentPasswordController.text.isNotEmpty ? _currentPasswordController.text : null,
          password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
          passwordConfirmation: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        );

        final success = await _profileService.updateProfile(request);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil başarıyla güncellendi!')));
            context.pop(true); // Return true to signal refresh needed
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil güncelleme başarısız.')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text('Profili Düzenle', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Ad Soyad
                AppTextField(
                  controller: _nameController,
                  label: 'Ad Soyad',
                  hintText: 'Ad Soyad giriniz',
                  validator: (value) => value == null || value.isEmpty ? 'Ad Soyad gerekli' : null,
                ),

                const SizedBox(height: 12),

                // Telefon
                AppTextField(
                  controller: _phoneController,
                  label: 'Telefon',
                  hintText: 'Telefon Numarası giriniz',
                  keyboardType: TextInputType.phone,
                  prefixText: '+90 ',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, _PhoneInputFormatter()],
                  validator: (value) => value == null || value.isEmpty ? 'Telefon numarası gerekli' : null,
                ),

                const SizedBox(height: 12),

                // Şehir
                AppDropdown<City>(
                  label: 'Şehir',
                  hintText: 'Seçiniz',
                  value: _selectedCity,
                  items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city.name))).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCity = value;
                        _selectedDistrict = null;
                        _selectedNeighbourhood = null;
                        _districts = [];
                        _neighborhoods = [];
                      });
                      _fetchDistricts(value.id);
                    }
                  },
                  validator: (value) => value == null ? 'Şehir seçiniz' : null,
                ),

                const SizedBox(height: 12),

                // İlçe
                AppDropdown<District>(
                  label: 'İlçe',
                  hintText: 'Seçiniz',
                  value: _selectedDistrict,
                  items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDistrict = value;
                        _selectedNeighbourhood = null;
                        _neighborhoods = [];
                      });
                      _fetchNeighbourhoods(value.id);
                    }
                  },
                  validator: (value) => value == null ? 'İlçe seçiniz' : null,
                ),

                const SizedBox(height: 12),

                // Mahalle
                AppDropdown<Neighbourhood>(
                  label: 'Mahalle',
                  hintText: 'Seçiniz',
                  value: _selectedNeighbourhood,
                  items: _neighborhoods.map((n) => DropdownMenuItem(value: n, child: Text(n.name))).toList(),
                  onChanged: (value) => setState(() => _selectedNeighbourhood = value),
                  validator: (value) => value == null ? 'Mahalle seçiniz' : null,
                ),

                const SizedBox(height: 12),

                // Adres
                AppTextField(
                  controller: _addressController,
                  label: 'Adres (İsteğe Bağlı)',
                  hintText: 'Açık adres giriniz',
                  maxLines: 2,
                ),

                const SizedBox(height: 12),

                // Doğum Tarihi
                AppDatePicker(
                  label: 'Doğum Tarihi',
                  hintText: 'Doğum tarihi seçiniz',
                  value: _birthDate,
                  onChanged: (value) => setState(() => _birthDate = value),
                  validator: (value) => value == null ? 'Doğum tarihi seçiniz' : null,
                ),

                const SizedBox(height: 12),

                // Cinsiyet
                AppDropdown<String>(
                  label: 'Cinsiyet',
                  hintText: 'Seçiniz',
                  value: _selectedGender,
                  items: _genders
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(
                            g == 'female'
                                ? 'Kadın'
                                : g == 'male'
                                ? 'Erkek'
                                : 'Belirtmek İstemiyorum',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) => value == null ? 'Cinsiyet seçiniz' : null,
                ),

                const SizedBox(height: 24),
                Text('Şifre Değiştir (İsteğe Bağlı)', style: AppTextStyles.pageTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 12),

                // Mevcut Şifre
                AppTextField(
                  controller: _currentPasswordController,
                  label: 'Mevcut Şifre',
                  hintText: 'Mevcut şifrenizi giriniz',
                  isPassword: true,
                ),

                const SizedBox(height: 12),

                // Yeni Şifre
                AppTextField(
                  controller: _passwordController,
                  label: 'Yeni Şifre',
                  hintText: 'Yeni şifrenizi giriniz',
                  helperText: 'Şifre en az 8 karakter olmalıdır',
                  isPassword: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 8) {
                      return 'Şifre en az 8 karakter olmalı';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                AppButton(text: 'Kaydet', onTap: _isLoading ? null : _onSave, isLoading: _isLoading),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6 || i == 8) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    final newText = buffer.toString();

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
