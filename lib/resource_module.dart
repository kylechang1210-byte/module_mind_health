import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ResourceScreen(),
  ));
}

// 1. THE DATA MODEL (This is how we structure the data)
class Resource {
  final String title;
  final String category;
  final String description;
  final String url;
  final IconData icon;
  final Color color;

  Resource({
    required this.title,
    required this.category,
    required this.description,
    required this.url,
    required this.icon,
    required this.color,
  });
}

class ResourceScreen extends StatefulWidget {
  const ResourceScreen({super.key});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  // 2. THE DATA (Hardcoded for now, easier to test than Database)
  final List<Resource> _allResources = [
    Resource(
      title: "5-4-3-2-1 Grounding",
      category: "Anxiety",
      description: "Panic attack? Use this sensory countdown to calm down instantly.",
      url: "https://www.mayoclinichealthsystem.org/hometown-health/speaking-of-health/5-4-3-2-1-grounding-technique",
      icon: Icons.self_improvement,
      color: Colors.purple,
    ),
    Resource(
      title: "TARUMT Counselling",
      category: "Support",
      description: "Book an official appointment with campus counsellors.",
      url: "https://www.tarc.edu.my/dsa/counselling/counselling-services/",
      icon: Icons.support_agent,
      color: Colors.red,
    ),
    Resource(
      title: "Pomodoro Technique",
      category: "Study",
      description: "Overwhelmed? Study in 25-minute chunks.",
      url: "https://todoist.com/productivity-methods/pomodoro-technique",
      icon: Icons.timer,
      color: Colors.orange,
    ),
    Resource(
      title: "Sleep Hygiene Guide",
      category: "Health",
      description: "Why pulling an all-nighter hurts your grades.",
      url: "https://www.sleepfoundation.org/teens-and-sleep",
      icon: Icons.bed,
      color: Colors.blue,
    ),
    Resource(
      title: "Box Breathing",
      category: "Anxiety",
      description: "A Navy SEAL technique to regain control of your breath.",
      url: "https://www.webmd.com/balance/what-is-box-breathing",
      icon: Icons.air,
      color: Colors.teal,
    ),
  ];

  // Variables for Search & Filter
  List<Resource> _filteredResources = [];
  String _selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredResources = _allResources; // Start by showing everything
  }

  // 3. THE LOGIC (Search + Filter)
  void _runFilter() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredResources = _allResources.where((resource) {
        // Rule 1: Must match category (unless "All" is selected)
        bool matchesCategory = _selectedCategory == "All" || resource.category == _selectedCategory;
        // Rule 2: Must match search text
        bool matchesSearch = resource.title.toLowerCase().contains(query);

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _changeCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _runFilter();
  }

  // 4. OPEN LINK FUNCTION
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get unique categories for the tabs
    final categories = ["All", ..._allResources.map((e) => e.category).toSet()];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8), // Soft mint background
      appBar: AppBar(
        title: const Text("Knowledge Hub"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // A. SEARCH BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(),
              decoration: InputDecoration(
                hintText: "Search topics...",
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // B. CATEGORY CHIPS (Horizontal Scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      _changeCategory(cat);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Colors.teal.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.teal.shade900 : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.teal : Colors.grey.shade300),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // C. THE LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredResources.length,
              itemBuilder: (context, index) {
                final item = _filteredResources[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _launchURL(item.url),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon Box
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item.icon, color: item.color),
                          ),
                          const SizedBox(width: 16),
                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          // Arrow
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}