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
        final kategori =
            subkategori != null ? subkategori['kategori'] as Map<String, dynamic>? : null;
        return {
          'id': raw['id'],
          'name': raw['name'],
          'slug': raw['slug'],
          'description': raw['description'],
          'price': raw['price'],
          'stock': raw['stock'],
          'status': (raw['is_active'] == 1) ? 'Active' : 'Inactive',
          'image_url': raw['image_url'] != null ? raw['image_url'].toString() : null,
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

  void _onAddProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add product coming soon.')),
    );
  }

  void _onEditProduct(Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${product['name'] ?? 'product'} coming soon.')),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> product, int index) async {
    final productName = product['name'] ?? 'product';
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

    if (shouldDelete != true) {
      return;
    }

    final id = product['id'];
    if (id == null) {
      return;
    }

    try {
      await ProductService.deleteProduct(id as int);
      if (!mounted) {
        return;
      }
      setState(() {
        products.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$productName dihapus.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus $productName: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          children: [
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                child: products.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 48, 16, 140),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Center(
                              child: _loading
                                  ? const CircularProgressIndicator()
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Belum ada produk',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tekan tombol Add Product untuk menambah produk baru.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _ProductCard(
                            product: product,
                            onEdit: () => _onEditProduct(product),
                            onDelete: () => _confirmDelete(product, index),
                            formatCurrency: _formatCurrency,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(dynamic rawValue) {
    if (rawValue == null) {
      return 'Rp 0';
    }

    num? parsed;
    if (rawValue is num) {
      parsed = rawValue;
    } else if (rawValue is String) {
      final noComma = rawValue.replaceAll(',', '');
      parsed = num.tryParse(noComma);
      if (parsed == null) {
        final dotParts = noComma.split('.');
        if (dotParts.length > 2) {
          final joined = dotParts.sublist(0, dotParts.length - 1).join('') +
              '.${dotParts.last}';
          parsed = num.tryParse(joined);
        }
      }
      parsed ??= num.tryParse(rawValue);
    }

    parsed ??= 0;

    final rounded = parsed is int ? parsed : parsed.round();
    final digits = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.formatCurrency,
  });

  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(dynamic) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = product['status'] == 'Active';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductThumbnail(imageUrl: _stringOrNull(product['image_url'])),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product['name'] ?? 'Product'}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product['slug'] ?? '-'}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  onEdit();
                                  break;
                                case 'delete':
                                  onDelete();
                                  break;
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatCurrency(product['price']),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF1E88E5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stock: ${product['stock'] ?? 0}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatusChip(isActive: isActive),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              product['category'] != null
                                  ? '${product['category']}'
                                  : 'Tidak ada kategori',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (product['description'] != null &&
                          '${product['description']}'.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            '${product['description']}',
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFFD1D9E6),
        borderRadius: BorderRadius.circular(16),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasImage
          ? null
          : const Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: 28,
            ),
    );
  }
}

String? _stringOrNull(dynamic value) {
  if (value == null) {
    return null;
  }
  return value.toString();
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF1B5E20) : const Color(0xFFC62828);
    final bg = isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final label = isActive ? 'Active' : 'Inactive';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
