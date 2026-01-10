class Category {
  final int id;
  final String name;
  final int isActive;

  Category({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'],
    );
  }
}