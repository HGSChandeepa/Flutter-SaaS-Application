import 'package:flutter/material.dart';
import 'package:langvify/constants/colors.dart';
import 'package:langvify/screens/conversion_history.dart';
import 'package:langvify/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Method to handle the tapping on bottom navigation items
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _selectedIndex == 0
            ? const HomeScreen()
            : const HistoryConversions(),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.transform),
              label: 'Conversion',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: const Color.fromARGB(255, 5, 35, 61),
          selectedItemColor: const Color.fromARGB(255, 252, 254, 255),
          onTap: _onItemTapped,
          backgroundColor: mainColor),
    );
  }
}
