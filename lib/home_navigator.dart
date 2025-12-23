import 'package:flutter/material.dart';
import 'main_mindtrack.dart'; // Tab 1: Tracker
import 'therapy_dashboard.dart'; // Tab 2: Therapy Tools
import 'resource_module.dart'; // Tab 3: Resources
import 'profile_page.dart'; // Tab 4: Profile (NEW)

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _currentIndex = 0;

  // The 4 Main Pages
  final List<Widget> _pages = [
    const MainMindTrackPage(), // Index 0
    const TherapyDashboard(), // Index 1
    const ResourceHubScreen(), // Index 2
    const ProfilePage(), // Index 3 (NEW)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        indicatorColor: const Color(0xFFE3F2FD),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            selectedIcon: Icon(Icons.show_chart, color: Color(0xFF5C9DFF)),
            label: 'Track',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement),
            selectedIcon: Icon(
              Icons.self_improvement,
              color: Color(0xFF5C9DFF),
            ),
            label: 'Therapy',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            selectedIcon: Icon(Icons.library_books, color: Color(0xFF5C9DFF)),
            label: 'Resources',
          ),
          // NEW TAB
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF5C9DFF)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
