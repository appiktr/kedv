import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.inputBackground, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 16),
          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Ana Sayfa',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.description_outlined,
                selectedIcon: Icons.description,
                label: 'Raporlarım',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.textPrimary : AppColors.secondary;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(27),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32,
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 18 / 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

