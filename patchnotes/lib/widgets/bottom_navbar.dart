import 'package:flutter/material.dart';
class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped; 

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => onTabTapped(index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.purple, 
      unselectedItemColor: Colors.grey, 
      showSelectedLabels: true,  
      items: [
        _buildNavItem(0, Icons.dashboard, 'Dashboard'),
        _buildNavItem(1, Icons.insights, 'Insights'),
        _buildNavItem(2, Icons.person, 'Profile'),
        _buildNavItem(3, Icons.settings, 'Settings'),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(int index, IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
      
    );
  }
}
