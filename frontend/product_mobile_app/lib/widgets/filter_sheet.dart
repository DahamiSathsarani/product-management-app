import 'package:flutter/material.dart';
import 'package:product_mobile_app/models/category.dart';

class FilterSheet extends StatefulWidget {
  final List<Category> categories; 
  final int? selectedCategoryId;
  final double? minPrice;
  final double? maxPrice;

  const FilterSheet({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.minPrice,
    this.maxPrice,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  int? selectedCategoryId;
  double? minPrice;
  double? maxPrice;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.selectedCategoryId;
    minPrice = widget.minPrice;
    maxPrice = widget.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Filter Products",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(height: 24, thickness: 1),
            Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: selectedCategoryId,
              hint: Text('Select Category'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: widget.categories
                  .where((c) => c.isActive == 1)
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedCategoryId = val),
            ),
            SizedBox(height: 16),
            Text(
              "Price Range",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (val) => minPrice = double.tryParse(val),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (val) => maxPrice = double.tryParse(val),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'categoryId': selectedCategoryId,
                  'minPrice': minPrice,
                  'maxPrice': maxPrice,
                });
              },
              child: Text('Apply Filters', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'categoryId': null,
                  'minPrice': null,
                  'maxPrice': null,
                });
              },
              child: Text(
                'Clear Filters',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
      );
  }
}
