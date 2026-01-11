import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:product_mobile_app/app/exceptions/api_exception.dart';
import '../models/product.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ProductService extends ChangeNotifier {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  List<Product> products = [];
  bool isLoading = false;

  Future<void> fetchProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      debugPrint('Fetching products with filters - Search: $search, Category ID: $categoryId, Min Price: $minPrice, Max Price: $maxPrice');
      final queryParameters = <String, String>{};

      if (search != null && search.isNotEmpty) queryParameters['search'] = search;
      if (categoryId != null) queryParameters['category_id'] = categoryId.toString();
      if (minPrice != null) queryParameters['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParameters['max_price'] = maxPrice.toString();

      final uri = Uri.parse('$baseUrl/product/get-all').replace(queryParameters: queryParameters);

      final res = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${res.statusCode}, Body: ${res.body}');

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

  Future<void> createProduct(
    String name,
    int categoryId,
    double price,
    bool isActive,
    File? image,
  ) async {
    var uri = Uri.parse('$baseUrl/product/create');

    http.Response response;

    if (image == null) {
      response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'category_id': categoryId,
          'price': price,
          'is_active': isActive ? 1 : 0,
        }),
      );
    } else {
      var request = http.MultipartRequest('POST', uri);
      request.fields['name'] = name;
      request.fields['category_id'] = categoryId.toString();
      request.fields['price'] = price.toString();
      request.fields['is_active'] = isActive ? '1' : '0';

      var mimeType = lookupMimeType(image.path)?.split('/') ?? ['image', 'jpeg'];
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ),
      );

      var streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    }

    _handleResponse(response);
    await fetchProducts();
  }

  Future<void> updateProduct(
    int id,
    String name,
    int categoryId,
    double price,
    bool isActive,
    File? image, 
  ) async {
    var uri = Uri.parse('$baseUrl/product/update/$id');

    http.Response response;

    if (image == null) {
      response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'category_id': categoryId,
          'price': price,
          'is_active': isActive ? 1 : 0,
        }),
      );
    } else {
      var request = http.MultipartRequest('POST', uri); 
      request.fields['name'] = name;
      request.fields['category_id'] = categoryId.toString();
      request.fields['price'] = price.toString();
      request.fields['is_active'] = isActive ? '1' : '0';
      request.fields['_method'] = 'PUT'; 

      var mimeType = lookupMimeType(image.path)?.split('/') ?? ['image', 'jpeg'];
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ),
      );

      var streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    }

    _handleResponse(response);
    await fetchProducts();
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