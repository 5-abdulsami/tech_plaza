import 'package:flutter/material.dart';

class ShopChatView extends StatelessWidget {
  const ShopChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Chat')),
      body: const Center(child: Text('Shop chat overview')),
    );
  }
}
