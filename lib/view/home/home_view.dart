import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/widgets/action_card.dart';

import 'package:kedv/service/profile_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ProfileService _profileService = ProfileService();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.getProfile();
    if (profile != null) {
      if (mounted) {
        // "Ad Soyad" -> "Ad" ayrıştırma
        String fullName = profile.user.name;
        String firstName = fullName.split(' ')[0];

        setState(() {
          _userName = firstName;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text('Dirençli Mahalle', style: AppTextStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hoşgeldin mesajı
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(_userName != null ? 'Hoşgeldin, $_userName!' : 'Hoşgeldin!', style: AppTextStyles.heading),
            ),

            // Mahalleni Değerlendir kartı
            Padding(
              padding: const EdgeInsets.all(16),
              child: ActionCard(
                imageLocation: 'assets/mahallenidegerlendir.jpeg',
                title: 'Mahalleni Değerlendir',
                description: 'Mahallendeki güvenlik ve olanaklar hakkında 10 soruyu cevapla.',
                buttonText: 'Başla',
                onTap: () => context.push(AppRoutes.survey),
              ),
            ),

            // Mahallemi Planlıyorum kartı (Menu 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ActionCard(
                imageLocation: 'assets/mahallemiplanliyorum.jpeg', // Example image
                title: 'Mahallemi Planlıyorum',
                description: 'Mahallenin daha dirençli ve yaşanabilir olması için fikrini belirt.',
                buttonText: 'Katıl',
                onTap: () => context.push(AppRoutes.planning),
              ),
            ),

            // Bir Sorun Bildir kartı
            Padding(
              padding: const EdgeInsets.all(16),
              child: ActionCard(
                imageLocation: 'assets/birsorunbildir.jpeg',
                title: 'Bir Sorun Bildir',
                description: 'Harita üzerinde bir konum seç ve varsa sorunları bildir.',
                buttonText: 'Bildir',
                onTap: () => context.push(AppRoutes.reportIssue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
