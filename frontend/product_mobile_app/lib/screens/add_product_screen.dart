import 'package:flutter/material.dart';
import 'package:product_mobile_app/app/app_colors.dart';
import 'package:product_mobile_app/widgets/toast_alert.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int? _selectedCategoryId;
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _selectedCategoryId = widget.product!.categoryId;
      _priceCtrl.text = widget.product!.price.toStringAsFixed(2);
      _isActive = widget.product!.isActive == 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryService = context.watch<CategoryService>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: AppColors.yellowColor,
      ),
      body: categoryService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceCtrl,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      items: categoryService.categories
                          .where((c) => c.isActive == 1)
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (v) => setState(() => _selectedCategoryId = v),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      validator: (v) => v == null ? 'Select category' : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: _isSubmitting
                          ? null
                          : (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greyColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitProduct(context),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.product == null
                                  ? 'Add Product'
                                  : 'Update Product',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submitProduct(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final productService = context.read<ProductService>();

    try {
      if (widget.product == null) {
        await productService.createProduct(
          _nameCtrl.text,
          _selectedCategoryId!,
          double.tryParse(_priceCtrl.text) ?? 0,
          _isActive,
        );
        AppToast.success('Product added successfully');
      } else {
        await productService.updateProduct(
          widget.product!.id,
          _nameCtrl.text,
          _selectedCategoryId!,
          double.tryParse(_priceCtrl.text) ?? 0,
          _isActive,
        );
        AppToast.success('Product updated successfully');
      }
      Navigator.pop(context);
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
