import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryService>().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<CategoryService>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: service.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: service.categories.length,
              itemBuilder: (_, i) {
                final c = service.categories[i];
                return ListTile(
                  title: Text(c.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => service.deleteCategory(c.id),
                  ),
                );
              },
            ),
    );
  }

  void _openForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    bool isActive = true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            SwitchListTile(
              title: const Text('Active'),
              value: isActive,
              onChanged: (v) => isActive = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<CategoryService>().createCategory(nameCtrl.text, isActive);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}