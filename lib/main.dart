import 'package:flutter/material.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // 👇 routing
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),

        // dummy dulu
        '/catalog': (context) => const Scaffold(
          body: Center(child: Text('Halaman Katalog')),
        ),
        '/admin': (context) => const DashboardPage(),
      },
    );
  }
}
