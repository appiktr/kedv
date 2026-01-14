// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_issue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportMenuResponse _$ReportMenuResponseFromJson(Map<String, dynamic> json) =>
    ReportMenuResponse(
      data: ReportMenuData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReportMenuResponseToJson(ReportMenuResponse instance) =>
    <String, dynamic>{'data': instance.data};

ReportMenuData _$ReportMenuDataFromJson(Map<String, dynamic> json) =>
    ReportMenuData(
      menu: json['menu'] as String?,
      title: json['title'] as String?,
      gostergeler: (json['gostergeler'] as List<dynamic>?)
          ?.map((e) => ReportMenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReportMenuDataToJson(ReportMenuData instance) =>
    <String, dynamic>{
      'menu': instance.menu,
      'title': instance.title,
      'gostergeler': instance.gostergeler,
    };

ReportMenuItem _$ReportMenuItemFromJson(Map<String, dynamic> json) =>
    ReportMenuItem(
      key: json['key'] as String?,
      label: json['label'] as String?,
      children: (json['children'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ReportSubCategory.fromJson(e as Map<String, dynamic>)),
      ),
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => ReportFinalQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String?,
    );

Map<String, dynamic> _$ReportMenuItemToJson(ReportMenuItem instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'title': instance.title,
      'children': instance.children,
      'questions': instance.questions,
    };

ReportSubCategory _$ReportSubCategoryFromJson(Map<String, dynamic> json) =>
    ReportSubCategory(
      label: json['label'] as String?,
      imageUrl: json['image_url'] as String?,
      children: (json['children'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ReportSubCategoryToJson(ReportSubCategory instance) =>
    <String, dynamic>{
      'label': instance.label,
      'image_url': instance.imageUrl,
      'children': instance.children,
    };

ReportFinalQuestion _$ReportFinalQuestionFromJson(Map<String, dynamic> json) =>
    ReportFinalQuestion(
      key: json['key'] as String?,
      label: json['label'] as String?,
      helper: json['helper'] as String?,
      type: json['type'] as String?,
      field: json['field'] as String?,
      imageUrl: json['image_url'] as String?,
      placeholder: json['placeholder'] as String?,
      multiple: json['multiple'] as bool?,
    );

Map<String, dynamic> _$ReportFinalQuestionToJson(
  ReportFinalQuestion instance,
) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'helper': instance.helper,
  'type': instance.type,
  'field': instance.field,
  'image_url': instance.imageUrl,
  'placeholder': instance.placeholder,
  'multiple': instance.multiple,
};
