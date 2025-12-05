import 'package:flutter/material.dart';

class SubscriptionCheckoutPlaceholderScreen extends StatelessWidget {
  const SubscriptionCheckoutPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Payment flow is not implemented yet.\n\n'
            'Here we will integrate Apple / Google in-app purchases.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
