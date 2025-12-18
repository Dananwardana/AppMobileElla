import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  Widget categoryCard(String title, String image) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            image,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD8CCC0),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori Pilihan',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
  builder: (context, constraints) {
    int crossAxisCount = 2;

    if (constraints.maxWidth >= 1200) {
      crossAxisCount = 3;
    } else if (constraints.maxWidth >= 800) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 3,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        final items = [
          {
            'title': 'Elektronik Rumah Tangga',
            'image': 'assets/images/elektronikrumahtangga.png',
          },
          {
            'title': 'Elektronik Dapur',
            'image': 'assets/images/elektronikdapur.png',
          },
          {
            'title': 'Kelistrikan',
            'image': 'assets/images/kelistrikan.png',
          },
        ];

        return categoryCard(
          items[index]['title']!,
          items[index]['image']!,
        );
      },
    );
  },
),

        ],
      ),
    );
  }
}
