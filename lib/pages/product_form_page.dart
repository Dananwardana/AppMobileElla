import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/product_service.dart';

class ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? product; // Null = Create, Not Null = Edit

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Text Controllers
  late TextEditingController _nameC;
  late TextEditingController _priceC;
  late TextEditingController _stockC;
  late TextEditingController _descC;
  late TextEditingController _brandC;
  late TextEditingController _wattC;

  // State
  bool _isActive = true;
  bool _isLoading = false;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  
  // Specs & Errors
  final List<Map<String, String>> _specs = [];
  Map<String, String> _fieldErrors = {};

  // --- DROPDOWN DATA ---
  List<Map<String, dynamic>> _categories = [];       // List from API
  List<Map<String, dynamic>> _allSubcategories = []; // List from API
  
  // --- DROPDOWN SELECTION ---
  int? _selectedCategoryId;    
  int? _selectedSubCategoryId; 

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameC = TextEditingController(text: p?['name']?.toString() ?? '');
    _priceC = TextEditingController(text: p?['price']?.toString() ?? '');
    _stockC = TextEditingController(text: p?['stock']?.toString() ?? '');
    _descC = TextEditingController(text: p?['description']?.toString() ?? '');
    _brandC = TextEditingController(text: p?['brand']?.toString() ?? '');
    _wattC = TextEditingController(text: p?['watt']?.toString() ?? '');

    if (p != null) {
      _isActive = (p['is_active'] == 1) || (p['status'] == 'Active');
      
      // Load Specs
      if (p['specs'] is List) {
        for (var s in p['specs']) {
          if (s is Map) {
            _specs.add({
              'key': s['key']?.toString() ?? '',
              'value': s['value']?.toString() ?? ''
            });
          }
        }
      }

      // Load Selected Subcategory ID
      if (p['subkategori_product_id'] != null) {
        _selectedSubCategoryId = int.tryParse(p['subkategori_product_id'].toString());
      }
      
      // We do NOT rely on p['subkategori']['kategori'] here because it might be null.
      // We will derive the Category ID inside _loadDropdownData instead.
    }

    // Fetch Data
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      // Fetch both lists in parallel
      final results = await Future.wait([
        ProductService.getCategories(),
        ProductService.getSubcategories(),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0];
          _allSubcategories = results[1];

          // --- AUTO-SELECT LOGIC ---
          // If we are editing (have a subcategory ID) but don't have a category ID,
          // find the subcategory in the list and get its parent ID.
          if (_selectedSubCategoryId != null && _selectedCategoryId == null) {
             final sub = _allSubcategories.firstWhere(
               (s) => s['id'] == _selectedSubCategoryId, 
               orElse: () => {}
             );
             
             if (sub.isNotEmpty) {
               _selectedCategoryId = sub['kategori_product_id'];
             }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading dropdowns: $e');
    }
  }

  @override
  void dispose() {
    _nameC.dispose(); _priceC.dispose(); _stockC.dispose(); _descC.dispose();
    _brandC.dispose(); _wattC.dispose();
    super.dispose();
  }

  // --- Helpers ---
  void _addSpec() => setState(() => _specs.add({'key': '', 'value': ''}));
  void _removeSpec(int i) => setState(() => _specs.removeAt(i));
  void _updateSpec(int i, String k, String v) => _specs[i][k] = v;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, 
      maxWidth: 1000
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  // --- FILTER LOGIC ---
  // Returns only subcategories that belong to the selected Category
  List<Map<String, dynamic>> get _filteredSubcategories {
    if (_selectedCategoryId == null) return [];
    return _allSubcategories
        .where((sub) => sub['kategori_product_id'] == _selectedCategoryId)
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _fieldErrors = {};
    });

    try {
      final Map<String, dynamic> data = {
        'name': _nameC.text,
        'price': _priceC.text,
        'stock': _stockC.text,
        'description': _descC.text,
        'brand': _brandC.text,
        'watt': _wattC.text,
        'subkategori_product_id': _selectedSubCategoryId?.toString() ?? '', 
        'is_active': _isActive,
        'specs': _specs,
      };

      if (widget.product == null) {
        await ProductService.createProduct(data, image: _imageFile);
      } else {
        await ProductService.updateProduct(widget.product!['id'], data, image: _imageFile);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception:', '').trim();
      
      if (errorMsg.contains('subkategori_product_id') || errorMsg.contains('subkategori product id')) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Subcategory'), backgroundColor: Colors.red)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    
    // Image Preview
    ImageProvider? imageProvider;
    if (_imageBytes != null) {
      imageProvider = MemoryImage(_imageBytes!);
    } else if (isEdit && widget.product!['image_url'] != null) {
      final raw = widget.product!['image_url'].toString();
      if (raw.isNotEmpty) {
        String url = raw.startsWith('http') ? raw : '${ProductService.baseUrl.replaceAll('/api', '')}${raw.startsWith('/') ? '' : '/'}$raw';
        imageProvider = NetworkImage(url);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Product' : 'Add Product')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- Image Picker ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150, width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: imageProvider != null 
                              ? DecorationImage(image: imageProvider, fit: BoxFit.cover) 
                              : null,
                        ),
                        child: imageProvider == null
                            ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Text Fields ---
                    TextFormField(
                      controller: _nameC,
                      decoration: InputDecoration(labelText: 'Name', border: const OutlineInputBorder(), errorText: _fieldErrors['name']),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _priceC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: _stockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- CATEGORY DROPDOWN ---
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      hint: const Text('Select Category'),
                      items: _categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat['id'],
                          child: Text(cat['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                          _selectedSubCategoryId = null; // Reset subcategory when parent changes
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // --- SUBCATEGORY DROPDOWN ---
                    DropdownButtonFormField<int>(
                      value: _selectedSubCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Subcategory', 
                        border: const OutlineInputBorder(),
                        errorText: _fieldErrors['subkategori_product_id']
                      ),
                      hint: const Text('Select Subcategory'),
                      // Load filtered list based on _selectedCategoryId
                      items: _filteredSubcategories.map((sub) {
                        return DropdownMenuItem<int>(
                          value: sub['id'],
                          child: Text(sub['name']),
                        );
                      }).toList(),
                      onChanged: _selectedCategoryId == null ? null : (val) {
                        setState(() {
                          _selectedSubCategoryId = val;
                        });
                      },
                      // Disable if no category selected
                      disabledHint: const Text('Select Category first'),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _wattC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Watt', border: OutlineInputBorder()))),
                        const SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: _brandC, decoration: const InputDecoration(labelText: 'Brand', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(controller: _descC, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                    SwitchListTile(title: const Text('Is Active?'), value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
                    
                    const Divider(height: 30),
                    
                    // --- Specs ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: _addSpec, icon: const Icon(Icons.add_circle, color: Colors.blue)),
                      ],
                    ),
                    ..._specs.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Expanded(child: TextFormField(initialValue: e.value['key'], decoration: const InputDecoration(hintText: 'Key', isDense: true), onChanged: (v) => _updateSpec(e.key, 'key', v))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(initialValue: e.value['value'], decoration: const InputDecoration(hintText: 'Value', isDense: true), onChanged: (v) => _updateSpec(e.key, 'value', v))),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeSpec(e.key)),
                      ]),
                    )),

                    const SizedBox(height: 30),
                    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submit, child: Text(isEdit ? 'Update' : 'Create'))),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}