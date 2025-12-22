import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'supabase_connection.dart';
import 'auth_screens.dart'; // Contains AuthGate
import 'therapy_model.dart'; // Your existing model

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  await SupabaseConnection.init();

  // 2. Run App with Provider (Keeps your Therapy logic alive)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TherapyModel()),
      ],
      child: const MindHealthApp(),
    ),
  );
}

class MindHealthApp extends StatelessWidget {
  const MindHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mind Health',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C9DFF), // kPrimaryBlue from your config
          primary: const Color(0xFF5C9DFF),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // kBackgroundBlue
      ),
      // 3. Point to AuthGate (which decides Login vs Home)
      home: const AuthGate(),
    );
  }
}