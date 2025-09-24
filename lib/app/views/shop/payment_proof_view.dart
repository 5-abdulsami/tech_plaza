import 'package:flutter/material.dart';

class PaymentProofView extends StatelessWidget {
  const PaymentProofView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Proof')),
      body: const Center(child: Text('Upload Easypaisa/JazzCash screenshot')),
    );
  }
}
