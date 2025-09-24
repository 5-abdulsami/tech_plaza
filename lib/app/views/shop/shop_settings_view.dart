import 'package:flutter/material.dart';

class ShopSettingsView extends StatelessWidget {
  const ShopSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Settings')),
      body: const Center(child: Text('Configure shop preferences and details')),
    );
  }
}
