import 'package:flutter/material.dart';
import 'package:product_mobile_app/app/app_colors.dart';
import 'package:product_mobile_app/widgets/toast_alert.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryService>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<CategoryService>();

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
                  'Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => service.fetchCategories(),
                  tooltip: 'Refresh categories',
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: service.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : service.categories.isEmpty
                      ? const Center(
                          child: Text(
                            'No categories available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: service.categories.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final c = service.categories[i];

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              shadowColor: Colors.grey.shade200,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                title: Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Align(
                                    alignment: Alignment.centerLeft, 
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: c.isActive == 1 ? Colors.green.shade100 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 60, 
                                        maxWidth: 100,
                                      ),
                                      child: Center(
                                        child: Text(
                                          c.isActive == 1 ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            color: c.isActive == 1 ? Colors.green.shade800 : Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13, 
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      tooltip: 'Edit Category',
                                      onPressed: () => _openForm(context, category: c),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                                      tooltip: 'Delete Category',
                                      onPressed: () => _confirmDelete(context, c.id),
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
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        backgroundColor: AppColors.lightYellowColor,
        elevation: 4,
      ),
    );
  }

  // ========================== Dialogs ==========================

  void _openForm(BuildContext context, {dynamic category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    bool isActive = category?.isActive == 1;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              category == null ? 'Add Category' : 'Edit Category',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: isSubmitting ? null : (v) => setState(() => isActive = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greyColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: isSubmitting
                    ? null
                    : () => _submitCategory(
                          context: context,
                          category: category,
                          nameCtrl: nameCtrl,
                          isActive: isActive,
                          setSubmitting: (value) => setState(() => isSubmitting = value),
                        ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int categoryId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this category?'),
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
                await context.read<CategoryService>().deleteCategory(categoryId);
                AppToast.success('Category deleted successfully');
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

  Future<void> _submitCategory({
    required BuildContext context,
    required dynamic category,
    required TextEditingController nameCtrl,
    required bool isActive,
    required Function(bool) setSubmitting,
  }) async {
    setSubmitting(true);

    try {
      final service = context.read<CategoryService>();

      if (category == null) {
        await service.createCategory(nameCtrl.text, isActive);
        AppToast.success('Category added successfully');
      } else {
        await service.updateCategory(category.id, nameCtrl.text, isActive);
        AppToast.success('Category updated successfully');
      }

      Navigator.pop(context);
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      setSubmitting(false);
    }
  }
}