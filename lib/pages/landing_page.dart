import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/hero_section.dart';
import '../widgets/category_section.dart';
import '../widgets/footer.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HeaderWidget(),
            HeroSection(),
            CategorySection(),
            FooterWidget(),
          ],
        ),
      ),
    );
  }
}
