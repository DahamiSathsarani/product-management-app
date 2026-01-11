import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:product_mobile_app/app/exceptions/api_exception.dart';
import '../models/product.dart';

class ProductService extends ChangeNotifier {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  List<Product> products = [];
  bool isLoading = false;

  int currentPage = 1;
  int lastPage = 1;

  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/product/get-all'), 
        headers: {'Content-Type': 'application/json'},
      );

      _handleResponse(res);

      final data = json.decode(res.body);
      products = (data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
    } catch (e) {
      products = [];
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct(String name, int categoryId, double price, bool isActive) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/product/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'category_id': categoryId,
          'price': price,
          'is_active': isActive ? 1 : 0,
        }),
      );

      _handleResponse(res);
      await fetchProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(int id, String name, int categoryId, double price, bool isActive) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/product/update/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'category_id': categoryId,
          'price': price,
          'is_active': isActive ? 1 : 0,
        }),
      );

      _handleResponse(res);
      await fetchProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/product/soft-delete/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'is_active': 0}),
      );

      _handleResponse(res);
      await fetchProducts();
    } catch (e) {
      rethrow;
    }
  }

  void _handleResponse(http.Response res) {
    final data = json.decode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) return;

    if (data['message'] != null) {
      throw ApiException(data['message']);
    }

    throw ApiException('Unexpected error occurred');
  }
}