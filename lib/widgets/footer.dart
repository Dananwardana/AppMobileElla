import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F1ED),
      padding: const EdgeInsets.all(24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ella Elektrik',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Jalan Stasiun Ceper No.940\n'
            'Kabupaten Klaten, Jawa Tengah',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
