import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product.dart';

class ProductService extends ChangeNotifier {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  List<Product> products = [];
  bool isLoading = false;

  int currentPage = 1;
  int lastPage = 1;

  Future<void> fetchProducts({int page = 1}) async {
    if (page > lastPage) return;

    isLoading = true;
    notifyListeners();

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/product/get-all?page=$page&limit=20'),
      );

      final data = json.decode(res.body);

      currentPage = data['meta']['current_page'];
      lastPage = data['meta']['last_page'];

      final fetched = (data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();

      if (page == 1) {
        products = fetched;
      } else {
        products.addAll(fetched);
      }
    } catch (e) {
      products = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createProduct(
      String name, int categoryId, double price, bool isActive) async {
    await http.post(
      Uri.parse('$baseUrl/product/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'category_id': categoryId,
        'price': price,
        'is_active': isActive ? 1 : 0,
      }),
    );

    fetchProducts(page: 1);
  }

  Future<void> updateProduct(int id, String name, int categoryId,
      double price, bool isActive) async {
    await http.put(
      Uri.parse('$baseUrl/product/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'category_id': categoryId,
        'price': price,
        'is_active': isActive ? 1 : 0,
      }),
    );

    fetchProducts(page: 1);
  }

  Future<void> deleteProduct(int id) async {
    await http.patch(
      Uri.parse('$baseUrl/product/soft-delete/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'is_active': 0}),
    );

    fetchProducts(page: 1);
  }
}