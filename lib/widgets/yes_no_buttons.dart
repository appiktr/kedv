import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/theme/app_colors.dart';

class YesNoButtons extends StatelessWidget {
  final bool? value; // true = Evet, false = Hayır, null = seçilmedi
  final void Function(bool) onChanged;

  const YesNoButtons({
    super.key,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              text: 'HAYIR',
              isSelected: value == false,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildButton(
              text: 'EVET',
              isSelected: value == true,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : AppColors.inputBackground,
          foregroundColor: isSelected ? AppColors.background : AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(text),
      ),
    );
  }
}

