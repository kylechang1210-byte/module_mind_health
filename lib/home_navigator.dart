import 'package:flutter/material.dart';
import 'main_mindtrack.dart'; // Links to your existing MindTrack page
import 'resource_hub.dart';   // Links to your existing Resource Hub
import 'therapy_dashboard.dart'; // Links to the new dashboard we make in Step 3

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _currentIndex = 0;

  // The 3 Main Tabs using your existing pages
  final List<Widget> _pages = [
    const MainMindTrackPage(), // Your Tracker/Journal logic
    const TherapyDashboard(),  // Your Breathing/Music/Movement logic
    const ResourceHubScreen(), // Your Articles/Contacts/Admin logic
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Track',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'Resources',
          ),
        ],
      ),
    );
  }
}