import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offers')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_offer, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text('Offers', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
