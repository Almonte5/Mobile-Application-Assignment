import 'package:flutter/material.dart';
import 'package:mq_marketplace/screens/home_screen.dart';
import 'package:mq_marketplace/screens/my_listings_screen.dart';
import 'package:mq_marketplace/screens/new_listing_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final _tabs = const [
    HomeScreen(),
    MyListingsScreen(),
    Placeholder(), // Profile — coming soon
  ];

  Future<void> _onTabTapped(int index) async {
    if (index == 1) {
      // Sell tab is an action, not a destination
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NewListingScreen()),
      );
      return;
    }

    // Remap: 0→Home, 2→MyListings, 3→Profile
    final bodyIndex = index == 0 ? 0 : index - 1;
    setState(() => _selectedIndex = bodyIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex == 0 ? 0 : _selectedIndex + 1,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}