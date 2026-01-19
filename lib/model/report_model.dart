class ReportModel {
  final int id;
  final String title;
  final String type;
  final String status;
  final DateTime completedDate;
  final List<ReportQuestion> questions;
  final List<ReportComment> comments;
  final Map<String, dynamic>? categoryInfo;
  final double? latitude;
  final double? longitude;

  ReportModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.completedDate,
    required this.questions,
    required this.comments,
    this.categoryInfo,
    this.latitude,
    this.longitude,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    List<ReportQuestion> parsedQuestions = [];
    if (json['sections'] != null) {
      var sections = json['sections'] as List;
      int qNum = 1;
      for (var section in sections) {
        if (section['questions'] != null && section['questions'] is List) {
          // Nested questions
          var subQuestions = section['questions'] as List;
          for (var sq in subQuestions) {
            parsedQuestions.add(ReportQuestion.fromSectionJson(sq, qNum++));
          }
        } else {
          // Direct question (like G0.1)
          // Only add if it looks like a question (has question text or answer)
          if (section['question'] != null) {
            parsedQuestions.add(ReportQuestion.fromSectionJson(section, qNum++));
          }
        }
      }
    }

    return ReportModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: 'Mahalleni Değerlendir Raporu',
      type: 'Değerlendirme',
      status: 'Tamamlandı',
      completedDate: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      questions: parsedQuestions,
      comments: [],
      latitude: json['location'] != null ? double.tryParse(json['location'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  factory ReportModel.fromPriveNotificationJson(Map<String, dynamic> json) {
    List<ReportQuestion> parsedQuestions = [];
    if (json['questions'] != null) {
      var questions = json['questions'] as List;
      for (int i = 0; i < questions.length; i++) {
        parsedQuestions.add(ReportQuestion.fromPriveQuestionJson(questions[i], i + 1));
      }
    }

    String title = 'Bir Sorun Bildir';
    String type = 'Sorun Bildirimi';
    Map<String, dynamic>? categoryInfo;

    if (json['category_info'] != null) {
      // Use subCategory_label as title if available, otherwise sub_subCategory_label
      var catInfo = json['category_info'];
      type = catInfo['category_label'] ?? 'Sorun Bildirimi';
      categoryInfo = catInfo;
    }

    return ReportModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: title,
      type: type,
      status: 'İletildi', // Default status for these notifications
      completedDate: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      questions: parsedQuestions,
      comments: [],
      categoryInfo: categoryInfo,
      latitude: json['location'] != null ? double.tryParse(json['location'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  factory ReportModel.fromNeighbourhoodEvaluationJson(Map<String, dynamic> json) {
    List<ReportQuestion> parsedQuestions = [];
    if (json['questions'] != null) {
      var questions = json['questions'] as List;
      for (int i = 0; i < questions.length; i++) {
        parsedQuestions.add(ReportQuestion.fromNeighbourhoodQuestionJson(questions[i], i + 1));
      }
    }

    return ReportModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: 'Mahallemi Planlıyorum',
      type: 'Mahalle Planlama',
      status: 'Tamamlandı',
      completedDate: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      questions: parsedQuestions,
      comments: [],
      latitude: json['location'] != null ? double.tryParse(json['location'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  String get formattedDate {
    return '${completedDate.year}-${completedDate.month.toString().padLeft(2, '0')}-${completedDate.day.toString().padLeft(2, '0')}';
  }

  String get formattedDateLong {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${completedDate.day} ${months[completedDate.month - 1]} ${completedDate.year}';
  }

  // ... existing code ...

  // Mock data
  static List<ReportModel> mockReports = [
    ReportModel(
      id: 1,
      title: 'Sokak Güvenliği Değerlendirmesi',
      type: 'Güvenlik Denetimi',
      status: 'Tamamlanmış',
      completedDate: DateTime(2024, 1, 15),
      questions: [
        ReportQuestion(
          number: 1,
          question: 'Geceleri mahallemde yalnız yürürken kendimi güvende hissediyorum.',
          answer: 'HAYIR',
        ),
        ReportQuestion(number: 2, question: 'Birkaç sokak lambası var ama daha fazlasına ihtiyaç var.', answer: 'EVET'),
        ReportQuestion(number: 3, question: 'Bölgemde mahalle nöbeti tabelaları gördüm.', answer: 'EVET'),
      ],
      comments: [
        ReportComment(
          authorName: 'Sophia Bennett',
          authorImage: 'https://i.pravatar.cc/40?img=1',
          date: DateTime(2024, 1, 16),
          content: 'Bu değerlendirmeyi tamamladığınız için teşekkür ederiz. Geri bildiriminiz değerlidir.',
        ),
      ],
    ),
  ];
}

class ReportQuestion {
  final int number;
  final String question;
  final String answer;
  final String? comment;
  final String type;
  final String? key; // API field key e.g. question_1
  final List<dynamic>? options; // Options for select types
  final dynamic rawAnswer; // Raw answer value for editing
  final int? maxSelect;

  ReportQuestion({
    required this.number,
    required this.question,
    required this.answer,
    this.comment,
    this.type = 'text',
    this.key,
    this.options,
    this.rawAnswer,
    this.maxSelect,
  });

  factory ReportQuestion.fromSectionJson(Map<String, dynamic> json, int number) {
    String answerText = '';
    var rawAnswer = json['answer'];
    var options = json['options'] as List?;
    String? field = json['field'];

    if (rawAnswer != null) {
      if (rawAnswer is List) {
        List<String> labels = [];
        for (var val in rawAnswer) {
          String? label;
          // Try to look up from options first
          if (options != null) {
            var opt = options.firstWhere((element) => element['value'] == val, orElse: () => {'label': null});
            label = opt['label'];
          }

          // If not found in options, check Enums based on field
          if (label == null) {
            if (field == 'question_1') {
              label = Question1Option.getLabel(val.toString());
            } else if (field == 'question_2') {
              label = Question2Option.getLabel(val.toString());
            }
          }

          labels.add(label ?? val.toString());
        }
        answerText = labels.join(', ');
      } else {
        String? label;
        if (options != null) {
          var opt = options.firstWhere((element) => element['value'] == rawAnswer, orElse: () => {'label': null});
          label = opt['label'];
        }

        if (label == null) {
          if (field == 'question_1') {
            label = Question1Option.getLabel(rawAnswer.toString());
          } else if (field == 'question_2') {
            label = Question2Option.getLabel(rawAnswer.toString());
          } else if (field == 'question_3') {
            // Basic Yes/No/Partial usually
            if (rawAnswer == 'Evet') label = 'Evet';
            if (rawAnswer == 'Hayır') label = 'Hayır';
            if (rawAnswer == 'Kısmen') label = 'Kısmen';
          }
        }

        answerText = label ?? rawAnswer.toString();
      }
    }

    return ReportQuestion(
      number: number,
      question: json['question'] ?? '',
      answer: answerText,
      comment: json['answer_other'] ?? json['question_2_other'] ?? json['question_1_other'],
      type: 'text', // Keeping as text for display, but we might want original type for editing later?
      // Actually let's use the UI friendly type or original type?
      // User wants update capability.
      // Let's store the original type if available or infer.
      // json['type'] is 'single_select', 'multi_select', etc.
      // But previous code overwrote it to 'text'.
      // Let's keep distinct types for editing logic if possible.
      // But DetailView currently renders based on this.
      // Let's assume text for read-only view, and maybe use another field for input type?
      // Or just override type?
      // Let's stick to text for display compatibility for now, but store 'key' and 'options'.
      key: field,
      options: options,
      rawAnswer: rawAnswer,
      maxSelect: json['max_select'], // Parse max_select
    );
  }

  factory ReportQuestion.fromPriveQuestionJson(Map<String, dynamic> json, int number) {
    String type = json['type'] ?? 'text';
    String answerText = '';
    var rawAnswer = json['answer'];

    if (rawAnswer != null) {
      if (type == 'image' && rawAnswer is Map && rawAnswer.containsKey('url')) {
        answerText = rawAnswer['url'];
      } else {
        answerText = rawAnswer.toString();
      }
    } else {
      answerText = '-';
    }

    // Prive Notifications typically don't fail standard field mapping like other endpoints
    // But they might not be editable in the same way?
    // Let's add key anyway if available (probably 'label' or inferred?)
    // JSON instructions didn't show 'field' key for prive questions clearly in user prompt?
    // Actually user prompt example showed notifications.
    // Let's just be safe.

    return ReportQuestion(
      number: number,
      question: json['label'] ?? '',
      answer: answerText,
      type: type,
      key: json['field'] ?? json['label'], // Fallback
      rawAnswer: rawAnswer,
      maxSelect: json['max_select'], // Parse max_select if available
    );
  }

  factory ReportQuestion.fromNeighbourhoodQuestionJson(Map<String, dynamic> json, int number) {
    // String type = json['type'] ?? 'text';

    String answerText = '';
    var rawAnswer = json['answer'];
    var options = json['options'] as List?;
    String? field = json['field']; // Assuming field exists or we use label

    if (rawAnswer != null) {
      if (rawAnswer is List) {
        List<String> labels = [];
        for (var val in rawAnswer) {
          String? label;
          if (options != null) {
            var opt = options.firstWhere((element) => element['value'] == val, orElse: () => {'label': null});
            label = opt['label'];
          }
          labels.add(label ?? val.toString());
        }
        answerText = labels.join(', ');
      } else {
        String? label;
        if (options != null) {
          var opt = options.firstWhere((element) => element['value'] == rawAnswer, orElse: () => {'label': null});
          label = opt['label'];
        }
        answerText = label ?? rawAnswer.toString();
      }
    } else {
      answerText = '-';
    }

    // Treat single/multi select as text for display
    String displayType = 'text';

    return ReportQuestion(
      number: number,
      question: json['label'] ?? '',
      answer: answerText,
      type: displayType,
      key: field ?? json['field'],
      options: options,
      rawAnswer: rawAnswer,
      maxSelect: json['max_select'], // Parse max_select
    );
  }
}

enum Question1Option {
  goodNeighborRelations('good_neighbor_relations', 'Komşuluk ilişkileri iyi'),
  feelSafe('feel_safe', 'Güvenli hissediyorum'),
  childSafeSchoolRoute('child_safe_school_route', 'Çocuğum okula güvenle gidip geliyor'),
  cleanEnvironment('clean_environment', 'Temizlik ve çevre düzeni iyi'),
  easyHealthAccess('easy_health_access', 'Sağlık hizmetlerine erişim kolay'),
  transportSufficient('transport_sufficient', 'Ulaşım seçenekleri yeterli'),
  socialGreenAreas('social_green_areas', 'Sosyal/yeşil alanlar var'),
  parksChildrenAreas('parks_children_areas', 'Park/çocuk alanları var'),
  shoppingSufficient('shopping_sufficient', 'Alışveriş olanakları yeterli'),
  goodLocation('good_location', 'Mahallenin konumu iyi'),
  womenGatheringSpaces('women_gathering_spaces', 'Kadınların bir araya gelebildiği alanlar var'),
  easyMunicipalityContact('easy_municipality_contact', 'Belediyeyle iletişim kolay'),
  other('other', 'Diğer');

  final String key;
  final String label;
  const Question1Option(this.key, this.label);

  static String? getLabel(String key) {
    try {
      return values.firstWhere((e) => e.key == key).label;
    } catch (_) {
      return null;
    }
  }
}

enum Question2Option {
  safeStreets('safe_streets', 'Güvenli sokaklar'),
  lighting('lighting', 'Aydınlatma'),
  parkGreenArea('park_green_area', 'Park / yeşil alan'),
  safePlayAreas('safe_play_areas', 'Çocuklar için güvenli oyun alanı'),
  disabledAccess('disabled_access', 'Engelli erişimi'),
  womenSocialSpaces('women_social_spaces', 'Kadın sosyal alanları'),
  healthServices('health_services', 'Sağlık hizmetleri'),
  schoolEducationSupport('school_education_support', 'Okul / eğitim desteği'),
  publicTransport('public_transport', 'Toplu ulaşım'),
  libraryStudyArea('library_study_area', 'Kütüphane / etüt alanı'),
  cleaningGarbage('cleaning_garbage', 'Temizlik / çöp'),
  floodDrainageIssues('flood_drainage_issues', 'Su baskını / mazgal sorunları'),
  abandonedBuildingsImprove('abandoned_buildings_improve', 'Metruk binaların iyileştirilmesi'),
  economicOpportunities('economic_opportunities', 'Ekonomik fırsatlar'),
  assemblyAreaAwareness('assembly_area_awareness', 'Toplanma alanı bilinirliği'),
  sportsArea('sports_area', 'Spor alanı'),
  elderlySocialServices('elderly_social_services', 'Yaşlılar için sosyal hizmetler'),
  other('other', 'Diğer');

  final String key;
  final String label;
  const Question2Option(this.key, this.label);

  static String? getLabel(String key) {
    try {
      return values.firstWhere((e) => e.key == key).label;
    } catch (_) {
      return null;
    }
  }
}

class ReportComment {
  final String authorName;
  final String? authorImage;
  final DateTime date;
  final String content;

  ReportComment({required this.authorName, this.authorImage, required this.date, required this.content});

  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
