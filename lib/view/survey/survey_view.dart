import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/survey_question_model.dart';
import 'package:kedv/widgets/app_button.dart';
import 'package:kedv/widgets/survey_question_card.dart';

class SurveyView extends StatefulWidget {
  const SurveyView({super.key});

  @override
  State<SurveyView> createState() => _SurveyViewState();
}

class _SurveyViewState extends State<SurveyView> {
  final List<SurveyQuestion> _questions = SurveyQuestion.mockQuestions;
  late List<SurveyAnswer> _answers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _answers = _questions
        .map((q) => SurveyAnswer(questionId: q.id))
        .toList();
  }

  void _onSubmit() async {
    // Tüm soruların cevaplanıp cevaplanmadığını kontrol et
    final unanswered = _answers.where((a) => a.answer == null).length;
    if (unanswered > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen tüm soruları cevaplayın ($unanswered soru kaldı)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: API'ye gönder
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Değerlendirmeniz başarıyla gönderildi!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text('Mahalleni Değerlendir', style: AppTextStyles.appBarTitle),
      ),
      body: Column(
        children: [
          // Açıklama
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              'Mahallenizin güvenliği ve tesisleriyle ilgili ${_questions.length} soruyu yanıtlayın.',
              style: AppTextStyles.body,
            ),
          ),

          // Sorular listesi
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                final answer = _answers[index];

                return SurveyQuestionCard(
                  question: question,
                  answer: answer,
                  onAnswerChanged: (value) {
                    setState(() {
                      _answers[index].answer = value;
                    });
                  },
                  onCommentChanged: (value) {
                    _answers[index].comment = value;
                  },
                );
              },
            ),
          ),

          // Gönder butonu
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                text: 'Gönder',
                isLoading: _isLoading,
                onTap: _onSubmit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

