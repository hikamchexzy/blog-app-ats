class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  // Factory untuk konversi dari JSON (response API)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }

  // Konversi ke JSON (untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}