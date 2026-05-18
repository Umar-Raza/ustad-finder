import 'package:flutter/material.dart';
import '../models/tutor.dart';

class PricingScreen extends StatelessWidget {
  final Tutor tutor;
  final Map<String, dynamic> request;

  const PricingScreen({super.key, required this.tutor, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing Engine')),
      body: Center(
        child: Text('Pricing calculation for ${tutor.name}\n(Coming soon)', textAlign: TextAlign.center),
      ),
    );
  }
}
