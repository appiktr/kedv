import 'package:json_annotation/json_annotation.dart';

part 'evaluation_model.g.dart';

@JsonSerializable()
class EvaluationResponse {
  final EvaluationData data;

  EvaluationResponse({required this.data});

  factory EvaluationResponse.fromJson(Map<String, dynamic> json) => _$EvaluationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EvaluationResponseToJson(this);
}

@JsonSerializable()
class EvaluationData {
  final List<EvaluationSection>? sections;
  // Menu 3 support: direct questions list, no sections
  final List<EvaluationQuestion>? questions;
  final String? menu;
  final String? title;

  EvaluationData({this.sections, this.questions, this.menu, this.title});

  factory EvaluationData.fromJson(Map<String, dynamic> json) => _$EvaluationDataFromJson(json);
  Map<String, dynamic> toJson() => _$EvaluationDataToJson(this);
}

@JsonSerializable()
class EvaluationSection {
  final String? title;
  final String? code;
  final String? menu;

  // These fields exist if the section is actually a single question
  final String? question;
  final String? type;
  @JsonKey(name: 'max_select')
  final int? maxSelect;
  final String? field;
  @JsonKey(name: 'has_other')
  final bool? hasOther;
  @JsonKey(name: 'other_field')
  final String? otherField;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<EvaluationOption>? options;

  // This exists if the section is a container for questions
  final List<EvaluationQuestion>? questions;

  EvaluationSection({
    this.title,
    this.code,
    this.menu,
    this.question,
    this.type,
    this.maxSelect,
    this.field,
    this.hasOther,
    this.otherField,
    this.imageUrl,
    this.options,
    this.questions,
  });

  factory EvaluationSection.fromJson(Map<String, dynamic> json) => _$EvaluationSectionFromJson(json);
  Map<String, dynamic> toJson() => _$EvaluationSectionToJson(this);

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<EvaluationQuestion>? _cachedQuestions;

  // Helper to normalize content: returns a list of questions regardless of structure
  List<EvaluationQuestion> get normalizedQuestions {
    if (_cachedQuestions != null) {
      return _cachedQuestions!;
    }

    if (questions != null && questions!.isNotEmpty) {
      _cachedQuestions = questions!;
      return _cachedQuestions!;
    }

    // If "questions" is null/empty but "question" exists, treat this section as a single question
    if (question != null) {
      _cachedQuestions = [
        EvaluationQuestion(
          code: code,
          subTitle: title, // Use section title as subtitle for single Q?
          question: question,
          type: type,
          maxSelect: maxSelect,
          field: field,
          hasOther: hasOther,
          otherField: otherField,
          options: options,
          imageUrl: imageUrl,
        ),
      ];
      return _cachedQuestions!;
    }

    _cachedQuestions = [];
    return _cachedQuestions!;
  }
}

@JsonSerializable()
class EvaluationQuestion {
  final String? code;
  final String? key; // menu3 alias for code
  @JsonKey(name: 'sub_title')
  final String? subTitle;
  final String? helper; // menu3 alias for subTitle
  final String? question;
  final String? label; // menu3 alias for question
  final String? type; // single_select, multi_select, text
  @JsonKey(name: 'max_select')
  final int? maxSelect;
  final String? field;
  @JsonKey(name: 'has_other')
  final bool? hasOther;
  @JsonKey(name: 'other_field')
  final String? otherField;
  final String? placeholder;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<EvaluationOption>? options;

  // Local state for answer
  @JsonKey(includeFromJson: false, includeToJson: false)
  dynamic answer;

  // Local state for 'other' text input
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? otherAnswer;

  EvaluationQuestion({
    this.code,
    this.key,
    this.subTitle,
    this.helper,
    this.question,
    this.label,
    this.type,
    this.maxSelect,
    this.field,
    this.hasOther,
    this.otherField,
    this.placeholder,
    this.imageUrl,
    this.options,
  });

  // Getters to unify legacy and new fields
  String? get displayQuestion => question ?? label;
  String? get displaySubtitle => subTitle ?? helper;
  String? get displayCode => code ?? key;

  factory EvaluationQuestion.fromJson(Map<String, dynamic> json) => _$EvaluationQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$EvaluationQuestionToJson(this);
}

@JsonSerializable()
class EvaluationOption {
  final String value;
  final String label;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  EvaluationOption({required this.value, required this.label, this.imageUrl});

  factory EvaluationOption.fromJson(Map<String, dynamic> json) => _$EvaluationOptionFromJson(json);
  Map<String, dynamic> toJson() => _$EvaluationOptionToJson(this);
}
