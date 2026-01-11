import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:product_mobile_app/app/exceptions/api_exception.dart';
import '../models/category.dart';

class CategoryService extends ChangeNotifier {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  List<Category> categories = [];
  bool isLoading = false;

  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/product-category/get-all'),
        headers: {'Content-Type': 'application/json'},
      );

      _handleResponse(res);

      final data = json.decode(res.body);
      categories = (data['categories'] as List)
          .map((e) => Category.fromJson(e))
          .toList();
    } catch (e) {
      categories = [];
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory(String name, bool isActive) async {
    final res = await http.post(
      Uri.parse('$baseUrl/product-category/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'is_active': isActive ? 1 : 0,
      }),
    );

    _handleResponse(res);
    await fetchCategories();
  }

  Future<void> updateCategory(int id, String name, bool isActive) async {
    final res = await http.put(
      Uri.parse('$baseUrl/product-category/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'is_active': isActive ? 1 : 0,
      }),
    );

    _handleResponse(res);
    await fetchCategories();
  }

  Future<void> deleteCategory(int id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/product-category/soft-delete/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    _handleResponse(res);
    await fetchCategories();
  }

  void _handleResponse(http.Response res) {
    final data = json.decode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    }

    if (data['message'] != null) {
      throw ApiException(data['message']);
    }

    throw ApiException('Unexpected error occurred');
  }
}