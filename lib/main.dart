import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/product_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EllaElektrikApp());
}

class EllaElektrikApp extends StatelessWidget {
  const EllaElektrikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ella Elektrik',
      theme: ThemeData(primarySwatch: Colors.blue),

      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/admin': (context) => const ProductPage(),
      },
    );
  }
}
