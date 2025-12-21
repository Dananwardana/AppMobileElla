import 'package:flutter/material.dart';
import '../services/product_service.dart';
import 'product_form_page.dart'; // Import the new combined form page

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
      final list = List<Map<String, dynamic>>.from(items);
      setState(() {
        products = list;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- UPDATED: Navigate to ProductFormPage for creating ---
  void _onAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductFormPage()), // null product = Create
    );

    if (result == true) {
      _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Created!')),
      );
    }
  }

  // --- UPDATED: Navigate to ProductFormPage for editing ---
  void _onEditProduct(Map<String, dynamic> product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductFormPage(product: product)), // pass product = Edit
    );

    if (result == true) {
      _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Updated!')),
      );
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> product, int index) async {
    final productName = product['name']?.toString() ?? 'product';

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text('Yakin ingin menghapus $productName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final id = product['id'];
    if (id == null) return;

    try {
      await ProductService.deleteProduct(id as int);
      if (!mounted) return;

      setState(() {
        products.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$productName dihapus.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus $productName: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProducts,
              child: products.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Belum ada produk')),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: products.length,
                      // Add padding at bottom so FAB doesn't cover last item
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final name = product['name']?.toString() ?? 'Product';
                        final price = product['price'];
                        final stock = product['stock'] ?? 0;

                        // Image URL Logic
                        final rawImagePath = product['image_url']?.toString();
                        String? imageUrl;
                        if (rawImagePath != null && rawImagePath.isNotEmpty) {
                          if (rawImagePath.startsWith('http')) {
                            imageUrl = rawImagePath;
                          } else {
                            final apiBase = ProductService.baseUrl;
                            final imageBase = apiBase.replaceFirst('/api', '');
                            imageUrl = '$imageBase$rawImagePath';
                          }
                        }
                        final hasImage = imageUrl != null && imageUrl.isNotEmpty;

                        // Status Logic
                        final statusValue = product['status'];
                        final isActiveFromStatus = statusValue == 'Active';
                        final isActiveFromFlag = product['is_active'] == 1;
                        final isActive = isActiveFromStatus || isActiveFromFlag;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // 1. Image
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: hasImage
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(imageUrl, fit: BoxFit.cover),
                                        )
                                      : const Icon(Icons.inventory_2, size: 50, color: Colors.grey),
                                ),
                                const SizedBox(width: 16),
                                
                                // 2. Text Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text('Harga: ${_formatPrice(price)}'),
                                      Text('Stok: $stock'),
                                      Text(
                                        'Status: ${isActive ? 'Active' : 'Inactive'}',
                                        style: TextStyle(color: isActive ? Colors.green : Colors.red),
                                      ),
                                    ],
                                  ),
                                ),

                                // 3. Menu Button
                                PopupMenuButton<String>(
                                  onSelected: (value) => value == 'edit'
                                      ? _onEditProduct(product)
                                      : _confirmDelete(product, index),
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic value) {
    if (value == null) return 'Rp 0';
    return 'Rp ${value.toString()}';
  }
}