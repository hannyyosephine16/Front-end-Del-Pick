import 'package:flutter/material.dart';

// lib/features/store/screens/store_menu_screen.dart
class StoreMenuScreen extends StatelessWidget {
  const StoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Store Menu Screen - Coming Soon'),
      ),
    );
  }
}
