import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/service/auth_service.dart';
import 'package:kedv/widgets/app_button.dart';

import 'package:kedv/widgets/app_text_button.dart';
import 'package:kedv/widgets/app_text_field.dart';
import 'package:flutter/services.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPhoneLogin = true;
  final _formKey = GlobalKey<FormState>();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _isRememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final credentials = await _authService.getCredentials();
    if (credentials != null && mounted) {
      final savedLogin = credentials['email']!;
      final isEmail = savedLogin.contains('@');

      setState(() {
        if (isEmail) {
          _emailController.text = savedLogin;
          _isPhoneLogin = false;
        } else {
          _phoneController.text = savedLogin;
          _isPhoneLogin = true;
        }
        _passwordController.text = credentials['password']!;
        _isRememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // Login request
        final loginInput = _isPhoneLogin ? _phoneController.text.replaceAll(' ', '') : _emailController.text;

        await _authService.login(loginInput, _passwordController.text);

        // Handle Remember Me
        if (_isRememberMe) {
          final savedEmail = _isPhoneLogin ? _phoneController.text : _emailController.text;
          await _authService.saveCredentials(savedEmail, _passwordController.text);
        } else {
          await _authService.clearCredentials();
        }

        if (mounted) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo
                Image.asset('assets/logo.png', width: 206, height: 210),

                // Başlık
                Text('Dirençli Mahalle', style: AppTextStyles.heading, textAlign: TextAlign.center),

                const SizedBox(height: 4),

                // Alt başlık
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Kadınlar birlikte daha güçlüdür.',
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // Tablar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPhoneLogin = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isPhoneLogin ? AppColors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _isPhoneLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: .05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              'Telefon',
                              textAlign: TextAlign.center,
                              style: _isPhoneLogin
                                  ? AppTextStyles.label.copyWith(color: AppColors.primary)
                                  : AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPhoneLogin = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isPhoneLogin ? AppColors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: !_isPhoneLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: .05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              'E-posta',
                              textAlign: TextAlign.center,
                              style: !_isPhoneLogin
                                  ? AppTextStyles.label.copyWith(color: AppColors.primary)
                                  : AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Input Alanı
                if (_isPhoneLogin)
                  AppTextField(
                    controller: _phoneController,
                    hintText: 'Telefon Numarası giriniz',
                    keyboardType: TextInputType.phone,
                    prefixText: '+90 ',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, _PhoneInputFormatter()],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Telefon numarası gerekli';
                      }
                      return null;
                    },
                  )
                else
                  AppTextField(
                    controller: _emailController,
                    hintText: 'E-posta',
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

                // Şifre input
                AppTextField(
                  controller: _passwordController,
                  hintText: 'Şifre',
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

                // Beni Hatırla Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isRememberMe,
                      onChanged: (value) {
                        setState(() {
                          _isRememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Beni Hatırla'),
                  ],
                ),

                const SizedBox(height: 20),

                // Giriş butonu
                AppButton(text: 'Giriş', onTap: _isLoading ? null : _onLogin, isLoading: _isLoading),

                const SizedBox(height: 16),

                // Kayıt ol linki
                AppTextButton(text: 'Hesabın yok mu? Hemen kayıt ol.', onTap: () => context.push(AppRoutes.register)),

                const SizedBox(height: 20),
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
