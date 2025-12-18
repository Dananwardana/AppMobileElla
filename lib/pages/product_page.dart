import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> products = List.generate(10, (index) {
    return {
      'name': 'Baterai button Maxell CR${2016 + index}',
      'slug': 'baterai-button-maxell-cr${2016 + index}',
      'category': 'Kelistrikan',
      'subcategory': 'Baterai',
      'stock': 71 + index % 5,
      'price': 18000,
      'status': 'Published',
      'description': 'Baterai 9V untuk alat elektronik',
      'watt': '9',
      'brand': 'Maxell',
      'image': 'https://via.placeholder.com/40',
      'specs': [], // ✅ Kosongkan awalnya
    };
  });

  void addProduct() {
    setState(() {
      products.add({
        'name': 'New Product ${products.length + 1}',
        'slug': 'new-product-${products.length + 1}',
        'category': 'Kelistrikan',
        'subcategory': 'Baterai',
        'stock': 50,
        'price': 18000,
        'status': 'Published',
        'description': 'Deskripsi baru',
        'watt': '3',
        'brand': 'Brand Baru',
        'image': 'https://via.placeholder.com/40',
        'specs': [],
      });
    });
  }

  // Fungsi buka modal edit
  void _editProduct(BuildContext context, int index) {
    final product = products[index];
    final TextEditingController nameController = TextEditingController(text: product['name']);
    final TextEditingController priceController = TextEditingController(text: '${product['price']}');
    final TextEditingController stockController = TextEditingController(text: '${product['stock']}');
    final TextEditingController descriptionController = TextEditingController(text: product['description']);
    final TextEditingController wattController = TextEditingController(text: product['watt']);
    final TextEditingController brandController = TextEditingController(text: product['brand']);

    // Spesifikasi tambahan — awalnya kosong
    List<Map<String, String>> specs = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Name
                  TextField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),

                  // 2. Price (IDR)
                  TextField(
                    decoration: const InputDecoration(labelText: 'Price (IDR)'),
                    controller: priceController,
                  ),
                  const SizedBox(height: 16),

                  // 3. Stock
                  TextField(
                    decoration: const InputDecoration(labelText: 'Stock'),
                    controller: stockController,
                  ),
                  const SizedBox(height: 16),

                  // 4. Active (dropdown)
                  DropdownButtonFormField<String>(
                    value: product['status'],
                    items: ['Published', 'Draft'].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Active'),
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: 16),

                  // 5. Category (dropdown)
                  DropdownButtonFormField<String>(
                    value: product['category'],
                    items: ['Kelistrikan', 'Baterai', 'Charger'].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Category'),
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: 16),

                  // 6. Subcategory (dropdown)
                  DropdownButtonFormField<String>(
                    value: product['subcategory'],
                    items: ['Baterai', 'AA', 'AAA', '9V'].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Subcategory'),
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: 16),

                  // 7. Image Upload
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('File picker not implemented')),
                            );
                          },
                          child: const Text('Choose File'),
                        ),
                        const SizedBox(width: 8),
                        Text(product['image'].toString().split('/').last),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 8. Description
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 16),

                  // 9. Watt & Brand (side-by-side)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Watt'),
                          controller: wattController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Brand'),
                          controller: brandController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 10. Additional Specifications - AWALNYA KOSONG
                  const Text('Additional Specifications', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: specs.length,
                    itemBuilder: (context, i) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(hintText: 'Key (e.g., Voltage)'),
                              controller: TextEditingController(text: specs[i]['key']),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(hintText: 'Value (e.g., 220V)'),
                              controller: TextEditingController(text: specs[i]['value']),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                specs.removeAt(i);
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          specs.add({'key': '', 'value': ''});
                        });
                      },
                      child: const Text('+ Add Spec'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () {
                setState(() {
                  products[index]['name'] = nameController.text;
                  products[index]['price'] = int.tryParse(priceController.text) ?? 0;
                  products[index]['stock'] = int.tryParse(stockController.text) ?? 0;
                  products[index]['status'] = product['status'];
                  products[index]['category'] = product['category'];
                  products[index]['subcategory'] = product['subcategory'];
                  products[index]['description'] = descriptionController.text;
                  products[index]['watt'] = wattController.text;
                  products[index]['brand'] = brandController.text;
                  products[index]['specs'] = specs; // ✅ Simpan spesifikasi yang ditambahkan
                });
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Products List',
              style: TextStyle(fontSize: isDesktop ? 22 : 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: addProduct,
              child: Text(isDesktop ? 'Add Product' : '+'),
            )
          ],
        ),
        const SizedBox(height: 20),

        // Baris 1: Search Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: isDesktop
                  ? 'Search name, brand, slug...'
                  : 'Search...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Baris 2: Dropdown Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: isDesktop
              ? Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildDropdown('All Categories', ['All Categories', 'Baterai', 'Charger']),
                    _buildDropdown('All Subcategories', ['All Subcategories', 'AA', 'AAA']),
                    _buildDropdown('All Status', ['All Status', 'Published', 'Draft']),
                    _buildDropdown('All Stock', ['All Stock', 'In Stock', 'Out of Stock']),
                    _buildDropdown('10 per page', ['10 per page', '20 per page', '50 per page']),
                  ],
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDropdown('All Categories', ['All Categories', 'Baterai', 'Charger']),
                      const SizedBox(width: 8),
                      _buildDropdown('All Subcategories', ['All Subcategories', 'AA', 'AAA']),
                      const SizedBox(width: 8),
                      _buildDropdown('All Status', ['All Status', 'Published', 'Draft']),
                      const SizedBox(width: 8),
                      _buildDropdown('All Stock', ['All Stock', 'In Stock', 'Out of Stock']),
                      const SizedBox(width: 8),
                      _buildDropdown('10 per page', ['10 per page', '20 per page', '50 per page']),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),

        // Table Header - Hanya di desktop
        if (isDesktop)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Product', style: Theme.of(context).textTheme.labelLarge)),
                Expanded(flex: 2, child: Text('Category', style: Theme.of(context).textTheme.labelLarge)),
                Expanded(flex: 1, child: Text('Stock', style: Theme.of(context).textTheme.labelLarge)),
                Expanded(flex: 1, child: Text('Price', style: Theme.of(context).textTheme.labelLarge)),
                Expanded(flex: 1, child: Text('Status', style: Theme.of(context).textTheme.labelLarge)),
                Expanded(flex: 1, child: Text('Action', style: Theme.of(context).textTheme.labelLarge)),
              ],
            ),
          ),
        const SizedBox(height: 8),

        // Table Body - Responsif
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                    child: const Icon(Icons.image, size: 20, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          p['slug'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(flex: 2, child: Text(p['category'])),
                            Expanded(flex: 1, child: Text('${p['stock']}')),
                            Expanded(flex: 1, child: Text('Rp ${p['price']}')),
                            Expanded(
                              flex: 1,
                              child: Chip(
                                label: Text(p['status']),
                                backgroundColor: p['status'] == 'Published'
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                labelStyle: TextStyle(
                                  color: p['status'] == 'Published' ? Colors.green[800] : Colors.orange[800],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            // ✅ LANGSUNG BUKA EDIT → TANPA MENU
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _editProduct(context, index),
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
                                  child: const Icon(Icons.image, size: 20, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        p['slug'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                                Expanded(child: Text('Category: ${p['category']}')),
                                Expanded(child: Text('Stock: ${p['stock']}')),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('Price: Rp ${p['price']}')),
                                Expanded(
                                  child: Chip(
                                    label: Text(p['status']),
                                    backgroundColor: p['status'] == 'Published'
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    labelStyle: TextStyle(
                                      color: p['status'] == 'Published' ? Colors.green[800] : Colors.orange[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () => _editProduct(context, index),
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

  // Utility: Dropdown yang rapi dan aman
  Widget _buildDropdown(String value, List<String> items) {
    return Container(
      width: 160,
      child: DropdownButton<String>(
        value: value,
        items: items.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (v) {},
        underline: Container(),
        isExpanded: true,
        borderRadius: BorderRadius.circular(8),
        style: const TextStyle(fontSize: 14),
        elevation: 8,
      ),
    );
  }
}