import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/location_model.dart';
import 'package:kedv/model/register_request_model.dart';
import 'package:kedv/service/auth_service.dart';
import 'package:kedv/service/location_service.dart';
import 'package:kedv/widgets/app_button.dart';
import 'package:kedv/widgets/app_date_picker.dart';
import 'package:kedv/widgets/app_dropdown.dart';
import 'package:kedv/widgets/app_text_button.dart';
import 'package:kedv/widgets/app_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Services
  final _locationService = LocationService();
  final _authService = AuthService();

  // Location Data
  List<City> _cities = [];
  List<District> _districts = [];
  List<Neighbourhood> _neighborhoods = [];

  // Selections
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
    _fetchCities();
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
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen doğum tarihi seçiniz')));
        return;
      }

      setState(() => _isLoading = true);

      try {
        final request = RegisterRequestModel(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          passwordConfirmation:
              _passwordController.text, // Assuming same password for confirmation as there is no separate field
          gender: _selectedGender!,
          birthdate:
              "${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}",
          cityId: _selectedCity!.id,
          districtId: _selectedDistrict!.id,
          neighbourhoodId: _selectedNeighbourhood!.id,
        );

        await _authService.register(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt başarılı!')));
          context.go(AppRoutes.home);
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
        title: Text('Dirençli Mahalle', style: AppTextStyles.appBarTitle),
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

                // Sayfa başlığı
                Text('Hesap Oluştur', style: AppTextStyles.pageTitle),

                const SizedBox(height: 12),

                // Ad Soyad
                AppTextField(
                  controller: _nameController,
                  label: 'Ad Soyad',
                  hintText: 'Ad Soyad giriniz',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ad Soyad gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // E-posta
                AppTextField(
                  controller: _emailController,
                  label: 'E-posta',
                  hintText: 'E-posta giriniz',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta gerekli';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir e-posta girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Telefon
                AppTextField(
                  controller: _phoneController,
                  label: 'Telefon',
                  hintText: 'Telefon Numarası giriniz',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telefon numarası gerekli';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null) {
                      return 'Şehir seçiniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // İlçe
                AppDropdown<District>(
                  label: 'İlçe',
                  hintText: 'Seçiniz',
                  value: _selectedDistrict,
                  items: _districts
                      .map((district) => DropdownMenuItem(value: district, child: Text(district.name)))
                      .toList(),
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
                  validator: (value) {
                    if (value == null) {
                      return 'İlçe seçiniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Mahalle
                AppDropdown<Neighbourhood>(
                  label: 'Mahalle',
                  hintText: 'Seçiniz',
                  value: _selectedNeighbourhood,
                  items: _neighborhoods
                      .map((neighborhood) => DropdownMenuItem(value: neighborhood, child: Text(neighborhood.name)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedNeighbourhood = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Mahalle seçiniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Şifre
                AppTextField(
                  controller: _passwordController,
                  label: 'Şifre',
                  hintText: 'Şifre giriniz',
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre gerekli';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Doğum Tarihi
                AppDatePicker(
                  label: 'Doğum Tarihi',
                  hintText: 'Doğum tarihi seçiniz',
                  value: _birthDate,
                  onChanged: (value) {
                    setState(() {
                      _birthDate = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Doğum tarihi seçiniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Cinsiyet
                AppDropdown<String>(
                  label: 'Cinsiyet',
                  hintText: 'Seçiniz',
                  value: _selectedGender,
                  items: _genders
                      .map(
                        (gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(
                            gender == 'female'
                                ? 'Kadın'
                                : gender == 'male'
                                ? 'Erkek'
                                : 'Belirtmek İstemiyorum',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Cinsiyet seçiniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Kayıt Ol butonu
                AppButton(text: 'Kayıt Ol', onTap: _isLoading ? null : _onRegister, isLoading: _isLoading),

                const SizedBox(height: 16),

                // Giriş yap linki
                Center(
                  child: AppTextButton(
                    text: 'Zaten bir hesabın var mı? Giriş yap.',
                    onTap: () => context.go(AppRoutes.login),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
