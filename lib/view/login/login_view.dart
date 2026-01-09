import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Login işlemi
      context.go(AppRoutes.home);
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
                Text(
                  'Dirençli Mahalle',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),

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

                const SizedBox(height: 20),

                // Giriş butonu
                AppButton(text: 'Giriş', onTap: _onLogin),

                const SizedBox(height: 16),

                // Kayıt ol linki
                AppTextButton(
                  text: 'Hesabın yok mu? Hemen kayıt ol.',
                  onTap: () => context.push(AppRoutes.register),
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
