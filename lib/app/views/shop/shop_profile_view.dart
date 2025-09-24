import 'package:flutter/material.dart';

class ShopProfileView extends StatelessWidget {
  const ShopProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Profile')),
      body: const Center(child: Text('Shop details and public profile')),
    );
  }
}
