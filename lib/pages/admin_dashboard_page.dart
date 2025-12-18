import 'package:flutter/material.dart';
import 'product_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedMenu = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // ✅ Pastikan ini ada

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 768;

    return Scaffold(
      key: _scaffoldKey, // ✅ Beri key ke Scaffold
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: const Color(0xFF1A2B45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ella Elektrik',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white30),
                  ...[
                    {'title': 'Dashboard', 'index': 1},
                    {'title': 'Produk', 'index': 2},
                    {'title': 'Pesanan', 'index': 3},
                    {'title': 'User', 'index': 4},
                  ].map((item) {
                    final isSelected = selectedMenu == item['index'];
                    return ListTile(
                      // ❌ HAPUS ICON CIRCLE → tidak ada di gambar kamu
                      // leading: Icon(Icons.circle, size: 8, color: isSelected ? Colors.blue : Colors.grey[300]),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.blue,
                      onTap: () {
                        setState(() => selectedMenu = item['index'] as int);
                        if (!isDesktop) {
                          Navigator.pop(context); // ✅ Tutup drawer setelah klik
                        }
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
      body: isDesktop
          ? Row(
              children: [
                // SIDEBAR
                Container(
                  width: 220,
                  color: const Color(0xFF1A2B45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Ella Elektrik',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white30),
                      ...[
                        {'title': 'Dashboard', 'index': 1},
                        {'title': 'Produk', 'index': 2},
                        {'title': 'Pesanan', 'index': 3},
                        {'title': 'User', 'index': 4},
                      ].map((item) {
                        final isSelected = selectedMenu == item['index'];
                        return ListTile(
                          // ❌ HAPUS ICON CIRCLE → tidak ada di gambar kamu
                          // leading: Icon(Icons.circle, size: 8, color: isSelected ? Colors.blue : Colors.grey[300]),
                          title: Text(
                            item['title'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue,
                          onTap: () {
                            setState(() => selectedMenu = item['index'] as int);
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
                // CONTENT
                Expanded(
                  child: Column(
                    children: [
                      // HEADER
                      Container(
                        height: 60,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 300,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Icon(Icons.notifications_none, color: Colors.grey[600]),
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '3',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    CircleAvatar(child: Text('AD')),
                                    const SizedBox(width: 8),
                                    Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // MAIN CONTENT
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: selectedMenu == 2
                              ? const ProductPage()
                              : const Center(child: Text('Halaman belum dibuat')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // HEADER MOBILE
                Container(
                  height: 60,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(), // ✅ Pakai key!
                      ),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Icon(Icons.notifications_none, color: Colors.grey[600]),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              CircleAvatar(child: Text('AD')),
                              const SizedBox(width: 8),
                              Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // MAIN CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: selectedMenu == 2
                        ? const ProductPage()
                        : const Center(child: Text('Halaman belum dibuat')),
                  ),
                ),
              ],
            ),
    );
  }
}