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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: selectedCategoryId,
            hint: Text('Select Category'),
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
          SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Min Price'),
            onChanged: (val) => minPrice = double.tryParse(val),
          ),
          SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Max Price'),
            onChanged: (val) => maxPrice = double.tryParse(val),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'categoryId': selectedCategoryId,
                'minPrice': minPrice,
                'maxPrice': maxPrice,
              });
            },
            child: Text('Apply Filters'),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'categoryId': null,
                'minPrice': null,
                'maxPrice': null,
              });
            },
            child: Text('Clear Filters', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }
}