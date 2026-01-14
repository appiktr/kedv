import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/service/auth_service.dart';
import 'package:kedv/widgets/app_button.dart';
import 'package:kedv/widgets/app_text_button.dart';
import 'package:kedv/widgets/app_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      setState(() {
        _emailController.text = credentials['email']!;
        _passwordController.text = credentials['password']!;
        _isRememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // Login request
        await _authService.login(_emailController.text, _passwordController.text);

        // Handle Remember Me
        if (_isRememberMe) {
          await _authService.saveCredentials(_emailController.text, _passwordController.text);
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

                // E-posta input
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
