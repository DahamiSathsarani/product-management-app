import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:product_mobile_app/app/app_colors.dart';
import 'package:product_mobile_app/services/product_service.dart';
import 'package:product_mobile_app/services/category_service.dart';
import 'package:product_mobile_app/widgets/filter_sheet.dart';
import 'package:product_mobile_app/widgets/toast_alert.dart';
import 'add_product_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String searchTerm = '';
  int? selectedCategoryId;
  double? minPrice;
  double? maxPrice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductService>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ProductService>();

    /// Group products by category
    final groupedProducts = <String, List<dynamic>>{};
    for (var product in service.products) {
      groupedProducts.putIfAbsent(product.categoryName, () => []);
      groupedProducts[product.categoryName]!.add(product);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// ------------------ APP BAR ------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Products',
          style: TextStyle(
            color: AppColors.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.blackColor,
            onPressed: () => service.fetchProducts(),
          ),
        ],
      ),

      /// ------------------ BODY ------------------
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchAndFilter(context),
            const SizedBox(height: 16),

            Expanded(
              child: service.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : groupedProducts.isEmpty
                      ? const Center(
                          child: Text(
                            'No products available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView(
                          children: groupedProducts.entries.map((entry) {
                            return _buildCategorySection(
                              category: entry.key,
                              products: entry.value,
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),

      /// ------------------ FAB ------------------
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Product',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
      ),
    );
  }

  /// ================= SEARCH + FILTER =================
  Widget _buildSearchAndFilter(BuildContext context) {
    final service = context.read<ProductService>();

    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              searchTerm = value;
              service.fetchProducts(search: value);
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list),
            color: AppColors.blackColor,
            onPressed: () async {
              final categoryService = context.read<CategoryService>();

              if (categoryService.categories.isEmpty) {
                await categoryService.fetchCategories();
              }

              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (_) => FilterSheet(
                  categories: categoryService.categories,
                  selectedCategoryId: selectedCategoryId,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                ),
              );

              if (result != null) {
                selectedCategoryId = result['categoryId'];
                minPrice = result['minPrice'];
                maxPrice = result['maxPrice'];

                service.fetchProducts(
                  search: searchTerm,
                  categoryId: selectedCategoryId,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  /// ================= CATEGORY SECTION =================
  Widget _buildCategorySection({
    required String category,
    required List<dynamic> products,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final p = products[index];
              return _buildProductCard(p);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// ================= PRODUCT CARD =================
  Widget _buildProductCard(dynamic p) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.inventory_2_outlined, size: 30),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              p.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Rs. ${p.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProductScreen(product: p),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDelete(context, p.id),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// ================= DELETE =================
  void _confirmDelete(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ProductService>().deleteProduct(productId);
              AppToast.success('Product deleted');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}