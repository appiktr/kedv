import 'package:flutter/material.dart';

import 'package:kedv/core/const.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/evaluation_model.dart';
import 'package:kedv/widgets/app_text_field.dart';

class SurveyQuestionCard extends StatefulWidget {
  final EvaluationQuestion question;
  final Function(dynamic)? onAnswerChanged;

  const SurveyQuestionCard({super.key, required this.question, this.onAnswerChanged});

  @override
  State<SurveyQuestionCard> createState() => _SurveyQuestionCardState();
}

class _SurveyQuestionCardState extends State<SurveyQuestionCard> {
  // Local state for 'Other' text input
  final TextEditingController _otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.question.otherAnswer != null) {
      _otherController.text = widget.question.otherAnswer!;
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  String _getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return '$baseImageUrl$path';
    return '$baseImageUrl/$path';
  }

  void _handleSingleSelect(String? value) {
    if (value == null) return;
    setState(() {
      widget.question.answer = value;
      // If switching away from 'other', maybe clear otherAnswer? optional.
    });
    widget.onAnswerChanged?.call(value);
  }

  void _handleMultiSelect(String optionValue, bool isSelected) {
    // Safely cast or convert current answer to List<String>
    List<String> currentAnswers = [];
    if (widget.question.answer != null) {
      if (widget.question.answer is List) {
        currentAnswers = (widget.question.answer as List).map((e) => e.toString()).toList();
      }
    }

    final newAnswers = List<String>.from(currentAnswers);

    if (isSelected) {
      if (!newAnswers.contains(optionValue)) {
        // Check max select
        if (widget.question.maxSelect != null && newAnswers.length >= widget.question.maxSelect!) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('En fazla ${widget.question.maxSelect} seçim yapabilirsiniz.')));
          return;
        }
        newAnswers.add(optionValue);
      }
    } else {
      newAnswers.remove(optionValue);
    }

    setState(() {
      widget.question.answer = newAnswers;
    });
    widget.onAnswerChanged?.call(newAnswers);
  }

  void _handleTextChange(String value) {
    setState(() {
      widget.question.answer = value;
    });
    widget.onAnswerChanged?.call(value);
  }

  void _handleOtherTextChange(String value) {
    setState(() {
      widget.question.otherAnswer = value;
    });
    // Optionally notify parent if needed, but saving to model is usually enough
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Image
        if (widget.question.imageUrl != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _getImageUrl(widget.question.imageUrl!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

        // Subtitle (if available, e.g. "Giriş Soruları" OR "helper")
        if (widget.question.displaySubtitle != null && widget.question.displaySubtitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.question.displaySubtitle!,
              style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
            ),
          ),

        // Question Text (question OR label)
        if (widget.question.displayQuestion != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(widget.question.displayQuestion!, style: AppTextStyles.heading.copyWith(fontSize: 18)),
          ),

        // Input Area
        _buildInputArea(),

        // Other Text Field
        if (_shouldShowOtherInput())
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AppTextField(
              controller: _otherController,
              hintText: 'Belirtiniz...',
              onChanged: _handleOtherTextChange,
            ),
          ),
      ],
    );
  }

  bool _shouldShowOtherInput() {
    if (widget.question.hasOther != true) return false;

    if (widget.question.type == 'single_select') {
      return widget.question.answer == 'other';
    } else if (widget.question.type == 'multi_select') {
      if (widget.question.answer is List) {
        return (widget.question.answer as List).contains('other');
      }
    }
    return false;
  }

  Widget _buildInputArea() {
    switch (widget.question.type) {
      case 'single_select':
        return _buildSingleSelect();
      case 'multi_select':
        return _buildMultiSelect();
      case 'text':
        return _buildTextInput();
      default:
        return const Text('Desteklenmeyen soru tipi');
    }
  }

  Widget _buildSingleSelect() {
    final options = widget.question.options ?? [];
    return Column(
      children: options.map((option) {
        // ignore: deprecated_member_use
        return RadioListTile<String>(
          title: Text(option.label, style: AppTextStyles.body),
          secondary: option.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _getImageUrl(option.imageUrl!),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                )
              : null,
          value: option.value,
          // ignore: deprecated_member_use
          groupValue: widget.question.answer as String?,
          // ignore: deprecated_member_use
          onChanged: _handleSingleSelect,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelect() {
    final options = widget.question.options ?? [];
    // Safely retrieve current answers
    List<String> currentAnswers = [];
    if (widget.question.answer != null && widget.question.answer is List) {
      currentAnswers = (widget.question.answer as List).map((e) => e.toString()).toList();
    }

    return Column(
      children: options.map((option) {
        final isSelected = currentAnswers.contains(option.value);
        return CheckboxListTile(
          title: Text(option.label, style: AppTextStyles.body),
          secondary: option.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _getImageUrl(option.imageUrl!),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                )
              : null,
          value: isSelected,
          onChanged: (val) => _handleMultiSelect(option.value, val ?? false),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }

  Widget _buildTextInput() {
    return AppTextField(
      hintText: widget.question.placeholder ?? 'Cevabınızı buraya yazın...',
      onChanged: _handleTextChange,
      maxLines: 3,
    );
  }
}
