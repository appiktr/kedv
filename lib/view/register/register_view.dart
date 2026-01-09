import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
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

  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedNeighborhood;
  String? _selectedGender;
  DateTime? _birthDate;

  // Örnek veriler - Gerçek uygulamada API'den gelecek
  final List<String> _cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya'];
  final List<String> _districts = ['Kadıköy', 'Beşiktaş', 'Üsküdar', 'Şişli', 'Bakırköy'];
  final List<String> _neighborhoods = ['Moda', 'Fenerbahçe', 'Caferağa', 'Koşuyolu'];
  final List<String> _genders = ['Kadın', 'Erkek', 'Belirtmek İstemiyorum'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Register işlemi
      context.go(AppRoutes.home);
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
                AppDropdown<String>(
                  label: 'Şehir',
                  hintText: 'Seçiniz',
                  value: _selectedCity,
                  items: _cities
                      .map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      _selectedDistrict = null;
                      _selectedNeighborhood = null;
                    });
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
                AppDropdown<String>(
                  label: 'İlçe',
                  hintText: 'Seçiniz',
                  value: _selectedDistrict,
                  items: _districts
                      .map((district) => DropdownMenuItem(
                            value: district,
                            child: Text(district),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      _selectedNeighborhood = null;
                    });
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
                AppDropdown<String>(
                  label: 'Mahalle',
                  hintText: 'Seçiniz',
                  value: _selectedNeighborhood,
                  items: _neighborhoods
                      .map((neighborhood) => DropdownMenuItem(
                            value: neighborhood,
                            child: Text(neighborhood),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedNeighborhood = value;
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
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
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
                AppButton(text: 'Kayıt Ol', onTap: _onRegister),

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

