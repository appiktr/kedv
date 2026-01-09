class ReportModel {
  final int id;
  final String title;
  final String type;
  final String status;
  final DateTime completedDate;
  final List<ReportQuestion> questions;
  final List<ReportComment> comments;

  ReportModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.completedDate,
    required this.questions,
    required this.comments,
  });

  String get formattedDate {
    return '${completedDate.year}-${completedDate.month.toString().padLeft(2, '0')}-${completedDate.day.toString().padLeft(2, '0')}';
  }

  String get formattedDateLong {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${completedDate.day} ${months[completedDate.month - 1]} ${completedDate.year}';
  }

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
        ReportQuestion(
          number: 2,
          question: 'Birkaç sokak lambası var ama daha fazlasına ihtiyaç var.',
          answer: 'EVET',
        ),
        ReportQuestion(
          number: 3,
          question: 'Bölgemde mahalle nöbeti tabelaları gördüm.',
          answer: 'EVET',
        ),
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
    ReportModel(
      id: 2,
      title: 'Mahalle Temizlik Raporu',
      type: 'Çevre Denetimi',
      status: 'Tamamlanmış',
      completedDate: DateTime(2023, 12, 20),
      questions: [
        ReportQuestion(
          number: 1,
          question: 'Sokaklar düzenli olarak temizleniyor mu?',
          answer: 'EVET',
        ),
        ReportQuestion(
          number: 2,
          question: 'Çöp kutuları yeterli mi?',
          answer: 'HAYIR',
        ),
      ],
      comments: [],
    ),
    ReportModel(
      id: 3,
      title: 'Topluluk Katılımı Anketi',
      type: 'Sosyal Denetim',
      status: 'Tamamlanmış',
      completedDate: DateTime(2023, 11, 5),
      questions: [
        ReportQuestion(
          number: 1,
          question: 'Mahalle toplantılarına katılıyor musunuz?',
          answer: 'HAYIR',
        ),
      ],
      comments: [],
    ),
  ];
}

class ReportQuestion {
  final int number;
  final String question;
  final String answer;
  final String? comment;

  ReportQuestion({
    required this.number,
    required this.question,
    required this.answer,
    this.comment,
  });
}

class ReportComment {
  final String authorName;
  final String? authorImage;
  final DateTime date;
  final String content;

  ReportComment({
    required this.authorName,
    this.authorImage,
    required this.date,
    required this.content,
  });

  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

