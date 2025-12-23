import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'therapy_model.dart';
import 'database_mindtrack.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MovementPage extends StatelessWidget {
  const MovementPage({super.key});
  final Color _brandColor = const Color(0xFF7555FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: const Text('Mindful Movement', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [_brandColor, const Color(0xff5fc3ff)]))),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Choose Your Practice", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _brandColor)),
            const SizedBox(height: 30),
            _buildCategoryCard(context, "Yoga", Icons.self_improvement),
            const SizedBox(height: 15),
            _buildCategoryCard(context, "Pilates", Icons.fitness_center),
            const SizedBox(height: 15),
            _buildCategoryCard(context, "Walking", Icons.directions_walk),
            const SizedBox(height: 15),
            _buildCategoryCard(context, "Tai Chi", Icons.air),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () async {
        final response = await Supabase.instance.client
            .from('movement')
            .select()
            .eq('category', title);

        final steps = List<Map<String, dynamic>>.from(response).map((item) {
          return {
            'id': item['id'],
            'title': item['title'],
            'description': item['description'],
            'iconCode': item['icon_code'] ?? 0xe6bd,
          };
        }).toList();

        if(!context.mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseGuidePage(categoryName: title, steps: steps)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: _brandColor.withValues(alpha: 0.3), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _brandColor.withValues(alpha:0.1), shape: BoxShape.circle),
              child: Icon(icon, color: _brandColor, size: 28),
            ),
            const SizedBox(width: 20),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _brandColor)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: _brandColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class ExerciseGuidePage extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> steps;
  const ExerciseGuidePage({super.key, required this.categoryName, required this.steps});
  @override
  State<ExerciseGuidePage> createState() => _ExerciseGuidePageState();
}

class _ExerciseGuidePageState extends State<ExerciseGuidePage> {
  int _currentStep = 0;
  bool _isCompleted = false;
  final Color _brandColor = const Color(0xFF7555FF);

  void _nextStep() {
    setState(() {
      if (_currentStep < widget.steps.length - 1) {
        _currentStep++;
      } else {
        _isCompleted = true;
        Provider.of<TherapyModel>(context, listen: false).recordSession('${widget.categoryName} Session');
        DatabaseMindTrack.instance.recordHistory('Movement', widget.categoryName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [_brandColor, const Color(0xff5fc3ff)]))),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isCompleted ? _buildCompletionScreen() : _buildStepScreen(),
      ),
    );
  }

  Widget _buildStepScreen() {
    if (widget.steps.isEmpty) return const Center(child: Text("No exercises found."));
    final step = widget.steps[_currentStep];
    IconData icon = IconData(step['iconCode'], fontFamily: 'MaterialIcons');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Step ${_currentStep + 1} of ${widget.steps.length}", style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: _brandColor.withValues(alpha:0.3), blurRadius: 20)]),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [_brandColor.withValues(alpha:0.2), const Color(0xff5fc3ff).withValues(alpha:0.2)])),
                  child: Icon(icon, size: 80, color: _brandColor),
                ),
                const SizedBox(height: 20),
                Text(step['title'], textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _brandColor)),
                const SizedBox(height: 15),
                Text(step['description'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200, height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _brandColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
              onPressed: _nextStep,
              child: const Text("NEXT STEP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          Text("Session Complete!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _brandColor)),
          const SizedBox(height: 40),
          SizedBox(
            width: 200, height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _brandColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
              onPressed: () => Navigator.pop(context),
              child: const Text("FINISH", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}