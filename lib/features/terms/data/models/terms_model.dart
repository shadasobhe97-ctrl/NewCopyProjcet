import 'article_model.dart';

class TermsModel {
  final int id;
  final String versionNumber;
  final String title;
  final String audience;
  final String status;
  final String publishedAt;
  final List<ArticleModel> articles;

  const TermsModel({
    required this.id,
    required this.versionNumber,
    required this.title,
    required this.audience,
    required this.status,
    required this.publishedAt,
    required this.articles,
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    var rawArticles = json['articles'];
    List<ArticleModel> parsedArticles = [];
    if (rawArticles is List) {
      parsedArticles = rawArticles
          .map((item) => ArticleModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return TermsModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      versionNumber: json['version_number']?.toString() ?? '1.0',
      title: json['title']?.toString() ?? 'الشروط والأحكام والسياسات',
      audience: json['audience']?.toString() ?? '',
      status: json['status']?.toString() ?? 'published',
      publishedAt: json['published_at']?.toString() ?? '',
      articles: parsedArticles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version_number': versionNumber,
      'title': title,
      'audience': audience,
      'status': status,
      'published_at': publishedAt,
      'articles': articles.map((a) => a.toJson()).toList(),
    };
  }
}
