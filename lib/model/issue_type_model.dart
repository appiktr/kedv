class IssueType {
  final int id;
  final String name;
  final String? imageUrl;

  IssueType({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  // Mock data
  static List<IssueType> mockIssueTypes = [
    IssueType(
      id: 1,
      name: 'Yol Hasarı',
      imageUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=400',
    ),
    IssueType(
      id: 2,
      name: 'Aydınlatma Sorunu',
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    ),
    IssueType(
      id: 3,
      name: 'Trafik Tehlikesi',
      imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400',
    ),
  ];
}

