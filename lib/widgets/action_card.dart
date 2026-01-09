import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/theme/app_colors.dart';

class ActionCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback? onTap;

  const ActionCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.description,
    required this.buttonText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl!,
                height: 201,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 201,
                  color: AppColors.inputBackground,
                  child: const Center(
                    child: Icon(Icons.image, size: 48, color: AppColors.hint),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 201,
              color: AppColors.inputBackground,
              child: const Center(
                child: Icon(Icons.image, size: 48, color: AppColors.hint),
              ),
            ),

          // İçerik
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 23 / 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Açıklama ve buton
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Açıklama
                    Expanded(
                      child: Text(
                        description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 24 / 16,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Mini buton
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(84, 32),
                        maximumSize: const Size(double.infinity, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: Text(buttonText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

