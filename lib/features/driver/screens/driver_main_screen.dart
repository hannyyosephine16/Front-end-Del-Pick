// lib/features/driver/screens/driver_main_screen.dart (Simplified)
import 'package:flutter/material.dart';
import 'package:del_pick/features/driver/screens/driver_home_screen.dart';
import 'package:del_pick/features/driver/screens/driver_orders_screen.dart';
import 'package:del_pick/features/driver/screens/driver_earnings_screen.dart';
import 'package:del_pick/features/auth/screens/profile_screen.dart'; // Gunakan ProfileScreen yang sudah ada

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DriverHomeScreen(),
    const DriverOrdersScreen(),
    const DriverEarningsScreen(),
    const ProfileScreen(), // Menggunakan ProfileScreen yang sudah ada dan universal
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[600],
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Pendapatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
