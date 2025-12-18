import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF123458),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ella Elektrik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Solusi Elektronik Terlengkap untuk Kebutuhan Anda\n'
                  'Belanja Elektronik Mudah & Terpercaya\n'
                  'Semua ada di Ella Elektrik',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text(
                    'Lihat Selengkapnya',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 28),
          Flexible(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'assets/images/produklogo.png',
                width: 340,
                height: 240,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
