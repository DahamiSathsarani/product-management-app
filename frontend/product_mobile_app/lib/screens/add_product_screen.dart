import 'package:flutter/material.dart';
import 'package:product_mobile_app/app/app_colors.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int? _selectedCategoryId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    context.read<CategoryService>().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final categoryService = context.watch<CategoryService>();
    final productService = context.read<ProductService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: AppColors.yellowColor
      ),
      body: categoryService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Product Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      items: categoryService.categories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (v) => v == null ? 'Select category' : null,
                    ),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await productService.createProduct(
                            _nameCtrl.text,
                            _selectedCategoryId!,
                            double.tryParse(_priceCtrl.text) ?? 0,
                            _isActive,
                          );
                          Navigator.pop(context); 
                        }
                      },
                      child: const Text('Save Product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}