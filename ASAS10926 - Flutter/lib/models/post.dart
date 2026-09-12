class Post {
  final int id;
  final String title;
  final String content;
  final int? categoryId;
  final String? categoryName;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.categoryId,
    this.categoryName,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'categoryId': categoryId,
    };
  }

  bool get isDeleted => status == 'delete';
}