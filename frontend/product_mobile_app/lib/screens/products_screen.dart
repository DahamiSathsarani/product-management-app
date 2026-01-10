import 'package:flutter/material.dart';
import 'package:product_mobile_app/screens/add_product_screen.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProductService>().fetchProducts();

    _scroll.addListener(() {
      final service = context.read<ProductService>();
      if (_scroll.position.pixels ==
              _scroll.position.maxScrollExtent &&
          !service.isLoading) {
        service.fetchProducts(page: service.currentPage + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ProductService>();

    return Scaffold(
      body: ListView.builder(
        controller: _scroll,
        itemCount: service.products.length + 1,
        itemBuilder: (_, i) {
          if (i == service.products.length) {
            return service.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox();
          }

          final p = service.products[i];
          return ListTile(
            title: Text(p.name),
            subtitle: Text('${p.categoryName} • Rs.${p.price}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => service.deleteProduct(p.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}