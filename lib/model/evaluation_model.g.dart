// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EvaluationResponse _$EvaluationResponseFromJson(Map<String, dynamic> json) =>
    EvaluationResponse(
      data: EvaluationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EvaluationResponseToJson(EvaluationResponse instance) =>
    <String, dynamic>{'data': instance.data};

EvaluationData _$EvaluationDataFromJson(Map<String, dynamic> json) =>
    EvaluationData(
      sections: (json['sections'] as List<dynamic>?)
          ?.map((e) => EvaluationSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => EvaluationQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      menu: json['menu'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$EvaluationDataToJson(EvaluationData instance) =>
    <String, dynamic>{
      'sections': instance.sections,
      'questions': instance.questions,
      'menu': instance.menu,
      'title': instance.title,
    };

EvaluationSection _$EvaluationSectionFromJson(Map<String, dynamic> json) =>
    EvaluationSection(
      title: json['title'] as String?,
      code: json['code'] as String?,
      menu: json['menu'] as String?,
      question: json['question'] as String?,
      type: json['type'] as String?,
      maxSelect: (json['max_select'] as num?)?.toInt(),
      field: json['field'] as String?,
      hasOther: json['has_other'] as bool?,
      otherField: json['other_field'] as String?,
      imageUrl: json['image_url'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => EvaluationOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => EvaluationQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EvaluationSectionToJson(EvaluationSection instance) =>
    <String, dynamic>{
      'title': instance.title,
      'code': instance.code,
      'menu': instance.menu,
      'question': instance.question,
      'type': instance.type,
      'max_select': instance.maxSelect,
      'field': instance.field,
      'has_other': instance.hasOther,
      'other_field': instance.otherField,
      'image_url': instance.imageUrl,
      'options': instance.options,
      'questions': instance.questions,
    };

EvaluationQuestion _$EvaluationQuestionFromJson(Map<String, dynamic> json) =>
    EvaluationQuestion(
      code: json['code'] as String?,
      key: json['key'] as String?,
      subTitle: json['sub_title'] as String?,
      helper: json['helper'] as String?,
      question: json['question'] as String?,
      label: json['label'] as String?,
      type: json['type'] as String?,
      maxSelect: (json['max_select'] as num?)?.toInt(),
      field: json['field'] as String?,
      hasOther: json['has_other'] as bool?,
      otherField: json['other_field'] as String?,
      placeholder: json['placeholder'] as String?,
      imageUrl: json['image_url'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => EvaluationOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EvaluationQuestionToJson(EvaluationQuestion instance) =>
    <String, dynamic>{
      'code': instance.code,
      'key': instance.key,
      'sub_title': instance.subTitle,
      'helper': instance.helper,
      'question': instance.question,
      'label': instance.label,
      'type': instance.type,
      'max_select': instance.maxSelect,
      'field': instance.field,
      'has_other': instance.hasOther,
      'other_field': instance.otherField,
      'placeholder': instance.placeholder,
      'image_url': instance.imageUrl,
      'options': instance.options,
    };

EvaluationOption _$EvaluationOptionFromJson(Map<String, dynamic> json) =>
    EvaluationOption(
      value: json['value'] as String,
      label: json['label'] as String,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$EvaluationOptionToJson(EvaluationOption instance) =>
    <String, dynamic>{
      'value': instance.value,
      'label': instance.label,
      'image_url': instance.imageUrl,
    };
