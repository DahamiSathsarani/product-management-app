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
      price: double.parse(json['price']),
      categoryId: json['category_id'],
      isActive: json['is_active'],
      categoryName: json['category']['name'],
      image: json['image'],
    );
  }
}