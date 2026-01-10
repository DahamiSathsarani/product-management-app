import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/category.dart';

class CategoryService extends ChangeNotifier {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  List<Category> categories = [];
  bool isLoading = false;

  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();

    final String url = '${baseUrl}/product-category/get-all';
    debugPrint('Fetching categories from: $url');

    try {
      debugPrint('BASE URL: $baseUrl');

      final res = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Body: ${res.body}');
      
      final data = json.decode(res.body);
      categories = (data['categories'] as List)
          .map((e) => Category.fromJson(e))
          .toList();
    } catch (e) {
      categories = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createCategory(String name, bool isActive) async {
    await http.post(
      Uri.parse('$baseUrl/product-category/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'is_active': isActive ? 1 : 0,
      }),
    );

    fetchCategories();
  }

  Future<void> updateCategory(int id, String name, bool isActive) async {
    await http.put(
      Uri.parse('$baseUrl/product-category/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'is_active': isActive ? 1 : 0,
      }),
    );

    fetchCategories();
  }

  Future<void> deleteCategory(int id) async {
    await http.patch(
      Uri.parse('$baseUrl/product-category/soft-delete/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'is_active': 0}),
    );

    fetchCategories();
  }
}