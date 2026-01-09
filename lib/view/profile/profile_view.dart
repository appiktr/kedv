import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/widgets/app_button.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  // Mock kullanıcı verileri
  String get _userName => 'Elif Kaya';
  String get _userEmail => 'elif.kaya@email.com';
  String get _userPhone => '+90 555 555 55 55';
  String get _userCity => 'İstanbul';
  String get _userDistrict => 'Kadıköy';
  String get _userNeighborhood => 'Örnek Mh.';
  String get _userBirthDate => '1990-01-01';
  String get _userGender => 'Kadın';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profilim',
          style: AppTextStyles.appBarTitle.copyWith(color: const Color(0xFF171214)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil header
                  _buildProfileHeader(context),

                  // Kişisel Bilgiler başlık
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Kişisel Bilgiler',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF171214),
                      ),
                    ),
                  ),

                  // Bilgiler grid
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Telefon | Şehir/Bölge
                        _buildInfoRow(
                          leftLabel: 'Telefon',
                          leftValue: _userPhone,
                          rightLabel: 'Şehir/Bölge',
                          rightValue: _userCity,
                        ),
                        // İlçe | Mahalle
                        _buildInfoRow(
                          leftLabel: 'İlçe',
                          leftValue: _userDistrict,
                          rightLabel: 'Mahalle',
                          rightValue: _userNeighborhood,
                        ),
                        // Doğum tarihi | Cinsiyet
                        _buildInfoRow(
                          leftLabel: 'Doğum tarihi',
                          leftValue: _userBirthDate,
                          rightLabel: 'Cinsiyet',
                          rightValue: _userGender,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Oturumu kapat butonu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: AppButton(
              text: 'Oturumu kapat',
              onTap: () {
                // TODO: Çıkış işlemi
                context.go(AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 64,
            backgroundColor: AppColors.inputBackground,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/128?img=5'),
            child: null,
          ),
          const SizedBox(height: 16),

          // İsim
          Text(
            _userName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF171214),
            ),
            textAlign: TextAlign.center,
          ),

          // E-posta
          Text(
            _userEmail,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A6175),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Düzenle butonu
          AppButton(
            text: 'Düzenle',
            onTap: () {
              // TODO: Profil düzenleme sayfasına git
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E8EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol sütun
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A6175),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  leftValue,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF171214),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Sağ sütun
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A6175),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rightValue,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF171214),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
