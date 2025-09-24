import 'package:flutter/material.dart';

class ShopAnalyticsView extends StatelessWidget {
  const ShopAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Shop analytics overview')),
    );
  }
}
