class SurveyQuestion {
  final int id;
  final String title;
  final String question;
  final String? imageUrl;

  SurveyQuestion({
    required this.id,
    required this.title,
    required this.question,
    this.imageUrl,
  });

  // Mock data
  static List<SurveyQuestion> mockQuestions = [
    SurveyQuestion(
      id: 1,
      title: 'Emniyet',
      question: 'Geceleri yalnız yürürken kendinizi güvende hissediyor musunuz?',
      imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800',
    ),
    SurveyQuestion(
      id: 2,
      title: 'Aydınlatma',
      question: 'İyi aydınlatılmış sokaklar ve kamusal alanlar var mı?',
      imageUrl: 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=800',
    ),
  ];
}

class SurveyAnswer {
  final int questionId;
  bool? answer; // true = Evet, false = Hayır, null = cevaplanmadı
  String? comment;

  SurveyAnswer({
    required this.questionId,
    this.answer,
    this.comment,
  });
}

