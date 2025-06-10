import 'package:flutter/material.dart';

class StoreOrdersScreen extends StatelessWidget {
  const StoreOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Store Orders Screen - Coming Soon'),
      ),
    );
  }
}

