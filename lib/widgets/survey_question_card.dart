import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/survey_question_model.dart';
import 'package:kedv/widgets/yes_no_buttons.dart';

class SurveyQuestionCard extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyAnswer answer;
  final void Function(bool) onAnswerChanged;
  final void Function(String) onCommentChanged;

  const SurveyQuestionCard({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswerChanged,
    required this.onCommentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resim ve soru bilgisi
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resim
              if (question.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    question.imageUrl!,
                    height: 201,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 201,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: AppColors.hint),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Başlık
              Text(
                question.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 23 / 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              // Soru
              Text(
                question.question,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),

        // Evet / Hayır butonları
        YesNoButtons(
          value: answer.answer,
          onChanged: onAnswerChanged,
        ),

        // Yorum alanı
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 144),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8CFDB)),
            ),
            child: TextField(
              maxLines: 5,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                hintText: 'İsteğe bağlı yorumlar',
                hintStyle: AppTextStyles.inputHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(15),
              ),
              onChanged: onCommentChanged,
            ),
          ),
        ),
      ],
    );
  }
}

