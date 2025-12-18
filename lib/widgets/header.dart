import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF183045),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logoella.png',
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          const Text(
            'Ella Elektrik',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            'Login',
            style: TextStyle(color: Colors.white),
          ),
        )
        ],
      ),
    );
  }
}
