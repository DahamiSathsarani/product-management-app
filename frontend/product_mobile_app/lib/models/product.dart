class Product {
  final int id;
  final String name;
  final double price;
  final int categoryId;
  final int isActive;
  final String categoryName;
  final String? image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.isActive,
    required this.categoryName,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'] is String 
        ? double.parse(json['price']) 
        : (json['price'] as num).toDouble(),
      categoryId: json['category_id'],
      isActive: json['is_active'],
      categoryName: json['category'] is Map
        ? json['category']['name']
        : json['category_name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category_id': categoryId,
      'is_active': isActive,
      'category_name': categoryName,
      'image': image,
    };
  }
}