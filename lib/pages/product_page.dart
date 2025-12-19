import 'package:flutter/material.dart';
import '../services/product_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> products = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ProductService.getAdminProducts();

      final mapped = items.map<Map<String, dynamic>>((raw) {
        final subkategori = raw['subkategori'] as Map<String, dynamic>?;
        final kategori = subkategori != null
            ? subkategori['kategori'] as Map<String, dynamic>?
            : null;

        return {
          'id': raw['id'],
          'name': raw['name'],
          'slug': raw['slug'],
          'description': raw['description'],
          'price': raw['price'],
          'stock': raw['stock'],
          'status': (raw['is_active'] == 1) ? 'Published' : 'Draft',
          'image_url': raw['image_url'],
          'watt': raw['watt'],
          'brand': raw['brand'],
          'specs': raw['specs'] ?? [],
          'subcategory_id': raw['subkategori_product_id'],
          'subcategory': subkategori != null ? subkategori['name'] : null,
          'category': kategori != null ? kategori['name'] : null,
        };
      }).toList();

      setState(() {
        products = mapped;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loading) const Center(child: CircularProgressIndicator()),
        if (_error != null && !_loading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),

        // Table Header
        if (isDesktop)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Product',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Category',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Stock',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Price',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Action',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),

        // Table Body
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: isDesktop
                      ? Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.image,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${p['name'] ?? ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${p['slug'] ?? ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${p['category'] ?? ''}'),
                            ),
                            Expanded(flex: 1, child: Text('${p['stock']}')),
                            Expanded(flex: 1, child: Text('Rp ${p['price']}')),
                            Expanded(
                              flex: 1,
                              child: Chip(
                                label: Text('${p['status'] ?? ''}'),
                                backgroundColor: p['status'] == 'Published'
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                labelStyle: TextStyle(
                                  color: p['status'] == 'Published'
                                      ? Colors.green[800]
                                      : Colors.orange[800],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final id = p['id'];
                                  if (id == null) return;

                                  try {
                                    await ProductService.deleteProduct(
                                      id as int,
                                    );
                                    setState(() {
                                      products.removeAt(index);
                                    });
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to delete product: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${p['name'] ?? ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${p['slug'] ?? ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Category: ${p['category'] ?? ''}',
                                  ),
                                ),
                                Expanded(child: Text('Stock: ${p['stock']}')),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('Price: Rp ${p['price']}'),
                                ),
                                Expanded(
                                  child: Chip(
                                    label: Text('${p['status'] ?? ''}'),
                                    backgroundColor: p['status'] == 'Published'
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    labelStyle: TextStyle(
                                      color: p['status'] == 'Published'
                                          ? Colors.green[800]
                                          : Colors.orange[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final id = p['id'];
                                    if (id == null) return;

                                    try {
                                      await ProductService.deleteProduct(
                                        id as int,
                                      );
                                      setState(() {
                                        products.removeAt(index);
                                      });
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to delete product: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
