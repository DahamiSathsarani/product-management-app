import 'package:flutter/material.dart';
import 'package:product_mobile_app/app/app_colors.dart';
import 'package:product_mobile_app/services/category_service.dart';
import 'package:product_mobile_app/widgets/filter_sheet.dart';
import 'package:product_mobile_app/widgets/toast_alert.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => service.fetchProducts(),
                  tooltip: 'Refresh products',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                        onChanged: (value) {
                          service.fetchProducts(search: value);
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () async {
                        final categoryService = context.read<CategoryService>();

                        if (categoryService.categories.isEmpty) {
                          await categoryService.fetchCategories();
                        }
                        
                        final result = await showModalBottomSheet<Map<String, dynamic>>(
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
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
            Expanded(
              child: service.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : service.products.isEmpty
                      ? const Center(
                          child: Text(
                            'No products available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: service.products.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final p = service.products[i];

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              shadowColor: Colors.grey.shade200,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                title: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${p.categoryName} • Rs.${p.price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      tooltip: 'Edit Product',
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
                                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                                      tooltip: 'Delete Product',
                                      onPressed: () => _confirmDelete(context, p.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: AppColors.lightYellowColor,
        elevation: 4,
      ),
    );
  }

  // ========================== Delete Dialog ==========================

  void _confirmDelete(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ProductService>().deleteProduct(productId);
                AppToast.success('Product deleted successfully');
              } catch (e) {
                AppToast.error(e.toString());
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}