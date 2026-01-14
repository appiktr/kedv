import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/evaluation_model.dart';
import 'package:kedv/service/evaluation_service.dart';
import 'package:kedv/widgets/app_button.dart';
import 'package:kedv/widgets/survey_question_card.dart';
import 'package:kedv/service/profile_service.dart';

enum SurveyType {
  evaluation, // Menu 1: Evaluate My Neighborhood
  planning, // Menu 3: Plan My Neighborhood
}

class SurveyView extends StatefulWidget {
  final SurveyType type;

  const SurveyView({super.key, required this.type});

  @override
  State<SurveyView> createState() => _SurveyViewState();
}

class _SurveyStep {
  final String? sectionTitle;
  final EvaluationQuestion question;

  _SurveyStep({this.sectionTitle, required this.question});
}

class _SurveyViewState extends State<SurveyView> {
  final _evaluationService = EvaluationService();

  bool _isLoading = true;
  String? _error;
  EvaluationResponse? _response;

  // Flattened steps
  List<_SurveyStep> _steps = [];

  // Navigation State
  int _currentStepIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      EvaluationResponse? response;
      if (widget.type == SurveyType.evaluation) {
        response = await _evaluationService.getQuestions();
      } else {
        response = await _evaluationService.getMenu3Questions();
      }

      // Flatten data
      final List<_SurveyStep> steps = [];
      if (response != null) {
        if (response.data.questions != null && response.data.questions!.isNotEmpty) {
          // Direct questions (Menu 3)
          for (final question in response.data.questions!) {
            // For Menu 3, title might come from response.data.title or be static
            steps.add(_SurveyStep(sectionTitle: response.data.title ?? 'Mahallemi Planlıyorum', question: question));
          }
        } else if (response.data.sections != null && response.data.sections!.isNotEmpty) {
          // Sections (Menu 1)
          for (final section in response.data.sections!) {
            for (final question in section.normalizedQuestions) {
              steps.add(_SurveyStep(sectionTitle: section.title, question: question));
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _response = response;
          _steps = steps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  bool get _isCurrentQuestionValid {
    if (_steps.isEmpty) return false;
    final question = _steps[_currentStepIndex].question;

    if (question.answer == null) return false;
    if (question.answer is String && (question.answer as String).isEmpty) return false;
    if (question.answer is List && (question.answer as List).isEmpty) return false;

    return true;
  }

  void _nextStep() {
    if (!_isCurrentQuestionValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen soruyu cevaplayınız.')));
      return;
    }

    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _pageController.animateToPage(
        _currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If manual completion is required, do nothing or just focus button.
      // User clicks "Tamamla" which calls _onSubmit.
    }
  }

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
      _pageController.animateToPage(
        _currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Auto-advance for single select
  void _onAnswerChanged(dynamic value) {
    setState(() {
      // Button state updates
    });

    final currentQ = _steps[_currentStepIndex].question;
    // Don't auto-advance if "other" is selected, because user needs to type text
    bool isOther = value == 'other';

    if (currentQ.type == 'single_select' && !isOther) {
      // Small delay to let user see selection
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _isCurrentQuestionValid && _currentStepIndex < _steps.length - 1) {
          _nextStep();
        }
        // We do NOT auto-submit on the last step anymore.
        // User must manually press "Tamamla".
        else if (mounted && _currentStepIndex == _steps.length - 1) {
          setState(() {}); // Ensure button is enabled
        }
      });
    }
  }

  bool get _shouldEnableNextButton {
    if (!_isCurrentQuestionValid) return false;

    final currentQ = _steps[_currentStepIndex].question;

    // For single select, we disable the button unless it's "other" OR it's the last step
    if (currentQ.type == 'single_select') {
      if (currentQ.answer == 'other') return true;
      if (_currentStepIndex == _steps.length - 1) return true; // Enable on last step
      return false;
    }

    return true;
  }

  void _onSubmit() async {
    if (!_isCurrentQuestionValid) return; // double check

    setState(() => _isLoading = true);

    try {
      // 1. Get Profile ID
      int? profileId;
      try {
        final profileService = ProfileService();
        final profile = await profileService.getProfile();
        if (profile == null) throw Exception('Profil bulunamadı');
        profileId = profile.id;
      } catch (e) {
        throw Exception('Kullanıcı bilgisi alınamadı. Lütfen tekrar giriş yapın.');
      }

      // 2. Build Payload
      final Map<String, dynamic> payload = {};
      payload['profile_id'] = profileId;

      // Menu 1 requires date, Menu 3 user request didn't explicitly show it but it's good practice
      // or maybe not needed. The example payload for Menu 3:
      // { "profile_id": 2, "select_field": "Evet", ... } -> no date shown.
      // But we can include it, extra fields usually ignored.
      if (widget.type == SurveyType.evaluation) {
        final now = DateTime.now();
        final day = now.day.toString().padLeft(2, '0');
        final month = now.month.toString().padLeft(2, '0');
        final year = now.year.toString();
        payload['date'] = '$day-$month-$year';
      }

      // 3. Collect Answers from _steps
      for (final step in _steps) {
        final question = step.question;
        // Main field
        if (question.field != null && question.answer != null) {
          payload[question.field!] = question.answer;
        }

        // Other field
        if (question.hasOther == true && question.otherField != null && question.otherAnswer != null) {
          bool includeOther = false;
          if (question.type == 'single_select' && question.answer == 'other') {
            includeOther = true;
          } else if (question.type == 'multi_select' &&
              question.answer is List &&
              (question.answer as List).contains('other')) {
            includeOther = true;
          }

          if (includeOther) {
            payload[question.otherField!] = question.otherAnswer;
          }
        }
      }

      if (widget.type == SurveyType.evaluation) {
        await _evaluationService.submitEvaluation(payload);
      } else {
        await _evaluationService.submitNeighbourhoodEvaluation(payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Değerlendirmeniz başarıyla gönderildi!'), backgroundColor: AppColors.success),
        );
        context.pop();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _response == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bir hata oluştu: $_error'),
              ElevatedButton(onPressed: _fetchQuestions, child: const Text('Tekrar Dene')),
            ],
          ),
        ),
      );
    }

    if (_steps.isEmpty) {
      return const Scaffold(body: Center(child: Text('Soru bulunamadı.')));
    }

    final currentStep = _steps[_currentStepIndex];
    final isLastStep = _currentStepIndex == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStepIndex > 0) {
              _prevStep();
            } else {
              context.pop();
            }
          },
        ),
        centerTitle: true,
        title: Text('Soru ${_currentStepIndex + 1}/${_steps.length}', style: AppTextStyles.appBarTitle),
      ),
      body: Column(
        children: [
          // Section Title Banner
          if (currentStep.sectionTitle != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              width: double.infinity,
              color: Colors.white,
              child: Text(
                currentStep.sectionTitle!,
                style: AppTextStyles.heading.copyWith(fontSize: 18, color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
            ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: SurveyQuestionCard(question: step.question, onAnswerChanged: _onAnswerChanged),
                  ),
                );
              },
            ),
          ),

          // Navigation Buttons
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStepIndex > 0)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppButton(text: 'Geri', isOutlined: true, onTap: _prevStep),
                      ),
                    ),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: isLastStep ? 'Tamamla' : 'İleri',
                      onTap: _shouldEnableNextButton ? (isLastStep ? _onSubmit : _nextStep) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
