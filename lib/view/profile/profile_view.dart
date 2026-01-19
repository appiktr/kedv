import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/profile_model.dart';
import 'package:kedv/service/auth_service.dart';
import 'package:kedv/service/profile_service.dart';
import 'package:kedv/widgets/app_button.dart';
import 'package:kedv/view/profile/edit_profile_view.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  Future<ProfileModel?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getProfile();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Profilim', style: AppTextStyles.appBarTitle.copyWith(color: const Color(0xFF171214))),
      ),
      body: FutureBuilder<ProfileModel?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bir hata oluştu: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Tekrar Dene',
                    onTap: () {
                      setState(() {
                        _profileFuture = _profileService.getProfile();
                      });
                    },
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Profil bilgisi bulunamadı.'));
          }

          final profile = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profil header
                      _buildProfileHeader(context, profile),

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
                              leftValue: profile.user.phone ?? '-',
                              rightLabel: 'Şehir/Bölge',
                              rightValue: profile.city.name,
                            ),
                            // İlçe | Mahalle
                            _buildInfoRow(
                              leftLabel: 'İlçe',
                              leftValue: profile.district.name,
                              rightLabel: 'Mahalle',
                              rightValue: profile.neighbourhood.name,
                            ),
                            // Doğum tarihi | Cinsiyet
                            _buildInfoRow(
                              leftLabel: 'Doğum tarihi',
                              leftValue: DateFormat(
                                'dd MMMM yyyy',
                                'tr',
                              ).format(DateTime.parse(profile.birthdate)), // 12 Ocak 1998
                              rightLabel: 'Cinsiyet',
                              rightValue: profile.genderLabel,
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
                child: AppButton(text: 'Oturumu kapat', onTap: _logout),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar

          // İsim
          Text(
            profile.user.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF171214),
            ),
            textAlign: TextAlign.center,
          ),

          // E-posta
          Text(
            profile.user.email,
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
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileView(profile: profile)),
              );

              if (result == true) {
                if (context.mounted) {
                  setState(() {
                    _profileFuture = _profileService.getProfile();
                  });
                }
              }
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
        border: Border(top: BorderSide(color: Color(0xFFE5E8EB), width: 1)),
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
