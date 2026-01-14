import 'package:json_annotation/json_annotation.dart';

part 'report_issue_model.g.dart';

@JsonSerializable()
class ReportMenuResponse {
  final ReportMenuData data;

  ReportMenuResponse({required this.data});

  factory ReportMenuResponse.fromJson(Map<String, dynamic> json) => _$ReportMenuResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReportMenuResponseToJson(this);
}

@JsonSerializable()
class ReportMenuData {
  final String? menu;
  final String? title;

  // "gostergeler" is a List in the JSON example

  // "final_questions" is a List inside "gostergeler" array in the example?
  // Wait, let's look closely at the user request JSON.
  // "gostergeler": [ {key: "gosterge1"...}, ..., {title: "Detay Bilgiler", key: "final_questions", questions: [...] } ]
  // It seems "final_questions" is also an item in the "gostergeler" list but with different structure!
  // This is a polymorphic list.
  // Or, I can try to parse it specifically.

  // Actually, looking at the JSON, "gostergeler" contains objects.
  // Most objects are categories (key="gostergeX").
  // One object is key="final_questions".

  // I will parse "gostergeler" as a List of generic objects or try to handle it in a custom way.
  // A cleaner way often used in simple apps: Parse the whole list, filters out the one with key="final_questions" into a separate field in a custom fromJson, or just keep them all in a list and filter in UI.

  // Let's stick to standard generation but maybe add a helper to find questions.
  final List<ReportMenuItem>? gostergeler;

  ReportMenuData({this.menu, this.title, this.gostergeler});

  factory ReportMenuData.fromJson(Map<String, dynamic> json) => _$ReportMenuDataFromJson(json);
  Map<String, dynamic> toJson() => _$ReportMenuDataToJson(this);

  List<ReportFinalQuestion> get finalQuestions {
    final item = gostergeler?.firstWhere(
      (element) => element.key == 'final_questions',
      orElse: () => ReportMenuItem(key: 'none'),
    );
    return item?.questions ?? [];
  }

  List<ReportMenuItem> get categories {
    return gostergeler?.where((element) => element.key != 'final_questions').toList() ?? [];
  }
}

@JsonSerializable()
class ReportMenuItem {
  final String? key;
  final String? label;
  final String? title;

  // For Categories
  // children is a Map<String, ReportSubCategory>
  final Map<String, ReportSubCategory>? children;

  // For Final Questions
  final List<ReportFinalQuestion>? questions;

  ReportMenuItem({this.key, this.label, this.children, this.questions, this.title});

  factory ReportMenuItem.fromJson(Map<String, dynamic> json) => _$ReportMenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$ReportMenuItemToJson(this);

  // Helper to convert children Map to List for UI
  List<ReportSubCategory> get subCategoriesList {
    if (children == null) return [];
    return children!.entries.map((e) {
      // Inject key into the object if needed, or wrap it
      // Since ReportSubCategory is generated, we can't easily inject key unless we added a field.
      // We should probably add a key field to ReportSubCategory and populate it after parsing, OR
      // just treat the map entry as the source of truth in UI.
      e.value.key = e.key;
      return e.value;
    }).toList();
  }
}

@JsonSerializable()
class ReportSubCategory {
  // We add this key field which is NOT in JSON, but we populate it manually or via custom fromJson?
  // Easier: Just make it non-final and set it when accessing via parent.
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? key;

  final String? label;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  // For the validation/leaf nodes.
  // In JSON: "children": { "leaf_key": "Leaf Label string" }
  // Wait, looking at JSON:
  // "children": { "belirli_sokakta_biriken_cop": "Belirli sokakta biriken çöp" }
  // The children of subcategory is a Map<String, String>.
  final Map<String, String>? children;

  ReportSubCategory({this.label, this.imageUrl, this.children});

  factory ReportSubCategory.fromJson(Map<String, dynamic> json) => _$ReportSubCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ReportSubCategoryToJson(this);

  List<MapEntry<String, String>> get issuesList {
    return children?.entries.toList() ?? [];
  }
}

@JsonSerializable()
class ReportFinalQuestion {
  final String? key;
  final String? label;
  final String? helper;
  final String? type; // text, image
  final String? field;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? placeholder;
  final bool? multiple;

  ReportFinalQuestion({
    this.key,
    this.label,
    this.helper,
    this.type,
    this.field,
    this.imageUrl,
    this.placeholder,
    this.multiple,
  });

  factory ReportFinalQuestion.fromJson(Map<String, dynamic> json) => _$ReportFinalQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$ReportFinalQuestionToJson(this);
}
