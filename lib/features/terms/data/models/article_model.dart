class ArticleModel {
  final int id;
  final int articleNumber;
  final String title;
  final String body;

  const ArticleModel({
    required this.id,
    required this.articleNumber,
    required this.title,
    required this.body,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      articleNumber: json['article_number'] is int
          ? json['article_number']
          : int.tryParse(json['article_number']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_number': articleNumber,
      'title': title,
      'body': body,
    };
  }
}
