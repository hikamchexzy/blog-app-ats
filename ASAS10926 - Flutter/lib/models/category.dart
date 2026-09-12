class Category {
  final int id;
  final String name;
  final String status;

  Category({
    required this.id,
    required this.name,
    this.status = 'active',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}