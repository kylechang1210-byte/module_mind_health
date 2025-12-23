import 'database_mindtrack.dart';
import 'checkin_history.dart';
import 'supabase_connection.dart';
import 'package:flutter/material.dart';



class DailyCheckInPage extends StatefulWidget {
  const DailyCheckInPage({super.key});




  @override
  State<DailyCheckInPage> createState() => _DailyCheckInPageState();
}




class _DailyCheckInPageState extends State<DailyCheckInPage> {
  final _formKey = GlobalKey<FormState>();
  final _customFeelingCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int selectedMood = 4;
  double _selectedRange = 0.75; // 0.0 – 1.0




  final List<String> feelings = [
    'Calm', 'Content', 'Excited',
    'Fulfilled', 'Grateful', 'Happy',
    'Hopeful', 'Inspired', 'Loved',
    'Motivated', 'Peaceful', 'Proud',
  ];
  final Set<String> selectedFeelings = {};




  //Supabase
  Future<void> _saveToSupabase({
    required int mood,
    required int score,
    required String feelings,
    required String notes,
  }) async {
    final supabase = SupabaseConnection.client;




    await supabase.from('checkins').insert({
      // id: auto
      // date: has default now() in Supabase, so you can omit it
      'mood': mood.toString(),  // your column is varchar
      'score': score,           // int8
      'feelings': feelings,       // varchar
      'notes': notes,           // varchar
    });
  }




  @override
  void dispose() {
    _customFeelingCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }








  void _onEmojiTap(int moodIndex) {
    setState(() {
      selectedMood = moodIndex;




      switch (moodIndex) {
        case 0: _selectedRange = 0.1; break;
        case 1: _selectedRange = 0.3; break;
        case 2: _selectedRange = 0.5; break;
        case 3: _selectedRange = 0.7; break;
        case 4: _selectedRange = 0.9; break;
      }
    });
  }




  String getRangeLabel() {
    final percent = (_selectedRange * 100).round();




    if (percent <= 20) {
      return '0% - 20%';
    } else if (percent <= 40) {
      return '21% - 40%';
    } else if (percent <= 60) {
      return '41% - 60%';
    } else if (percent <= 80) {
      return '61% - 80%';
    } else {
      return '81% - 100%';
    }
  }








  void _onSliderChanged(double value) {
    setState(() {
      _selectedRange = value;




      final percent = (_selectedRange * 100).round();




      if (percent <= 20) {
        selectedMood = 0; // Terrible
      } else if (percent <= 40) {
        selectedMood = 1; // Meh
      } else if (percent <= 60) {
        selectedMood = 2; // Fine
      } else if (percent <= 80) {
        selectedMood = 3; // Good
      } else {
        selectedMood = 4; // Great
      }
    });
  }




  void myAlertDialogSuccessCheckIn(){
    AlertDialog successAlertDialog = AlertDialog(
      title: const Text('Success'),
      content: Text('Successfully Check In',
      ),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.pop(context);
            }, child: Text('OK'))
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context){
        return successAlertDialog;
      },
    );
  }




  void myAlertDialogErrorCheckIn(String message){
    AlertDialog errorAlertDialog = AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.pop(context);
            }, child: Text('OK'))
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context){
        return errorAlertDialog;
      },
    );
  }




  void _onCheckIn() async {
    if (_formKey.currentState!.validate()) {
      final score = (_selectedRange * 100).round();




      final List<String> all = selectedFeelings.toList();
      final custom = _customFeelingCtrl.text.trim();
      if (custom.isNotEmpty) {
        all.add(custom);
      }
      final feelingsText = all.join(', ');




      try {
        await DatabaseMindTrack.instance.insertCheckIn(
          date: DateTime.now().toIso8601String().substring(0, 10),
          mood: selectedMood,
          score: score,
          feelings: feelingsText,
          notes: _notesCtrl.text.trim(),




        );
        await _saveToSupabase(
          mood: selectedMood,
          score: score,
          feelings: feelingsText,
          notes: _notesCtrl.text.trim(),
        );








        if (!mounted) return;
        myAlertDialogSuccessCheckIn();








        _customFeelingCtrl.clear();
        _notesCtrl.clear();
        selectedFeelings.clear();
        setState(() {});
      } catch (e) {
        if (!mounted) return;
        myAlertDialogErrorCheckIn('Failed to save: $e');




      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CheckInHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 20),
                _buildMoodRow(),
                const SizedBox(height: 20),
                _buildRangePill(),
                const SizedBox(height: 20),
                _buildFeelingCard(),
                const SizedBox(height: 16),
                _buildCustomFeelingField(),
                const SizedBox(height: 12),
                _buildNotesField(),
                const SizedBox(height: 28),
                _buildCheckInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildTitle() {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'Rate ',
            style: TextStyle(
              color: Color(0xFF6D5DF6),
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'Your Day',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildMoodRow() {
    final moods = ['Terrible', 'Meh', 'Fine', 'Good', 'Great'];
    final faces = ['😫', '😕', '😐', '🙂', '😄'];




    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(moods.length, (index) {
        final isSelected = index == selectedMood;
        return GestureDetector(
          onTap: () => _onEmojiTap(index),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF7ED957) : Colors.white,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Text(
                  faces[index],
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                moods[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }




  Widget _buildRangePill() {
    final min = (_selectedRange * 100).round();
    const max = 100;




    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF6D5DF6), Color(0xFF8D5CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '$min% - $max%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _selectedRange,
          min: 0.0,
          max: 1.0,
          activeColor: const Color(0xFF6D5DF6),
          onChanged: _onSliderChanged,
        ),
      ],
    );
  }




  Widget _buildFeelingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF7BC5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_offer_rounded,
                  color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Feeling',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: feelings.map((f) {
              final selected = selectedFeelings.contains(f);
              return ChoiceChip(
                label: Text(
                  f,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF6D5DF6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.white.withOpacity(0.18),
                selectedColor: const Color(0xFFB96BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      selectedFeelings.add(f);
                    } else {
                      selectedFeelings.remove(f);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }




  Widget _buildCustomFeelingField() {
    return TextFormField(
      controller: _customFeelingCtrl,
      decoration: InputDecoration(
        labelText: 'Custom feeling (optional)',
        hintText: 'e.g. Anxious but hopeful',
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value != null && value.trim().length > 40) {
          return 'Keep it short (max 40 characters).';
        }
        return null;
      },
    );
  }




  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesCtrl,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes about your day (optional)',
        hintText: 'Write anything you want to remember from today',
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }




  Widget _buildCheckInButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _onCheckIn,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: const Color(0xFF6D5DF6),
        ),
        child: const Text(
          'Check-In',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),




      ),
    );
  }
}
